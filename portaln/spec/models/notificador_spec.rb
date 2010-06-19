require 'spec_helper'

describe Notificador do
  
  before :each do
    ActionMailer::Base.deliveries = [] 
  end

  it "deveria enviar o email de contato" do
    configuracao = Factory.create :configuracao
    mensagem = {                  
      :nome => "Tulio Ornelas",
      :email => "email@gmail.com",
      :assunto => "Novo contrato",
      :conteudo => "Um conteudo bem legal!"
    }
                                                  
    ActionMailer::Base.deliveries.size.should == 0
    email = Notificador.deliver_email_contato mensagem, configuracao
    ActionMailer::Base.deliveries.size.should == 1
                        
    email.subject.should ==  "[#{I18n.t('portaln.nome_aplicacao')}] #{mensagem[:assunto]}" 
    email.body.should =~ /#{mensagem[:assunto]}/
    email.body.should =~ /#{mensagem[:conteudo]}/
    email.body.should =~ /#{mensagem[:nome]}/
    email.body.should =~ /#{mensagem[:email]}/
  end

end