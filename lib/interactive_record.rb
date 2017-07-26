require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
    PRAGMA table_info(#{table_name});
    SQL
    columns = []
    array = DB[:conn].execute(sql)
    array.each do |row|
      columns << row["name"]
    end
    columns
  end

  def initialize(hash={})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
        values << "'#{send(col)}'" unless send(col).nil?
  end
    values.join(", ")
  end

  def col_names_for_insert
    values = []
    self.class.column_names.each do |col|
        values << "#{col}" unless col == "id"
  end
    values.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}
    (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    x = <<-SQL
    SELECT last_insert_rowid()
    FROM #{table_name_for_insert}
    SQL
    self.id = DB[:conn].get_first_value(x)
  end

  def self.find_by_name(str)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    x = DB[:conn].execute(sql, str)
    x
  end

  def self.find_by(hash)
    hash.map do |key, value|
      puts value
      sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{key} = ?
      SQL
      DB[:conn].get_first_row(sql, value)
    end

  end

end
