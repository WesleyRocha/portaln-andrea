require 'spec_helper'

describe AlbunsController do
  include Devise::TestHelpers
  
  it "deveria visualizar um album pelo id" do
    album = Factory.create :album                        
    album.publicar! # sem estar logado so eh possivel ver albuns publicados
                             
    5.times {Factory.create :foto, :album_id => album.id, :publicada => true}
    5.times {Factory.create :foto, :album_id => album.id, :publicada => false}
    
    get :show, :id => album.id
    response.should be_success
    response.should render_template('albuns/show.html.erb')
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    assigns[:fotos].should_not be_nil
    assigns[:fotos].length.should == assigns[:album].fotos_publicadas.length
    assigns[:fotos].each {|f| f.publicada?.should be_true}
    
    # Verificando quando o id passado for id-titulo
    album.to_param.should == "#{album.id}-#{album.titulo.to_url}"

    get :show, :id => album.to_param
    response.should be_success
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    assigns[:fotos].should_not be_nil
    assigns[:fotos].length.should == assigns[:album].fotos_publicadas.length    
    assigns[:fotos].each {|f| f.publicada?.should be_true}
  end                                                                      
  
  it "nao deveria permitir acesso aos albuns nao publicados para usuarios nao logados"  do
    album = Factory.create :album # nao publicado                       
    
    get :show, :id => album.id
    response.should render_template('errors/forbidden')
    
    assigns[:album].should be_nil
    assigns[:fotos].should be_nil
    
    # Verificando quando o id passado for id-titulo
    get :show, :id => album.to_param
    response.should render_template('errors/forbidden')
    
    assigns[:album].should be_nil
    assigns[:fotos].should be_nil
  end
  
  it "deveria carregar o formulario de cadastramento" do
    sign_in users(:test)
    get :new
    response.should be_success
    assigns[:album].should_not be_nil
  end                                  
  
  it "deveria carregar o album para edicao" do
    sign_in users(:test)
    album = Factory.create :album
    get :edit, :id => album.id
    response.should be_success     
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    assigns[:fotos].should_not be_nil
    assigns[:fotos].length.should == assigns[:album].fotos.length
  end
         
  it "nao deveria poder carregar o album de outro usuario para edicao" do
    album = Factory.create :album, :user_id => users(:test2).id
    
    sign_in users(:test)
    get :edit, :id => album.id
    response.should be_success                                     
    
    assigns[:album].should be_nil
    response.should render_template("errors/forbidden")
  end     
  
  it "deveria criar um album" do
    sign_in users(:test)
    
    count = Album.count
    Album.should have(count).records
    
    hash = Factory.attributes_for :album
    post :create, :album => hash
    assigns[:album].should_not be_nil
    assigns[:album].user.id.should == users(:test).id
    response.should redirect_to("albuns/#{assigns[:album].id}/edit")
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.criado')
    
    Album.should have(count + 1).records
  end      
  
  it "nao deveria criar um album caso ocorra algum problema" do
    sign_in users(:test)
    
    count = Album.count
    Album.should have(count).records
    
    hash = Factory.attributes_for :album, :titulo => ''
    post :create, :album => hash
    response.should be_success
    response.should render_template('new')
    
    assigns[:album].should_not be_nil
    assigns[:album].should have(1).error
    
    Album.should have(count).records
  end    
  
  it "deveria criar um album com tags" do
    sign_in users(:test)
    
    count = Album.count
    Album.should have(count).records
    
    hash = Factory.attributes_for :album
    tag = Factory.create :tag
    
    post :create, :album => hash, :tags => [tag.name]
    assigns[:album].should_not be_nil
    assigns[:album].user.id.should == users(:test).id
    response.should redirect_to("albuns/#{assigns[:album].id}/edit")
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.criado')
                               
    assigns[:album].tag_list.should_not be_nil
    assigns[:album].tag_list[0].should == tag.name
    
    Album.should have(count + 1).records
  end
  
  it "deveria atualizar um album" do
    sign_in users(:test)
    
    album = Factory.create :album
    
    count = Album.count
    Album.should have(count).records
    
    put :update, :id => album.id, :album => {:titulo => 'Novo titulo'}
    response.should redirect_to("albuns/#{album.id}/edit")
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    assigns[:album].titulo.should == 'Novo titulo'
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.atualizado')
    
    Album.should have(count).records
  end   
  
  it "nao deveria atualizar o album de outro usuario" do
    sign_in users(:test)
    
    album = Factory.create :album, :user_id => users(:test2).id
    
    count = Album.count
    Album.should have(count).records
    
    put :update, :id => album.id, :album => {:titulo => 'Novo titulo'}
    response.should render_template("errors/forbidden")
    
    assigns[:album].should be_nil
    Album.should have(count).records
  end    
  
  it "nao deveria atualizar caso ocorra algum problema" do
    sign_in users(:test)
    album = Factory.create :album
    
    count = Album.count
    Album.should have(count).records
    
    put :update, :id => album.id, :album => {:titulo => ''}
    response.should be_success
    response.should render_template('edit')
    
    assigns[:album].should_not be_nil
    assigns[:album].should have(1).error
    
    Album.should have(count).records
  end    
  
  it "deveria atualizar um album adicionando tags" do
    sign_in users(:test)
    album = Factory.create :album
    hash = Factory.attributes_for :album
    
    tag = Factory.create :tag
    
    count = Album.count
    Album.should have(count).records
                                                    
    put :update, :id => album.id, :album => hash, :tags => [tag.name]
    response.should redirect_to("albuns/#{album.id}/edit")
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    
    assigns[:album].tag_list.should_not be_nil
    assigns[:album].tag_list[0].should == tag.name
    
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.atualizado')
    
    Album.should have(count).records
  end                                  
  
  it "deveria atualizar um album retirando tags" do
    sign_in users(:test)
    album = Factory.create :album
    hash = Factory.attributes_for :album
    
    album.tag_list = ['tag1', 'tag2']
    album.save.should be_true
    album.reload.tag_list.length.should == 2
    
    put :update, :id => album.id, :album => hash, :tags => ['tag1']    
    response.should redirect_to("albuns/#{album.id}/edit")
    
    assigns[:album].tag_list.should_not be_nil
    assigns[:album].tag_list[0].should == 'tag1'
    
    put :update, :id => album.id, :album => hash, :tags => nil    
    response.should redirect_to("albuns/#{album.id}/edit")
    
    assigns[:album].tag_list.should_not be_nil
    assigns[:album].tag_list.length.should == 0
  end
  
  it "deveria apagar um album" do
    sign_in users(:test)
    
    album = Factory.create :album 
    
    count = Album.count
    Album.should have(count).records
    
    delete :destroy, :id => album.id
    response.should redirect_to(albuns_path)
    
    Album.should have(count - 1).records
  end
  
  it "nao deveria apagar um album de outro usuario" do
    sign_in users(:test)
    
    album = Factory.create :album, :user_id => users(:test2).id 
    
    count = Album.count
    Album.should have(count).records
    
    delete :destroy, :id => album.id
    response.should render_template("errors/forbidden")
    
    Album.should have(count).records
  end
  
  it "deveria apagar as fotos ao apagar o album" do
    sign_in users(:test)
    
    album = Factory.create :album
    album.save.should be_true
                         
    album.reload.fotos.length.should == 0
    10.times {Factory.create :foto, :album_id => album.id}
    album.reload.fotos.length.should == 10
                          
    album_count = Album.count
    fotos_count = Foto.count
                             
    id = album.id
    
    delete :destroy, :id => id
    response.should redirect_to(albuns_path)

    fotos = Foto.find(:all, :conditions => ["album_id = ?", id])
    fotos.should_not be_nil
    fotos.length.should == 0
    
    Album.should have(album_count - 1).records
    Foto.should have(fotos_count - 10).records
  end          
  
  it "deveria carregar a listagem paginada com apenas os albuns publicados" do
    (1...15).each do |number| 
      Factory.create(:album, :titulo => "Titulo novo #{number}", :workflow_state => 'novo')
    end
    
    (1...15).each do |number| 
      Factory.create(:album, :titulo => "Titulo publicado #{number}", :workflow_state => 'publicado')
    end
    
    get :index
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].length.should == PortalN::PAGE_SIZE
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
  end  

  it "deveria carregar a listagem paginada com o valor de pagina informado" do
    (1...15).each do |number| 
      Factory.create(:album, :titulo => "Titulo novo #{number}", :workflow_state => 'novo')
    end
    
    (1...15).each do |number| 
      Factory.create(:album, :titulo => "Titulo publicado #{number}", :workflow_state => 'publicado')
    end
    
    # Quando o valor informado eh < que PortalN::PAGE_SIZE e > que 0 ele eh aceito
    get :index, :page_size => 1
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].length.should == 1
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
                                 
    # Valor maior que PortalN::PAGE_SIZE nao eh aceito
    get :index, :page_size => 1000000000
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].length.should == PortalN::PAGE_SIZE
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end                                                   
                                                      
    # Valor < que 1 nao eh aceito
    get :index, :page_size => 0
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].length.should == PortalN::PAGE_SIZE
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
  end  
  
  it "deveria carregar qualquer status quando logado" do
    sign_in users(:test)
    
    (1..5).each do |number| 
      Factory.create(:album, :titulo => "Titulo novo #{number}", :workflow_state => 'novo')
    end
    
    (1..6).each do |number| 
      Factory.create(:album, :titulo => "Titulo publicado #{number}", :workflow_state => 'publicado')
    end
              
    # Sem informar recupera 'publicado'
    get :index
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
    
    # Informando para usuario logado, retorna a informada
    get :index, :workflow_state => 'novo'
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'novo'
    end
    
    get :index, :workflow_state => 'publicado'
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
  end
  
  it "nao deveria conseguir carregar outros status quando nao estiver logado" do
    (1..5).each do |number| 
      Factory.create(:album, :titulo => "Titulo novo #{number}", :workflow_state => 'novo')
    end
    
    (1..6).each do |number| 
      Factory.create(:album, :titulo => "Titulo publicado #{number}", :workflow_state => 'publicado')
    end
              
    # Sem informar recupera 'publicada'
    get :index
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
    
    # Informando para usuario nao logado, retorna 'publicado'
    get :index, :workflow_state => 'novo'
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].each do |n|
      n.workflow_state.should == 'publicado'
    end
  end                                          
  
  it "deveria carregar a listagem paginada filtrando pela tag" do
    tag = Factory.create :tag
    (1...15).each {|number| Factory.create(:album, :titulo => "Titulo #{number}", :workflow_state => 'publicado') }
    album = Album.find(:first)                                                         
    album.tag_list = [tag.name]
    album.save!
    
    get :index, :tag => tag.name
    response.should be_success
    assigns[:albuns].should_not be_nil
    assigns[:albuns].length.should == 1
    assigns[:albuns][0].id.should == album.id
  end
  
                        
end   



























