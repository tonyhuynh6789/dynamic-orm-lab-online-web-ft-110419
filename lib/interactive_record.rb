require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"
class InteractiveRecord

   def self.table_name
    self.to_s.downcase.pluralize 
   end 


   def self.column_names 
    DB[:conn].results_as_hash = true 

    table_info = DB[:conn].execute("Pragma table_info('#{table_name}')")

    column_names = []
    table_info.each do |col_name|
        column_names << col_name['name'] 
    end 
    column_names.compact
   end 


   def initialize(option={})
   option.each {|k,v| self.send("#{k}=", v)}
   end 


   def table_name_for_insert 
    self.class.table_name
   end 


   def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
   end 
   

   def values_for_insert
    values = []
    self.class.column_names.each do |col|
        values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
   end 

   def save 
    sql = <<-SQL
    Insert into #{table_name_for_insert} (#{col_names_for_insert}) values (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
   end 

   def self.find_by_name(name)
    sql = <<-SQL
    select *
    from #{table_name}
    where name = ?
    SQL
    DB[:conn].execute(sql, name)
   end 


   def self.find_by(attribute)
    column_name = attribute.keys[0].to_s
    value_name = attribute.values[0]
    
    sql = <<-SQL
    select *
    from #{table_name}
    where #{column_name} = ?
    SQL
    DB[:conn].execute(sql, value_name)
   end 


  
   



end