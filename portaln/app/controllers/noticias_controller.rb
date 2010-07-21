class NoticiasController < ApplicationController
  
  # ====================================================================================================================
  # Filtros  
  # ====================================================================================================================
  
  before_filter :authenticate_user!, :except => [:index, :show, :ultimas]
                           
  # Filtro que verifica se o usuario pode editar a noticia selecionada
  before_filter :only => [:edit, :update, :publicar, :destroy] do |controller|
    @noticia = Noticia.find(controller.params[:id])
    # Lanca Aegis::PermissionError caso nao possa
    controller.current_user.may_editar_noticia! @noticia
  end    
                              
  # Filtro que verifica se o usuario pode ver a noticia selecionada
  before_filter :only => [:show] do |controller|
    @noticia = Noticia.find(controller.params[:id])
    raise Aegis::PermissionError if (not controller.user_signed_in?) and @noticia.nova?
  end
  
  before_filter :only => [:new, :create] do |controller|
    controller.current_user.may_criar_noticia!
  end
           
  # ====================================================================================================================
  # Metodos de action
  # ====================================================================================================================

  def index                                                     
    if user_signed_in?
      @noticias = pesquisa_paginada(Noticia, 'publicada', params, current_user.may_criar_noticia?)
    else                                                                                          
      @noticias = pesquisa_paginada(Noticia, 'publicada', params)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.atom { render :template => 'noticias/index.atom.builder', :layout => false }
    end
  end
  
  def ultimas
    @noticias = pesquisa_paginada(Noticia, 'publicada', params)
    
    respond_to do |format|
      format.html { render :partial => 'noticias/ultimas_content' }
      format.atom { render :template => 'noticias/index.atom.builder', :layout => false }
    end
  end
    
  def publicar
    begin
      if params[:id] and user_signed_in?
        @noticia ||= Noticia.find(params[:id])
        @noticia.publicar!
        @noticia.save! # chamando o metodo de save novamente para disparar o job que ira reindexar o conteudo
        @msg = t("portaln.noticias.publicado_sucesso")
      end
    rescue Workflow::NoTransitionAllowed => e
      @msg = e
    end
    render :partial => 'noticias/resultado_publicar'
  end

  def show
    @noticia ||= Noticia.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @noticia }
    end
  end

  def new
    @noticia = Noticia.new
  end

  def edit
    @noticia ||= Noticia.find(params[:id])
    @anexos = @noticia.anexos
  end

  def create
    @noticia = Noticia.new(params[:noticia])
    @noticia.user = current_user
    
    if params[:tags]                                      
      # downcase para que nao ocorra internet e Internet
      @noticia.tag_list = params[:tags].join(',').downcase
    end
    
    if params[:sem_resumo]
      @noticia.resumo = nil
    end
    
    @noticia.save!
    
    flash[:notice] = t('portaln.noticias.mensagens.criada')
    redirect_to(:action => :edit, :id => @noticia.id)  
    
  rescue => e
    render :action => "new"
  end

  def update
    @noticia ||= Noticia.find(params[:id])
    @noticia.update_attributes!(params[:noticia])

    # Atualizando tags
    if params[:tags]    
      # downcase para que nao ocorra internet e Internet
      @noticia.tag_list = params[:tags].join(',').downcase
    else                                                  
      @noticia.tag_list = nil
    end
    
    if params[:sem_resumo]
      @noticia.resumo = nil
    end
    
    @noticia.save!
                    
    flash[:notice] = t('portaln.noticias.mensagens.atualizada')
    redirect_to(:action => :edit, :id => @noticia.id)  
    
  rescue => e
    flash.now[:error] = e.message         
    render :action => "edit"
  end

  def destroy
    @noticia ||= Noticia.find(params[:id])
    @noticia.destroy
    redirect_to(noticias_url)
  end
  
end
           
























