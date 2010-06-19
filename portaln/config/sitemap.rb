# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = PortalN::HOST

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add path, options
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host

  # Noticias =============================================================================================================
  sitemap.add noticias_path, :changefreq => 'daily'
  
  Noticia.find_in_batches(
    :conditions => ["workflow_state = ?", 'publicada'], 
    :batch_size => PortalN::SITEMAP_BATCH_SIZE
  ) do |noticias|
    
    noticias.each do |noticia|
      sitemap.add noticia_path(noticia), :lastmod => noticia.updated_at
    end
    
  end

  # Album ================================================================================================================
  sitemap.add albuns_path, :changefreq => 'daily'
  
  Album.find_in_batches(
    :conditions => ["workflow_state = ?", 'publicado'], 
    :batch_size => PortalN::SITEMAP_BATCH_SIZE
  ) do |albuns|
    
    albuns.each do |album|
      sitemap.add album_path(album), 
        :lastmod => album.updated_at,
        :images => album.fotos_publicadas.collect {|foto| {:loc => foto.imagem.url(:normal), :title => foto.legenda}}
    end
    
  end
  
  # Rotas gerais =========================================================================================================
  sitemap.add pesquisar_path
  sitemap.add noticias_ultimas_feeds_path
  sitemap.add noticias_ultimas_path
  sitemap.add tagcloud_noticias_path
  
  # Pesquisa com tags
  Noticia.tag_counts.each do |tag|
    sitemap.add noticias_tag_feeds_path(:tag => tag.name)
  end
  
end

# Including Sitemaps from Rails Engines.
#
# These Sitemaps should be almost identical to a regular Sitemap file except
# they needn't define their own SitemapGenerator::Sitemap.default_host since
# they will undoubtedly share the host name of the application they belong to.
#
# As an example, say we have a Rails Engine in vendor/plugins/cadability_client
# We can include its Sitemap here as follows:
#
# file = File.join(Rails.root, 'vendor/plugins/cadability_client/config/sitemap.rb')
# eval(open(file).read, binding, file)