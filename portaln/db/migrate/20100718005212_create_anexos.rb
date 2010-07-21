class CreateAnexos < ActiveRecord::Migration
  def self.up
    create_table :anexos do |t|
      t.belongs_to :noticia
      
      t.string :arquivo_file_name
      t.string :arquivo_content_type
      t.integer :arquivo_file_size
      t.datetime :arquivo_updated_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :anexos
  end
end
