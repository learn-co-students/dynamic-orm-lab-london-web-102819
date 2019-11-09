require_relative "../config/environment.rb"
require 'active_support/inflector'
require_relative './interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

    self.column_names.each do |col_name|
        self.attr_accessor col_name.to_sym
    end

end

binding.pry

puts 'done'
