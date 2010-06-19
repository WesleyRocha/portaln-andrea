require 'spec_helper'

describe Configuracao do

  it "deveria salvar" do
    count = Configuracao.count
    Configuracao.should have(count).records
    
    c = Configuracao.new(:email         => 'email@email.com',
                         :quem_alterou  => users(:test),
                         :contato       => 'um testo qualquer')
    c.save.should be_true        
    
    Configuracao.should have(count + 1).records
  end
  
  it "deveria validar os campos obrigatorios" do
    c = Configuracao.new
    c.save.should be_false
    
    c.errors.should_not be_nil               
    c.should have(1).errors_on(:email)
    c.should have(1).errors_on(:quem_alterou_id)
  end
  
end