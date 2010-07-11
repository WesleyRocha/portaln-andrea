class HomeController < ApplicationController
  def index
   @album = Album.find(
    :last,
    :conditions => ["workflow_state = ?", "publicado"]
   )        
   @fotos = @album.fotos_publicadas if @album
  end
end