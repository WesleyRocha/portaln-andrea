set :environment, Rails.env

# Tarefa para reindexar o conteudo novo (sphinx)
if Rails.env =~ /development/
  
  puts "Agendando tarefa em modo desenvolvimento (a cada 1 min)"
  every 1.minute do
    rake 'ts:reindex'
    #rake "-s sitemap:refresh"
  end
  
else
  
  # 1.day, :at => '23:00 pm'
  every :midnight do
    rake 'ts:reindex'
    rake "-s sitemap:refresh"
  end
  
  every :reboot do
    rake 'ts:reindex'
    rake "-s sitemap:refresh"
  end
  
end