module PortalN                                            
  # Quantidade padrao de registros por pagina no sistema
  PAGE_SIZE = 10                                        
                          
  Paperclip.options[:command_path] = "/opt/local/bin"#"/usr/bin/" #"/opt/local/bin"
  
  # Path do diretorio que armazena a estrutura das fotos da galeria de imagens
  # padrao: /public/system
  IMAGENS_PATH = File.join(Rails.root, 'public', 'system')
  ANEXOS_PATH = File.join(Rails.root, 'public', 'system')
  
  HOST = 'http://localhost:3000'
  
  SITEMAP_BATCH_SIZE = 150
end                    