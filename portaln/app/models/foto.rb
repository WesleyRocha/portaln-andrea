class Foto < ActiveRecord::Base

  belongs_to :album
  has_attached_file :imagem,
                    :content_type => 'image',
                    :styles => { 
                      :thumb  => "100x100#",
                      :thumb2 => "300x300#",
                      :normal => "800x600",
                      :grande => "1024x768"
                    },
                    :default_style => :normal,
                    :path => "#{PortalN::IMAGENS_PATH}/:class/:id/:style/:basename.:extension",
                    :url => ":class/show/:id/:style"
  
  validates_presence_of :album_id
                   
  def publicada?
    publicada == true
  end        
  
  def nova?
    publicada == false or publicada == nil
  end
  
end