class Permissions < Aegis::Permissions
                 
  OPERADOR = 'operador'
  ADMINISTRADOR = 'administrador'                  
  
  ROLES = [
    [:operador,      OPERADOR     ], 
    [:administrador, ADMINISTRADOR]
  ]

  role :convidado, :default_permission => :allow
  role :operador
  role :administrador
                  
  permission :criar_noticia do
    allow :operador, :administrador
    deny :convidado
  end                
                  
  permission :editar_noticia do |current_user, noticia|
    allow :operador, :administrador do               
      # Um usuario somente podera editar suas noticias
      noticia.autor.id == current_user.id  
    end
    deny :convidado
  end

  permission :criar_usuarios do
    allow :administrador   
    deny :operador, :convidado
  end   
  
  permission :criar_album do
    allow :operador, :administrador
    deny :convidado
  end                
  
  permission :editar_album do |current_user, album|
    allow :operador, :administrador do               
      # Um usuario somente podera editar seus albuns
      album.autor.id == current_user.id  
    end
    deny :convidado
  end
  
  permission :configurar_sistema do
    allow :administrador
    deny :operador, :convidado
  end

end
