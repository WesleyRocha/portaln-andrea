class AnexosController < ApplicationController
  
  # ====================================================================================================================
  # Filtros  
  # ====================================================================================================================
  
  before_filter :authenticate_user!, :except => :download
  
  protect_from_forgery :except => [:create]    
                              
  # Filtro que verifica se o usuario logado tem permissao para manipular o
  # anexo informado
  before_filter :only => [:create, :destroy, :all_by_noticia] do |controller|
    
    @noticia = Noticia.find(controller.params[:noticia_id])
    # Lanca Aegis::PermissionError caso nao possa
    controller.current_user.may_editar_noticia! @noticia
    
  end                            
           
  # ====================================================================================================================
  # Metodos de action
  # ====================================================================================================================
  
  def create
    @noticia ||= Noticia.find(params[:noticia_id])
    
    @anexo = Anexo.new(params[:anexo].merge({:noticia_id => @noticia.id}))          
                    
    @anexo.arquivo_content_type = mime_type @anexo                
    @anexo.save!
    
    render :nothing => true
  end
     
  def destroy
    Anexo.find(params[:id]).destroy
    
    flash[:notice] = t('portaln.noticias.mensagens.anexo.removido')
    redirect_to :controller => :noticias, :action => :edit, :id => params[:noticia_id]
  end
  
  def download
    @anexo = Anexo.find(params[:id])
    @noticia = @anexo.noticia
    if @noticia.publicada? or (user_signed_in? and current_user.id == @noticia.user.id)
      @style = 'original'
      send_file @anexo.arquivo.path(@style)
    else
      render :nothing => true, :status => 403
    end
  end
  
  def all_by_noticia
    @noticia ||= Noticia.find(params[:noticia_id])        
    @anexos = @noticia.anexos
    render :partial => 'anexos/lista_edicao', :layout => false
  end                                      
  
  private
  def mime_type anexo
    MIME::Types.type_for(anexo.arquivo_file_name).to_s
  end

end