require 'spec_helper'

describe AnexosController do
  include Devise::TestHelpers
   
  it "deveria salvar um anexo para uma noticia" do
    sign_in users(:test)

    count = Anexo.count

    noticia = Factory.create :noticia, :user_id => users(:test).id
    hash = Factory.attributes_for :anexo
    
    post :create, :noticia_id => noticia.id, :anexo => hash
    response.should be_success
    
    Anexo.should have(count + 1).records
    assigns[:anexo].should_not be_nil
    assigns[:anexo].noticia_id.should == noticia.id
    assigns[:noticia].should_not be_nil
    assigns[:noticia].id.should == noticia.id                  
  end
   
  it "nao deveria salvar um anexo para uma noticia que nao eh do usuario" do
    sign_in users(:test2)

    count = Anexo.count

    noticia = Factory.create :noticia, :user_id => users(:test).id
    hash = Factory.attributes_for :anexo
    
    post :create, :noticia_id => noticia.id, :anexo => hash
    response.should render_template("errors/forbidden")
    
    Anexo.should have(count).records
    assigns[:anexo].should be_nil
    assigns[:noticia].should be_nil
  end
  
  it "nao deveria aceitar salvar o anexo sem usuario logado" do
    count = Anexo.count

    noticia = Factory.create :noticia, :user_id => users(:test).id
    hash = Factory.attributes_for :anexo
    
    post :create, :noticia_id => noticia.id, :anexo => hash
    response.should redirect_to('/users/login?unauthenticated=true')
    
    Anexo.should have(count).records
    assigns[:anexo].should be_nil
    assigns[:noticia].should be_nil
  end               
  
  it "deveria carregar todos os anexos de uma noticia especifica" do
    sign_in users(:test)

    noticia = Factory.create :noticia, :user_id => users(:test).id
    5.times {Factory.create :anexo, :noticia_id => noticia.id}                                   
                                            
    noticia2 = Factory.create :noticia, :titulo => 'noticia2', :user_id => users(:test).id
    2.times {Factory.create :anexo, :noticia_id => noticia2.id}                                   
    
    get :all_by_noticia, :noticia_id => noticia.id
    response.should render_template('anexos/_lista_edicao')
    
    assigns[:noticia].should_not be_nil
    assigns[:anexos].should_not be_nil                 
    assigns[:noticia].id.should == noticia.id
    assigns[:anexos].length.should == 5
    assigns[:anexos].each {|a| a.noticia_id.should == noticia.id}
  end
  
  it "nao deveria permitir carregar os anexos de uma noticia de outro usuario" do
    sign_in users(:test)

    noticia = Factory.create :noticia, :user_id => users(:test2).id
    5.times {Factory.create :anexo, :noticia_id => noticia.id}
    
    get :all_by_noticia, :noticia_id => noticia.id
    response.should render_template("errors/forbidden")
    
    assigns[:noticia].should be_nil
    assigns[:anexos].should be_nil                 
  end  
  
  it "deveria carregar o anexo pelo metodo de controller" do
    sign_in users(:test)

    noticia = Factory.create :noticia, :user_id => users(:test).id
    noticia.publicar!.should be_true
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    
    get :download, :id => anexo.id
    response.should be_success
    
    assigns[:anexo].should_not be_nil
    assigns[:anexo].id.should == anexo.id
    assigns[:style].should == 'original'
  end
  
  it "deveria carregar anexo de noticia nao publicada apenas para o dono" do
    sign_in users(:test)

    noticia = Factory.create :noticia, :user_id => users(:test).id
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    
    get :download, :id => anexo.id               
    response.should be_success
    
    assigns[:anexo].should_not be_nil
    assigns[:anexo].id.should == anexo.id
    assigns[:style].should == 'original'
  end              
  
  it "nao deveria permitir carregar anexos de noticias nao publicadas por outros usuarios logados" do
    sign_in users(:test2)

    noticia = Factory.create :noticia, :user_id => users(:test).id
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    
    get :download, :id => anexo.id
    response.should_not be_success     
    response.status.should == "403 Forbidden"
  end                                                                        
                               
  it "nao deveria permitir carregar anexos de noticias nao publicadas por usuarios nao logados" do
    noticia = Factory.create :noticia, :user_id => users(:test).id
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    
    get :download, :id => anexo.id
    response.should_not be_success
    response.status.should == "403 Forbidden"
  end
  
  it "deveria permitir que usuarios nao autenticados acessem os anexos de noticias publicadas" do
    noticia = Factory.create :noticia, :user_id => users(:test).id
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    noticia.publicar!.should be_true
    
    get :download, :id => anexo.id               
    response.should be_success
    
    assigns[:anexo].should_not be_nil
    assigns[:anexo].id.should == anexo.id
    assigns[:style].should == 'original'
  end
  
  it "deveria apagar um anexo" do
    sign_in users(:test)

    noticia = Factory.create :noticia, :user_id => users(:test).id
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    
    noticia.reload.anexos.length.should == 1
    delete :destroy, :id => anexo.id, :noticia_id => noticia.id
    response.should redirect_to "/noticias/#{noticia.id}/edit"
                              
    response.flash[:notice].should == I18n.t('portaln.noticias.mensagens.anexo.removido')
    noticia.reload.anexos.length.should == 0
  end                                                     
  
  it "nao deveria permitir apagar um anexo da noticia de outra pessoa" do
    sign_in users(:test2)

    noticia = Factory.create :noticia, :user_id => users(:test).id
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    
    noticia.reload.anexos.length.should == 1
    delete :destroy, :id => anexo.id, :noticia_id => noticia.id
    response.should render_template("errors/forbidden")
                              
    assigns[:noticia].should be_nil
    noticia.reload.anexos.length.should == 1
  end     
  
end