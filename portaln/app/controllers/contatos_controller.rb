class ContatosController < ApplicationController
  include SimpleCaptcha::ControllerHelpers  
  
  def index
    @configuracao ||= Configuracao.find(:first)
  end                       
  
  def create
    @configuracao ||= Configuracao.find(:first)
    
    unless @configuracao
      flash[:error] = t('portaln.configuracoes.mensagens.nao_configurado')
      redirect_to root_path
      return
    end
    
    unless campos_preenchidos? params                
      flash.now[:error] = t('portaln.contatos.mensagens.preencha_todos_campos')
      render 'index'
      return
    end
    
    if simple_captcha_valid?                
      Notificador.deliver_email_contato(params[:mensagem], @configuracao)
      flash[:notice] = t('portaln.contatos.mensagens.enviada')
    else
      flash[:error] = t('portaln.contatos.mensagens.captcha_invalido')
    end
           
    redirect_to :controller => :contatos, :action => :index
  end
  
  private
  def campos_preenchidos? params    
    preenchido? params[:mensagem] and    
    preenchido? params[:mensagem][:nome] and
    preenchido? params[:mensagem][:email] and
    preenchido? params[:mensagem][:assunto] and
    preenchido? params[:mensagem][:conteudo]
  end
  
  def preenchido? elemento
    elemento and (not elemento.empty?)
  end
  
end