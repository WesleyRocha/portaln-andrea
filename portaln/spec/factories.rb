module FactoriesBuilder
  
  def self.load
                    
    #==================================================================================
    # Sequences
    #==================================================================================
                                                                                       
    Factory.sequence :email do |n|
      "test_email#{n}@gmail.com"
    end

    Factory.sequence :titulo do |n|
      "Título #{n}"
    end
    
    #==================================================================================
    # Factories
    #==================================================================================
    
    Factory.define :noticia do |n|
      n.titulo Factory.next :titulo
      n.resumo 'Resumo'
      n.conteudo 'Conteúdo'
      n.user_id 1
    end

    Factory.define :tag do |t|
      t.name 'tag'
    end          
    
    Factory.define :user do |u|
      u.email Factory.next :email
      u.password "testtest"
      u.username "test_user_#{rand(1024)}"
      u.name "Test #{rand(1024)}"
      u.role_name 'operador'
    end
         
    Factory.define :album do |a|
      a.titulo Factory.next :titulo
      a.descricao "Descrição do álbum!"
      a.user_id 1
    end                
    
    Factory.define :foto do |f|
      f.legenda "Descrição da foto"
      f.fotografo "Fotografo da Silva"
      f.publicada false
      f.imagem File.open(imagem_test_path)
    end
                                          
    Factory.define :configuracao do |c|
      c.contato "Um texto de contato"
      c.quem_alterou_id 3 #admin
      c.email Factory.next :email
    end
    
  end
  
end