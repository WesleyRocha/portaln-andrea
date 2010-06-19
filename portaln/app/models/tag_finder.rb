class TagFinder
    
  # Procura as tags pelo nome, ignorando o case e os acentos.
  # Este metodo necessita da migracao <i>2010-04-04_versao_01.sql</i>
  # 
  def self.find_all_by_tag_name(name)
    if name.nil? or name.empty? then return '' end
      
    Tag.find(
      :all, 
      :conditions => ["#{retirar_acentos('name')} like lower(?)",
                      "%#{name.parameterize}%"], # parameterize tira os acentos
      :order => 'name asc'
    )                       
  end
                         
  private
  def self.retirar_acentos campo
    "lower(to_ascii(convert_to(#{campo}, 'latin1'), 'latin1'))"
  end
  
end