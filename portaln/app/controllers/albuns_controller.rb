class AlbunsController < ApplicationController
                              
  before_filter :authenticate_user!, :except => [:index, :show]
                                                                   
  # Filtro que verifica se o usuario pode editar o album selecionado
  before_filter :only => [:edit, :update, :destroy] do |controller|
    @album = Album.find(controller.params[:id])
    # Lanca Aegis::PermissionError caso nao possa
    controller.current_user.may_editar_album! @album
  end                      
              
  # Filtro que verifica se o usuario pode ver o album selecionado
  before_filter :only => [:show] do |controller|
    @album = Album.find(controller.params[:id])
    raise Aegis::PermissionError if (not controller.user_signed_in?) and @album.novo?
  end
  
  def index           
    @albuns = pesquisa_paginada(Album, 'publicado', params)
  end                  
  
  def new
    @album = Album.new
  end
  
  def create
    @album = Album.new(params[:album])
    @album.user = current_user
    
    if params[:tags]                                      
      # downcase para que nao ocorra internet e Internet
      @album.tag_list = params[:tags].join(',').downcase
    end
    
    @album.save!
    
    flash[:notice] = t('portaln.albuns.mensagens.criado')
    redirect_to(:action => :edit, :id => @album.id)  
    
  rescue => e
    render :action => "new"
  end     
         
  def show
    @album ||= Album.find(params[:id])
    @fotos = @album.fotos_publicadas

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def edit
    @album ||= Album.find(params[:id])
    @fotos = @album.fotos
  end               
  
  def update
    @album ||= Album.find(params[:id])
    @album.update_attributes!(params[:album])

    # Atualizando tags
    if params[:tags]    
      # downcase para que nao ocorra internet e Internet
      @album.tag_list = params[:tags].join(',').downcase
    else             
      @album.tag_list = nil
    end
    
    @album.save!
                    
    flash[:notice] = t('portaln.albuns.mensagens.atualizado')
    redirect_to(:action => :edit, :id => @album.id)  
    
  rescue => e
    flash.now[:error] = e.message    

    @fotos = @album.fotos     
    render :action => "edit"
  end  
  
  def destroy
    Album.find(params[:id]).destroy
    redirect_to(albuns_url)
  end
    
end
