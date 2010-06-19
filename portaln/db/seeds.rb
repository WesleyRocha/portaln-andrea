# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# User test
test = User.create(
  :email => "test@gmail.com",
  :password => 'testtest',
  :username => "test",
  :name => "Test",
  :role_name => 'operador'
)

# User test 2
test2 = User.create(
  :email => "test2@gmail.com",
  :password => 'testtest2',
  :username => "test2",
  :name => "Test 2",
  :role_name => 'operador'
)                 

# User admin
admin = User.create(
  :email => "admin@gmail.com",
  :password => 'adminadmin',
  :username => "admin",
  :name => "Admin",
  :role_name => 'administrador'
)