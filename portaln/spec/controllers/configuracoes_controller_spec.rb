require 'spec_helper'

describe ConfiguracoesController do
  include Devise::TestHelpers
                      
  it "deveria carregar uma nova configuracao caso nenhuma exista" do
    sign_in users(:admin)
    get :index
    response.should be_success
    response.should render_template 'configuracoes/index.html.erb'
    
    assigns[:configuracao].should_not be_nil
    assigns[:configuracao].id.should be_nil
  end
  
  it "deveria carregar a configuracao existente" do
    c = Factory.build :configuracao
    c.save.should be_true
                                            
    Configuracao.find(:first).should_not be_nil
    
    sign_in users(:admin)
    get :index
    response.should be_success
    response.should render_template 'configuracoes/index.html.erb'
    
    assigns[:configuracao].should_not be_nil
    assigns[:configuracao].id.should == c.id
  end
  
  it "nao deveria permitir que pessoas nao autorizadas carreguem o formulario" do
    sign_in users(:test) # nao tem permissao de administracao
    get :index
    response.should render_template 'errors/forbidden'
    assigns[:configuracao].should be_nil
  end       
  
  it "nao deveria permitir que usuarios nao autenticados acessem o formulario" do
    get :index
    response.should redirect_to '/users/login?unauthenticated=true'
    assigns[:configuracao].should be_nil
  end    
  
  it "deveria salvar a configuracao caso o id nao seja informado" do      
    sign_in users(:admin)
    
    count = Configuracao.count
    
    hash = Factory.attributes_for :configuracao   
    post :update, :configuracao => hash
    response.should redirect_to '/configuracoes'
    
    response.flash[:notice].should == I18n.t('portaln.configuracoes.mensagens.salva')
    assigns[:configuracao].should_not be_nil
    assigns[:configuracao].id.should_not be_nil
    
    Configuracao.should have(count + 1).records
  end                                 
  
  it "deveria atualizar a configuracao caso o id seja informado" do
    c = Factory.build :configuracao
    c.save.should be_true
    
    sign_in users(:admin)
    count = Configuracao.count
                                  
    hash = Factory.attributes_for :configuracao   
    post :update, :configuracao => hash.merge(:id => c.id.to_s)
    response.should redirect_to '/configuracoes'
    
    response.flash[:notice].should == I18n.t('portaln.configuracoes.mensagens.salva')
    assigns[:configuracao].should_not be_nil
    assigns[:configuracao].id.should_not be_nil
    
    Configuracao.should have(count).records
  end                                                         
  
  it "deveria renderizar o index caso ocorra algum erro de validacao" do
    sign_in users(:admin)
    post :update, :configuracao => {}
    response.should render_template 'configuracoes/index.html.erb'
  end
  
end  



























