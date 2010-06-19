require 'spec_helper'

describe NoticiasController do
  include Devise::TestHelpers
  
  it "deveria carregar a listagem paginada com apenas as noticias publicadas" do
    (1...15).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo nova #{number}", :workflow_state => 'nova')
    end
    
    (1...15).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicada #{number}", :workflow_state => 'publicada')
    end
    
    get :index
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].length.should == PortalN::PAGE_SIZE
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
  end  

  it "deveria carregar a listagem paginada com o valor de pagina informado" do
    (1...15).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo nova #{number}", :workflow_state => 'nova')
    end
    
    (1...15).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicada #{number}", :workflow_state => 'publicada')
    end
    
    # Quando o valor informado eh < que PortalN::PAGE_SIZE e > que 0 ele eh aceito
    get :index, :page_size => 1
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].length.should == 1
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
                                 
    # Valor maior que PortalN::PAGE_SIZE nao eh aceito
    get :index, :page_size => 1000000000
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].length.should == PortalN::PAGE_SIZE
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end                                                   
                                                      
    # Valor < que 1 nao eh aceito
    get :index, :page_size => 0
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].length.should == PortalN::PAGE_SIZE
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
  end  
  
  it "deveria carregar qualquer status quando logado" do
    sign_in users(:test)
    
    (1..5).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo nova #{number}", :workflow_state => 'nova')
    end
    
    (1..6).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicada #{number}", :workflow_state => 'publicada')
    end
              
    # Sem informar recupera 'publicada'
    get :index
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
    
    # Informando para usuario logado, retorna a informada
    get :index, :workflow_state => 'nova'
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'nova'
    end
    
    get :index, :workflow_state => 'publicada'
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
  end
  
  it "nao deveria conseguir carregar outros status quando nao estiver logado" do
    (1..5).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo nova #{number}", :workflow_state => 'nova')
    end
    
    (1..6).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicada #{number}", :workflow_state => 'publicada')
    end
              
    # Sem informar recupera 'publicada'
    get :index
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
    
    # Informando para usuario nao logado, retorna 'publicada
    get :index, :workflow_state => 'nova'
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
  end                                          
  
  it "deveria carregar a listagem paginada filtrando pela tag" do
    tag = Factory.create :tag
    (1...15).each {|number| Factory.create(:noticia, :titulo => "Titulo #{number}", :workflow_state => 'publicada') }
    noticia = Noticia.find(:first)                                                         
    noticia.tag_list = [tag.name]
    noticia.save!
    
    get :index, :tag => tag.name
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].length.should == 1
    assigns[:noticias][0].id.should == noticia.id
  end
  
  it "deveria visualizar uma noticia pelo id" do
    noticia = Factory.create :noticia
    noticia.publicar! # Somente usuarios logados podem ver noticias novas
    
    get :show, :id => noticia.id
    response.should be_success
    response.should render_template('noticias/show.html.erb')
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id
    
    # Verificando quando o id passado for id-titulo
    noticia.to_param.should == "#{noticia.id}-#{noticia.titulo.to_url}"

    get :show, :id => noticia.to_param
    response.should be_success
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id
  end
  
  it "nao deveria permitir acesso as noticias nao publicados para usuarios nao logados" do
    noticia = Factory.create :noticia
    
    get :show, :id => noticia.id
    response.should render_template('errors/forbidden')
    assigns[:noticia].should be_nil
    
    # Verificando quando o id passado for id-titulo
    get :show, :id => noticia.to_param
    response.should render_template('errors/forbidden')
    assigns[:noticia].should be_nil
  end
  
  it "deveria carregar o formulario de cadastramento" do
    sign_in users(:test)
    get :new
    response.should be_success
    assigns[:noticia].should_not be_nil
  end                                  
  
  it "deveria carregar a noticia para edicao" do
    sign_in users(:test)
    noticia = Factory.create :noticia
    get :edit, :id => noticia.id
    response.should be_success
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id
  end                                        
  
  it "nao deveria poder carregar uma noticia de outro usuario para edicao" do
    noticia = Factory.create :noticia, :user_id => users(:test2).id
    
    sign_in users(:test)
    get :edit, :id => noticia.id
    response.should be_success                                     
    
    assigns[:noticia].should be_nil
    response.should render_template("errors/forbidden")
  end                                        
  
  it "deveria criar uma noticia" do
    sign_in users(:test)
    
    count = Noticia.count
    Noticia.should have(count).records
    
    hash = Factory.attributes_for :noticia
    post :create, :noticia => hash
    assigns[:noticia].should_not be_nil
    assigns[:noticia].user.id.should == users(:test).id
    response.should redirect_to("noticias/#{assigns[:noticia].id}/edit")
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.criada')
    
    Noticia.should have(count + 1).records
  end
  
  it "nao deveria criar uma noticia caso ocorra algum problema" do
    sign_in users(:test)
    
    count = Noticia.count
    Noticia.should have(count).records
    
    hash = Factory.attributes_for :noticia, :titulo => ''
    post :create, :noticia => hash
    response.should be_success
    response.should render_template('new')
    
    assigns[:noticia].should_not be_nil
    assigns[:noticia].should have(1).error
    
    Noticia.should have(count).records
  end
  
  it "deveria criar uma noticia com tags" do
    sign_in users(:test)
    
    count = Noticia.count
    Noticia.should have(count).records
    
    hash = Factory.attributes_for :noticia
    tag = Factory.create :tag
    
    post :create, :noticia => hash, :tags => [tag.name]
    assigns[:noticia].should_not be_nil
    assigns[:noticia].user.id.should == users(:test).id
    response.should redirect_to("noticias/#{assigns[:noticia].id}/edit")
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.criada')
                               
    assigns[:noticia].tag_list.should_not be_nil
    assigns[:noticia].tag_list[0].should == tag.name
    
    Noticia.should have(count + 1).records
  end
              
  it "deveria criar uma noticia sem resumo" do
    sign_in users(:test)
    
    count = Noticia.count
    Noticia.should have(count).records
    
    hash = Factory.attributes_for :noticia
    
    post :create, :noticia => hash, :sem_resumo => ""
    assigns[:noticia].should_not be_nil
    assigns[:noticia].user.id.should == users(:test).id
    response.should redirect_to("noticias/#{assigns[:noticia].id}/edit")
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.criada')
                               
    assigns[:noticia].resumo.should be_nil
    
    Noticia.should have(count + 1).records
  end
  
  it "deveria atualizar uma noticia" do
    sign_in users(:test)
    
    noticia = Factory.create :noticia
    
    count = Noticia.count
    Noticia.should have(count).records
    
    put :update, :id => noticia.id, :noticia => {:titulo => 'Novo titulo'}
    response.should redirect_to("noticias/#{noticia.id}/edit")
    
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id
    assigns[:noticia].titulo.should == 'Novo titulo'
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.atualizada')
    
    Noticia.should have(count).records
  end

  it "nao deveria atualizar uma noticia de outro usuario" do
    sign_in users(:test)
    
    noticia = Factory.create :noticia, :user_id => users(:test2).id
    
    count = Noticia.count
    Noticia.should have(count).records
    
    put :update, :id => noticia.id, :noticia => {:titulo => 'Novo titulo'}
    response.should render_template("errors/forbidden")
    
    assigns[:noticia].should be_nil
    Noticia.should have(count).records
  end
  
  it "deveria atualizar uma noticia marcando o sem resumo" do
    sign_in users(:test)
    
    noticia = Factory.create :noticia
    noticia.resumo.should_not be_nil # tem resumo                           
    
    count = Noticia.count
    Noticia.should have(count).records
    
    put :update, :id => noticia.id, :noticia => {:titulo => 'Novo titulo'}, :sem_resumo => ""
    response.should redirect_to("noticias/#{noticia.id}/edit")
    
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id
    
    assigns[:noticia].resumo.should be_nil
    
    assigns[:noticia].titulo.should == 'Novo titulo'
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.atualizada')
    
    Noticia.should have(count).records
  end
  
  
  it "nao deveria atualizar caso ocorra algum problema" do
    sign_in users(:test)
    noticia = Factory.create :noticia
    
    count = Noticia.count
    Noticia.should have(count).records
    
    put :update, :id => noticia.id, :noticia => {:titulo => ''}
    response.should be_success
    response.should render_template('edit')
    
    assigns[:noticia].should_not be_nil
    assigns[:noticia].should have(1).error
    
    Noticia.should have(count).records
  end
  
  it "deveria atualizar uma noticia adicionando tags" do
    sign_in users(:test)
    noticia = Factory.create :noticia
    hash = Factory.attributes_for :noticia
    
    tag = Factory.create :tag
    
    count = Noticia.count
    Noticia.should have(count).records
                                                    
    put :update, :id => noticia.id, :noticia => hash, :tags => [tag.name]
    response.should redirect_to("noticias/#{noticia.id}/edit")
    
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id
    
    assigns[:noticia].tag_list.should_not be_nil
    assigns[:noticia].tag_list[0].should == tag.name
    
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.atualizada')
    
    Noticia.should have(count).records
  end                    
  
  it "deveria atualizar uma noticia retirando tags" do
    sign_in users(:test)
    noticia = Factory.create :noticia
    hash = Factory.attributes_for :noticia
    
    noticia.tag_list = ['tag1', 'tag2']
    noticia.save.should be_true
    noticia.reload.tag_list.length.should == 2
    
    put :update, :id => noticia.id, :noticia => hash, :tags => ['tag1']    
    response.should redirect_to("noticias/#{noticia.id}/edit")
    
    assigns[:noticia].tag_list.should_not be_nil
    assigns[:noticia].tag_list[0].should == 'tag1'
    
    put :update, :id => noticia.id, :noticia => hash, :tags => nil    
    response.should redirect_to("noticias/#{noticia.id}/edit")
    
    assigns[:noticia].tag_list.should_not be_nil
    assigns[:noticia].tag_list.length.should == 0
  end
  
  
  it "deveria apagar uma noticia" do
    sign_in users(:test)
    
    noticia = Factory.create :noticia 
    
    count = Noticia.count
    Noticia.should have(count).records
    
    delete :destroy, :id => noticia.id
    response.should redirect_to(noticias_path)
    
    Noticia.should have(count - 1).records
  end

  it "nao deveria apagar uma noticia de outro usuario" do
    sign_in users(:test)
    
    noticia = Factory.create :noticia, :user_id => users(:test2).id 
    
    count = Noticia.count
    Noticia.should have(count).records
    
    delete :destroy, :id => noticia.id
    response.should render_template("errors/forbidden")
    
    Noticia.should have(count).records
  end
  
  it "deveria publicar a noticia" do
    noticia = Factory.create :noticia, :titulo => 'Noticia a ser publicada'
    noticia.nova?.should be_true
    
    sign_in users(:test)
    get :publicar, :id => noticia.id
    assigns[:msg].should == I18n.t("portaln.noticias.publicado_sucesso")
    
    noticia.reload
    noticia.publicada?.should be_true
    noticia.published_at.should_not be_nil
  end

  it "nao deveria publicar a noticia de outro usuario" do
    noticia = Factory.create :noticia, :titulo => 'Noticia a ser publicada', :user_id => users(:test2).id
    noticia.nova?.should be_true
    
    sign_in users(:test)
    get :publicar, :id => noticia.id
    response.should render_template("errors/forbidden")
    
    noticia.reload
    noticia.publicada?.should be_false
    noticia.published_at.should be_nil
  end
  
  it "nao deveria permitir mudar o estado de uma noticia ja publicada" do
    noticia = Factory.create :noticia, :titulo => 'Noticia a ser publicada', :workflow_state => 'publicada'
    noticia.publicada?.should be_true
    
    sign_in users(:test)
    get :publicar, :id => noticia.id 
    
    # Nao pode ser o texto de sucesso
    assigns[:msg].should_not == I18n.t("portaln.noticias.publicado_sucesso")
    
    noticia.reload
    noticia.publicada?.should be_true
  end
  
  it "deveria recuperar as ultimas noticias publicadas" do
    (1...15).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo nova #{number}", :workflow_state => 'nova')
    end
    
    (1...15).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicada #{number}", :workflow_state => 'publicada')
    end
    
    get :ultimas
    response.should be_success
    assigns[:noticias].should_not be_nil
    assigns[:noticias].length.should == PortalN::PAGE_SIZE
    assigns[:noticias].each do |n|
      n.workflow_state.should == 'publicada'
    end
  end
                                               
end
  



























