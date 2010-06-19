class TagsController < ApplicationController

  before_filter :authenticate_user!, :except => [:cloud_noticia]

  # GET /tags/find
  def find
    @tags ||= TagFinder.find_all_by_tag_name(params[:name])         
    render :json => @tags
  end

  # GET /tags/cloud_noticia
  def cloud_noticia
    @tags = Noticia.tag_counts
    @controller_name = :noticias
    @action_name = :index
    render :partial => 'tags/cloud'
  end
   
end