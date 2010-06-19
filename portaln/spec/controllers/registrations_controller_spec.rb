require 'spec_helper'

describe RegistrationsController do
  include Devise::TestHelpers
  
  it 'nao deveria permitir acesso a listagem sem a role de administrador' do
    sign_in users(:test) # usuario operador
    get :index
    response.should be_success
    assigns[:users].should be_nil
    response.should render_template("errors/forbidden")
  end                 
  
  it 'nao deveria permitir acesso a new sem a role de administrador' do
    sign_in users(:test) # usuario operador
    get :new
    response.should be_success
    assigns[:user].should be_nil
    response.should render_template("errors/forbidden")
  end
                 
  it 'nao deveria permitir acesso ao create sem a role de administrador' do
    sign_in users(:test) # usuario operador
    hash = Factory.attributes_for :user
    post :create, :user => hash
    response.should be_success
    assigns[:user].should be_nil
    response.should render_template("errors/forbidden")
  end                
  
  it 'deveria permitir aos administradores carregar a listagem' do
    sign_in users(:admin)
    get :index
    response.should be_true
    assigns[:users].should_not be_nil
    response.should render_template("registrations/index")
  end
  
  it 'deveria permitir aos administradores carregar a tela de cadastramento' do
    sign_in users(:admin)
    get :new
    response.should be_true
    assigns[:user].should_not be_nil
    response.should render_template("registrations/new")
  end
  
  it 'deveria permitir aos administradores criar usuarios' do
    count = User.count
    User.should have(count).records                  
    
    sign_in users(:admin)
    hash = Factory.attributes_for :user
    post :create, :user => hash
    response.should redirect_to('registrations')
    assigns[:user].should_not be_nil
    assigns[:user].id.should_not be_nil              
    response.flash[:notice].should == I18n.t("devise.registrations.signed_up")
    
    User.should have(count + 1).records
  end               
  
  it 'deveria renderizar o new em caso de falha na criacao de usuarios' do
    sign_in users(:admin)
    post :create
    response.should render_template('registrations/new')
  end   
  
  it 'deveria permitir a edicao dos dados pessoais' do
    name = users(:test).name
    
    sign_in users(:test)
    hash = Factory.attributes_for :user, :current_password => 'testtest', :password => ''
    post :update, :user => hash
    response.should redirect_to '/'     
    response.flash[:notice].should == I18n.t("devise.registrations.updated")
    
    user = User.find(users(:test).id)
    user.name.should_not == name
  end                
  
  it 'nao deveria permitir usuarios operadores alterarem o valor do role_name' do
    sign_in users(:test)                                                                 
    hash = Factory.attributes_for :user, :current_password => 'testtest', :password => '', :role_name => 'administrador'
    post :update, :user => hash
    response.should redirect_to '/'     
    response.flash[:notice].should == I18n.t("devise.registrations.updated")
    
    user = User.find(users(:test).id)
    user.role_name.should == Permissions::OPERADOR
  end             
  
  it 'deveria renderizar o edit em caso de falha na atualizacao do usuario' do
    sign_in users(:test)
    post :update, :user => {}
    response.should render_template('registrations/edit')
    assigns[:user].should_not be_nil
  end     
  
  it 'deveria carregar o edit apenas com o current_user' do
    get :edit
    response.should redirect_to('users/login?unauthenticated=true')
    
    sign_in users(:test)
    get :edit
    response.should render_template('registrations/edit')
  end
  
end                                                   

































