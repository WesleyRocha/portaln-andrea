require 'spec_helper'

describe ContatosController do
  include Devise::TestHelpers
                           
  before :each do
    ActionMailer::Base.deliveries = [] 
  end
  
  it "deveria carregar o formulario de contato recuperando a configuracao vigente" do
    configuracao = Factory.create :configuracao
    
    get :index
    response.should be_success
    response.should render_template 'contatos/index.html.erb'
    
    assigns[:configuracao].should_not be_nil
    assigns[:configuracao].id.should == configuracao.id
  end                                                  
  
  it "deveria enviar a mensagem de contato" do
    configuracao = Factory.create :configuracao
    
    mensagem = {                  
      :nome => "Tulio Ornelas",
      :email => "email@gmail.com",
      :assunto => "Novo contrato",
      :conteudo => "Um conteudo bem legal!"
    }
    
    ActionMailer::Base.deliveries.size.should == 0
    
    post :create, :mensagem => mensagem
    response.should redirect_to :controller => :contatos, :action => :index
    response.flash[:notice].should == I18n.t('portaln.contatos.mensagens.enviada')
    
    ActionMailer::Base.deliveries.size.should == 1
  end     
  
  it "nao deveria aceitar mensagens caso a configuracao nao tenha sido feita" do
    post :create
    response.should redirect_to root_path
    response.flash[:error].should == I18n.t('portaln.configuracoes.mensagens.nao_configurado')
  end                      
  
  it "nao deveria aceitar mensagens com algum campo faltando" do
    configuracao = Factory.create :configuracao
    
    post :create                                                           
    response.should render_template 'contatos/index.html.erb'
    response.flash[:error].should == I18n.t('portaln.contatos.mensagens.preencha_todos_campos')
  end
  
end






























