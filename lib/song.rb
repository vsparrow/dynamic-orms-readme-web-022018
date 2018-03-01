require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{self.table_name}')"
    table_info = DB[:conn].execute(sql) #PRAGMA return which is a array of hashes
    column_names = []
    table_info.each do |col_name|
      column_names << col_name["name"]
    end
    column_names.compact
  end

  #program the attr_accessor
  #outside in the class so when called attr_accessor is setup
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  # now that we have attr_accessor we can build out initialize
  def initialize(options={}) #design initialize to take any argument by taking a hash
    options.each do |property, value|
      self.send("{property}=",value)
    end
  end

  # In order to use a class method inside an instance method,
  # we need to do the following:
  # self.class.class_method
  # so to use self.table_name we need to do self.class.table_name
  def table_name_for_insert #for the instance, we method a way to get table name
    self.class.table_name
  end

  # insert into #{self.table_name} (#{self.column_names.join(,)})
  # values (#{})  #this was wrong...
  # we dont want id inserted so
  # self.class.column_names.delete_if {|col| col =='id'}.join(", ")
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col=='id'}.join(", ")
  end

  #how to gtab attr_accessor values?
  #attr_accessor methods derived from column names, use column_names
  #we can invoke the method using send
  #we push the return value via send unless its nil (like for id)
    # values = []
    # self.class.column_names.each do |col_name|
    #   values << "'#{send(col_name)}'" unless send(col_name).nil?
    # end
  # values -> ["'the name of the song'", "'the album of the song'"]
  # so we want values.join(", ")
  def values_for_insert
    values = []
    self.class.column_names do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    # sql = "INSERT INTO table_name () VALUES ()"
    sql = "INSERT INTO #{self.table_name_for_insert}
      (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from
      #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    # sql = "SELECT * FROM table_name where name = ?"
    sql = "SELECT * FROM #{self.table_name_for_insert} where name = #{name}"
    DB[:conn].execute(sql)
  end

  #
  # def self.table_name
  #   self.to_s.downcase.pluralize
  # end
  #
  # def self.column_names
  #   DB[:conn].results_as_hash = true
  #
  #   sql = "pragma table_info('#{table_name}')"
  #
  #   table_info = DB[:conn].execute(sql)
  #   column_names = []
  #   table_info.each do |row|
  #     column_names << row["name"]
  #   end
  #   column_names.compact
  # end
  #
  # self.column_names.each do |col_name|
  #   attr_accessor col_name.to_sym
  # end
  #
  # def initialize(options={})
  #   options.each do |property, value|
  #     self.send("#{property}=", value)
  #   end
  # end
  #
  # def save
  #   sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  #   DB[:conn].execute(sql)
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  # end
  #
  # def table_name_for_insert
  #   self.class.table_name
  # end
  #
  # def values_for_insert
  #   values = []
  #   self.class.column_names.each do |col_name|
  #     values << "'#{send(col_name)}'" unless send(col_name).nil?
  #   end
  #   values.join(", ")
  # end
  #
  # def col_names_for_insert
  #   self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  # end
  #
  # def self.find_by_name(name)
  #   sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  #   DB[:conn].execute(sql)
  # end

end
