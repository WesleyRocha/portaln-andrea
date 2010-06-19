require 'spec_helper'

describe TagFinder do
  
  it "deveria pesquisa uma tag pelo nome ignorando o case e os acentos" do
    tag1 = Factory.create :tag, :name => 'Relatório'
    tag2 = Factory.create :tag, :name => 'Hortolândia'
    tag3 = Factory.create :tag, :name => 'Túlio'
    
    # Pesquisando com acento e case maluco
    tag = TagFinder.find_all_by_tag_name('ReLaTóRiO')
    tag.should_not be_nil        
    tag.length.should > 0
    tag[0].name.should == 'Relatório'
                                          
    # Com acento e com case up
    tag = TagFinder.find_all_by_tag_name('HORTOLÂNDIA')
    tag.should_not be_nil
    tag.length.should > 0
    tag[0].name.should == 'Hortolândia'
                              
    # Pesquisando pela palvra normal
    tag = TagFinder.find_all_by_tag_name('Túlio')
    tag.should_not be_nil
    tag.length.should > 0
    tag[0].name.should == 'Túlio'
                                    
    # Pesquisando com case down e sem acento
    tag = TagFinder.find_all_by_tag_name('relatorio')
    tag.should_not be_nil        
    tag.length.should > 0
    tag[0].name.should == 'Relatório'
                                            
    # Pesquisando com case down e com parte da palavra
    tag = TagFinder.find_all_by_tag_name('horto')
    tag.should_not be_nil
    tag.length.should > 0
    tag[0].name.should == 'Hortolândia'
                                                      
    # Pesquisando com case down e sem acento
    tag = TagFinder.find_all_by_tag_name('tulio')
    tag.should_not be_nil
    tag.length.should > 0
    tag[0].name.should == 'Túlio'
  end
  
end