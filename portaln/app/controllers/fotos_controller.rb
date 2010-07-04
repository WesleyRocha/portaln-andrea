class FotosController < ApplicationController
                              
  before_filter :authenticate_user!, :except => :show
  
  # Filtro que verifica se o usuario logado tem permissao para manipular o
  # album informado
  before_filter :only => [
    :create, :destroy, :all_by_album, :publicar, :tirar_do_ar, :salvar_ordem,
    :carregar_legendas, :salvar_legendas
  ] do |controller|
    
    @album = Album.find(controller.params[:album_id])
    # Lanca Aegis::PermissionError caso nao possa
    controller.current_user.may_editar_album! @album
    
  end                            
                   
  # Filtro que verifica se pelo menos uma foto foi selecionada
  before_filter :selecionou_foto?, :only => [:publicar, :tirar_do_ar, :carregar_legendas]
  
  protect_from_forgery :except => [:create]
                     
  def show
    @foto = Foto.find(params[:id])
    if @foto.publicada? or (user_signed_in? and current_user.id == @foto.album.user.id)
      @style = params[:style] ? params[:style] : 'normal'
      send_file @foto.imagem.path(@style)
    else
      render :nothing => true, :status => 403
    end
  end      
              
  def create
    @album ||= Album.find(params[:album_id])
    
    @foto = Foto.new(params[:foto].merge({:album_id => @album.id}))          
                    
    @foto.imagem_content_type = mime_type @foto                
    @foto.save!
    
    render :nothing => true
  end                           
  
  def destroy
    Foto.find(params[:id]).destroy
    
    flash[:notice] = t('portaln.albuns.mensagens.fotos.removida')
    redirect_to :controller => :albuns, :action => :edit, :id => params[:album_id]
  end
                    
  def all_by_album
    @album ||= Album.find(params[:album_id])        
    @fotos = @album.fotos
    render :partial => 'fotos/lista_edicao', :layout => false 
  end
  
  def publicar
    @album ||= Album.find(params[:album_id])
    @album.recuperar_fotos(params[:fotos]).publicar!        
    if @album.novo?
      @album.publicar!
      @album.save! # forca a reindexaxao
    end
    
    flash[:notice] = t('portaln.albuns.mensagens.fotos.publicadas')
    redirect_to :controller => :albuns, :action => :edit, :id => @album.id
  end
  
  def tirar_do_ar
    @album ||= Album.find(params[:album_id])
    @album.recuperar_fotos(params[:fotos]).tirar_do_ar!        
    if @album.fotos_publicadas.length == 0 and (not @album.novo?)
      @album.tirar_do_ar! 
      @album.save! # forca a reindexaxao
    end
    
    flash[:notice] = t('portaln.albuns.mensagens.fotos.fora_do_ar')
    redirect_to :controller => :albuns, :action => :edit, :id => @album.id
  end
  
  def salvar_ordem     
    @album ||= Album.find(params[:album_id])
    imgs_ids = params[:ordem].keys.collect {|id| Integer(id)}
    
    @fotos = Foto.find(imgs_ids)     
    @fotos.each do |foto|
      ordem = params[:ordem]["#{foto.id}"]
      foto.ordem = ordem
      foto.save!
    end                                  
    
    flash[:notice] = t('portaln.albuns.mensagens.fotos.ordenadas')
    redirect_to :controller => :albuns, :action => :edit, :id => @album.id
  end
  
  def carregar_legendas
    @album ||= Album.find(params[:album_id])
    @fotos = @album.recuperar_fotos(params[:fotos])
  end                  
  
  def salvar_legendas
    @album ||= Album.find(params[:album_id])
    
    params[:fotos].each do |foto_array|
      foto = Foto.find(Integer(foto_array[0]))
      foto.fotografo = foto_array[1][:fotografo]
      foto.legenda = foto_array[1][:legenda]
      foto.save!
    end         

    flash[:notice] = t('portaln.albuns.mensagens.fotos.editar_legendas')
    redirect_to :controller => :albuns, :action => :edit, :id => @album.id
  end            
  
  private
  def selecionou_foto?
    unless fotos_enviadas? params                           
      flash[:error] = t('portaln.albuns.erros.pelo_menos_uma')
      redirect_to :controller => :albuns, :action => :edit, :id => params[:album_id]
      return
    end
  end
  
  def fotos_enviadas? params
    params[:fotos] and params[:fotos].length > 0
  end
  
  def mime_type foto
    MIME::Types.type_for(foto.imagem_file_name).to_s
  end
end