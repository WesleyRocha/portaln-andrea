class CreateFoto < ActiveRecord::Migration
  def self.up
    create_table :fotos do |t|
      t.text :legenda
      t.string :fotografo    
      t.boolean :publicada
      t.integer :ordem
      t.belongs_to :album
      
      t.string :imagem_file_name
      t.string :imagem_content_type
      t.integer :imagem_file_size
      t.datetime :imagem_updated_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :fotos
  end
end
