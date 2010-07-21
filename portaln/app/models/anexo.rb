class Anexo < ActiveRecord::Base

  belongs_to :noticia
  has_attached_file :arquivo,
                    :path => "#{PortalN::ANEXOS_PATH}/:class/:id/:style/:basename.:extension",
                    :url => ":class/download/:id/:style"
  
  validates_presence_of :noticia_id
                   
end