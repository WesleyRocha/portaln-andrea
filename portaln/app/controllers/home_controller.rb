class HomeController < ApplicationController
  def index
    @gerais = Noticia.pesquisa_paginada({
      :page_size => 5,
      :tag => 'geral'
    })    
    
    @saude = Noticia.pesquisa_paginada({
      :page_size => 5,
      :tag => 'saúde'
    })
    
    @tecnologia = Noticia.pesquisa_paginada({
      :page_size => 5,
      :tag => 'tecnologia'
    })
  end
end