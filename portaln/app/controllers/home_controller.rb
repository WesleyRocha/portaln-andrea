class HomeController < ApplicationController
  def index
   @album = Album.find(
    :first,
    :conditions => ["workflow_state = ?", "publicado"],
    :order => "published_at desc"
   )        
   @fotos = @album.fotos_publicadas if @album
  end
end