require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name 
        self.to_s.downcase.pluralize
    end 

    def self.column_names
        DB[:conn].results_as_hash = true 

        sql = "Pragma table_info('#{table_name}')"
        table_info = DB[:conn].execute(sql)

        column_names = []
        table_info.each do |col_name| 
            column_names << col_name['name']
        end 
        column_names.compact
    end 

    def initialize(options={})
        options.each {|k,v| self.send("#{k}=", v)}
    end

    def table_name_for_insert 
        self.class.table_name
    end 

    def col_names_for_insert
        self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
    end 

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end 
        values.join(", ")
    end 

    def save 
        sql = "Insert into #{table_name_for_insert} (#{col_names_for_insert}) values (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
    end 


 




    
end