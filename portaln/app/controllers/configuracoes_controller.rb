class ConfiguracoesController < ApplicationController
                
  before_filter :authenticate_user!
  before_filter do |controller|
    # Lanca Aegis::PermissionError caso nao possa
    controller.current_user.may_configurar_sistema!
  end
                                               
  def index
    @configuracao = Configuracao.find(:first)
    unless @configuracao then @configuracao = Configuracao.new end
  end
  
  def update
    if params[:configuracao][:id] and (not params[:configuracao][:id].empty?)          
      @configuracao ||= Configuracao.find(params[:configuracao][:id])
    end
                                                               
    if @configuracao                           
      @configuracao.quem_alterou = current_user
      @configuracao.update_attributes!(params[:configuracao])
      
    else
      @configuracao = Configuracao.new(params[:configuracao])
      @configuracao.quem_alterou = current_user
      @configuracao.save!
    end
    
    flash[:notice] = t('portaln.configuracoes.mensagens.salva')
    redirect_to :controller => :configuracoes, :action => :index
    
  # TODO: Capturar o erro do active record, para evitar de pegar outros problemas ou
  # ficar loggando mensagens de erro de validacao  
  rescue => e                               
    logger.error e.message
    render 'index'
  end
  
end