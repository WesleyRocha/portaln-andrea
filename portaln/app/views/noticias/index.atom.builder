atom_feed do |feed|
  
  if @tag
    feed.title("#{t('portaln.nome_aplicacao')} | #{t("portaln.noticias.listagem")} #{t('portaln.noticias.tag.sobre')} #{@tag}")
  else                                                                                     
    feed.title("#{t('portaln.nome_aplicacao')} | #{t('portaln.noticias.ultimas')}")
  end
  
  if @noticias and (not @noticias.empty?)
  
    feed.updated(@noticias.first.published_at)

    @noticias.each do |noticia|
      feed.entry(noticia) do |entry|
        entry.title(noticia.titulo)
        entry.content(noticia.resumo, :type => 'html')
        entry.updated(noticia.published_at.strftime("%Y-%m-%dT%H:%M:%SZ"))                                   
    
        entry.author do |author|
          author.name(noticia.user.username)
        end
      end
    end
    
  end

end