require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        column_names = []
        table_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name});")
        table_info.each do |column|
            column_names << column["name"]
        end

        column_names.compact
    end

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
        end
    end

    def col_names_for_insert
        col_names = self.instance_variables.map{|a| a.to_s.delete("@")}.compact
        col_names.delete("id")
        col_names.join(", ")
    end

    def values_for_insert
        values = []
        methods = self.instance_variables.map{|a| a.to_s[1..-1]}
        methods.each do |m|
            values << self.send("#{m}") unless self.send("#{m}").nil?
        end
        values.map{|v| "'#{v.to_s}'"}.join(", ")
    end

    def table_name_for_insert
        self.class.table_name
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
      end

    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?;", name)
        result[0].delete(0)
        result[0].delete(1)
        result[0].delete(2)
        result
    end

    def self.find_by(attributes)
        value = attributes.values.first
        formatted_value = value.class == Fixnum ? value : "'#{value}'"
        key = attributes.keys.first
        result = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = #{formatted_value};")
        result[0].delete(0)
        result[0].delete(1)
        result[0].delete(2)
        result
    end

  
end