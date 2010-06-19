class PesquisaController < ApplicationController
  
  def index       
    
    if params[:query].nil? or params[:query].empty?
      flash[:error] = I18n.t("portaln.pesquisa.query_vazia")
      redirect_to root_path
      return
    end
    
    @query = params[:query]
    @objetos = ThinkingSphinx.search(@query, 
                                   :classes => [Noticia, Album],
                                   :page => params[:page], 
                                   :per_page => PortalN::PAGE_SIZE, 
                                   :with => {
                                     :published => true
                                   },              
                                   :star => true,
                                   #:order => :published_at,
                                   #:sort_mode => :desc,
                                   :match_mode => :any
    )
  end
  
end