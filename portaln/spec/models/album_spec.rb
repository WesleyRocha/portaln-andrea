require 'spec_helper'

describe Album do

  it "deveria salvar" do
    count = Album.count
    Album.should have(count).records
    
    a = Album.new(:titulo    => 'Titulo',
                  :descricao => 'Descricao',
                  :user => users(:test))
    a.save.should be_true        
    
    Album.should have(count + 1).records
  end
  
  it "deveria validar os campos obrigatorios" do
    a = Album.new
    a.save.should be_false
    
    a.errors.should_not be_nil               
    a.should have(1).errors_on(:titulo)
    a.should have(1).errors_on(:user_id)
  end
     
  it "to_param deveria retorna id-titulo" do
    album = Factory.create :album
    album.to_param.should == "#{album.id}-#{album.titulo.to_url}"
  end 
  
  it "deveria aceitar tags" do
    album = Factory.create :album
    album.save.should be_true        
    album.tag_list.length.should == 0
    
    album.tag_list = ["tag1", "tag2", "tag3"]
    album.save.should be_true
    
    album.reload
    album.tag_list.should_not be_nil
    album.tag_list.length.should == 3
  end    
  
  it "deveria estar no estado novo quando criado" do
    album = Factory.create :album
    album.save.should be_true  
    
    album.reload
    album.novo?.should be_true
    album.workflow_state.should == "novo"
  end         
  
  it "deveria permitir publicar" do
    album = Factory.create :album
    album.save.should be_true  
    album.novo?.should be_true

    album.publicar!

    album.reload
    album.publicado?.should be_true
    album.workflow_state.should == "publicado"
  end
  
  it "deveria adicionar a data de publicacao no ato de publicar" do
    album = Factory.create :album, :titulo => 'album de teste'
    album.novo?.should be_true
    album.published_at.should be_nil                 
    
    album.publicar!                 
    album.published_at.should_not be_nil
  end
  
  it "deveria ter varias fotos" do
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0
    
    10.times {Factory.create :foto, :album_id => album.id}
    
    album.reload.fotos.length.should == 10
  end                                   
  
  it "deveria recuperar as fotos ordenadas pelo campo ordem" do
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0
    
    10.times {|n| Factory.create :foto, :album_id => album.id, :ordem => n}
    
    album.reload.fotos.length.should == 10                                
    album.fotos.each_with_index do |foto, index|
      foto.ordem.should == index
    end
  end
  
  it "deveria ter varias fotos publicadas" do
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0                                                          
    album.reload.fotos_publicadas.length.should == 0                                                          
    
    5.times {|n| Factory.create :foto, :album_id => album.id, :publicada => true}
    5.times {|n| Factory.create :foto, :album_id => album.id, :publicada => false}
    
    album.reload.fotos.length.should == 10
    album.reload.fotos_publicadas.length.should == 5                                                          
  end                                   
  
  it "deveria permitir publicar as fotos" do
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0
    5.times {Factory.create :foto, :album_id => album.id}
    
    ids = []
    5.times do
      ids << Factory.create(:foto, :album_id => album.id).id
    end
    
    album.reload.fotos.length.should == 10
    album.reload.fotos_publicadas.length.should == 0
                          
    ids.should_not be_nil
    album.recuperar_fotos(ids).publicar!  
        
    album.reload.fotos.length.should == 10    
    album.reload.fotos_publicadas.length.should == 5
  end
                           
  it "deveria recuperar_fotos com um array de ids ou um hash, assumindo a chave como id" do
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0
    ids = []
    5.times do
      ids << Factory.create(:foto, :album_id => album.id).id
    end
    album.reload.fotos.length.should == 5
    
    album.recuperar_fotos(ids).should_not be_nil
    album.recuperar_fotos(ids).length.should == 5
    
    # Transformando o array de ids em um hash de ids
    hash = {}
    ids.each {|id| hash[id] = id}
    
    album.recuperar_fotos(hash).should_not be_nil
    album.recuperar_fotos(hash).length.should == 5 
    
    # Usando strings no hash
    hash = {}
    ids.each {|id| hash["#{id}"] = "#{id}"}
    
    album.recuperar_fotos(hash).should_not be_nil
    album.recuperar_fotos(hash).length.should == 5      

    # Usando um hash do proprio rails
    hash = HashWithIndifferentAccess.new
    ids.each {|id| hash["#{id}"] = "#{id}"}
    
    album.recuperar_fotos(hash).should_not be_nil
    album.recuperar_fotos(hash).length.should == 5      
  end
  
  it "deveria apagar as fotos ao apagar o album" do
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0
    10.times {Factory.create :foto, :album_id => album.id}
    album.reload.fotos.length.should == 10
                          
    album_count = Album.count
    fotos_count = Foto.count
    
    id = album.id
    album.destroy.should be_true
    fotos = Foto.find(:all, :conditions => ["album_id = ?", id])
    fotos.should_not be_nil
    fotos.length.should == 0
    
    Album.should have(album_count - 1).records
    Foto.should have(fotos_count - 10).records
  end
  
  it "deveria ter uma capa caso exista alguma foto publicada" do
    album = Factory.create :album
    album.save.should be_true
            
    foto1 = Factory.create :foto, :album_id => album.id, :publicada => true, :created_at => Date.today
    foto2 = Factory.create :foto, :album_id => album.id, :publicada => true, :created_at => Date.today + 1.day
    
    album.reload.fotos_publicadas.should_not be_nil
    album.fotos_publicadas.length.should == 2
                                  
    # Caso as fotos nao estejam ordenadas, pega a primeira                                         
    album.capa.should_not be_nil
    album.capa.id.should == foto1.id
    
    # Em caso de ordenamento, pega a de numero 0 (zero)
    foto1.ordem = 1
    foto2.ordem = 0
    foto1.save
    foto2.save
    
    album.reload.capa.should_not be_nil
    album.capa.id.should == foto1.id
  end                            
  
  it "deveria realizar uma pesquisa paginada em qualquer status" do
    (1..10).each do |number| 
      Factory.create(:album, :titulo => "Album novo #{number}")
    end
                                    
    (1..10).each do |number| 
      Factory.create(:album, :titulo => "Album publicado #{number}", :workflow_state => 'publicado')
    end
           
    # Pesquisa pelos albuns publicados
    albuns = Album.pesquisa_paginada
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE
                               
    # Pesquisa pelos novos            
    albuns = Album.pesquisa_paginada(:workflow_state => 'novo')
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE
  end
  
  it "deveria realizar uma pesquisa paginada apenas em albuns publicados" do
    (1...10).each do |number| 
      Factory.create(:album, :titulo => "Album novo #{number}")
    end
                                    
    (1...22).each do |number| 
      Factory.create(:album, :titulo => "Album publicado #{number}", :workflow_state => 'publicado')
    end
    
    albuns = Album.pesquisa_paginada
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE
    
    albuns = Album.pesquisa_paginada(:page => 2)
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE
    
    albuns = Album.pesquisa_paginada(:page => 3)
    albuns.should_not be_nil
    albuns.length.should < PortalN::PAGE_SIZE
  end

  it "deveria poder definir o tamanho da pagina na pesquisa paginada" do
    (1...10).each do |number| 
      Factory.create(:album, :titulo => "Album novo #{number}")
    end
                                    
    (1...22).each do |number| 
      Factory.create(:album, :titulo => "Album publicado #{number}", :workflow_state => 'publicado')
    end
                                                                    
    # Sem informar utiliza PortalN::PAGE_SIZE
    albuns = Album.pesquisa_paginada
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE
                                             
    # Informando um valor < PortalN::PAGE_SIZE e > 0
    albuns = Album.pesquisa_paginada(:page_size => 1)
    albuns.should_not be_nil
    albuns.length.should == 1
                                                    
    # Valores maiores que PortalN::PAGE_SIZE retornam PortalN::PAGE_SIZE
    albuns = Album.pesquisa_paginada(:page_size => 100000)
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE              
                                                                        
    # Valores < 1 retornam PortalN::PAGE_SIZE
    albuns = Album.pesquisa_paginada(:page_size => 0)
    albuns.should_not be_nil
    albuns.length.should == PortalN::PAGE_SIZE              
  end
  
  
  it "deveria realizar uma pesquisa paginada pela tag" do
    n1 = Factory.create :album, :titulo => 'Titulo tag 1'
    n1.tag_list = ['tag1'] 
    n1.save!
    
    n2 = Factory.create :album, :titulo => 'Titulo tag 2'
    n2.tag_list = ['tag2'] 
    n2.save!
    
    n3 = Factory.create :album, :titulo => 'Titulo tag 3', :workflow_state => 'publicado'
    n3.tag_list = ['tag3'] 
    n3.save!
                        
    albuns = Album.pesquisa_paginada({
      :workflow_state => 'novo',
      :tag => 'tag1'
    })         
    albuns.should_not be_nil
    albuns.length.should > 0
    albuns[0].id.should == n1.id
    
    albuns = Album.pesquisa_paginada({
      :workflow_state => 'novo',
      :tag => 'tag2'
    })         
    albuns.should_not be_nil
    albuns.length.should > 0
    albuns[0].id.should == n2.id
    
    albuns = Album.pesquisa_paginada({
      :tag => 'tag3'
    })         
    albuns.should_not be_nil
    albuns.length.should > 0
    albuns[0].id.should == n3.id
                               
    albuns = Album.pesquisa_paginada({
      :tag => 'tag_desconhecida'
    })         
    albuns.should_not be_nil
    albuns.length.should == 0
  end
  
end               






























