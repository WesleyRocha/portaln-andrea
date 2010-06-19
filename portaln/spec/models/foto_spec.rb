require 'spec_helper'

describe Foto do

  it "deveria salvar" do
    album = Factory.create :album
    album.save.should be_true
    
    count = Foto.count
    foto = Factory.create :foto, :album_id => album.id
    foto.save.should be_true
    
    Foto.should have(count + 1).records
    foto.reload
    
    foto.imagem.url(:thumb).should_not be_nil
    foto.imagem.url(:normal).should_not be_nil
    foto.album.should_not be_nil
  end
  
  it "deveria validar os campos obrigatorios" do
    f = Foto.new
    f.save.should be_false
    
    f.errors.should_not be_nil               
    f.should have(1).errors_on(:album_id)
  end                   
  
  it "deveria retornar true em caso de publicada" do
    Foto.new(:publicada => true).publicada?.should be_true
    Foto.new.publicada?.should be_false
  end                             
  
  it "deveria retornar true em caso de nova" do
    Foto.new.nova?.should be_true
    Foto.new(:publicada => true).nova?.should be_false
    Foto.new(:publicada => false).nova?.should be_true
    Foto.new(:publicada => nil).nova?.should be_true
  end

end