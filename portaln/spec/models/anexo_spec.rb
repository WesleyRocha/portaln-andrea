require 'spec_helper'

describe Anexo do

  it "deveria salvar" do
    noticia = Factory.create :noticia
    
    count = Anexo.count
    anexo = Factory.create :anexo, :noticia_id => noticia.id
    anexo.save.should be_true
    
    Anexo.should have(count + 1).records
    anexo.reload

    anexo.noticia.should_not be_nil
    anexo.arquivo.should_not be_nil
  end
  
  it "deveria validar os campos obrigatorios" do
    a = Anexo.new
    a.save.should be_false
    
    a.errors.should_not be_nil               
    a.should have(1).errors_on(:noticia_id)
  end                   
  
end