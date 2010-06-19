rake ts:stop
echo "Inicializando o Sphinx e reindexando conteudo"
rake ts:start && rake ts:reindex           
echo "Inicializando o delayed_delta"
rake ts:dd &        
echo "Inicializando o whenever (cron)"
whenever --update-crontab PortalN &
echo "Subindo a aplicacao"
ruby script/server