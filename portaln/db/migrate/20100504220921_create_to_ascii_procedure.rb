class CreateToAsciiProcedure < ActiveRecord::Migration
  def self.up
    execute("CREATE FUNCTION to_ascii(bytea, name) RETURNS text STRICT AS 'to_ascii_encname' LANGUAGE internal;")
  end

  def self.down
  end
end
