require_relative 'db_connection'
require 'active_support/inflector'
require_relative 'searchable'
require_relative 'associatable'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    table = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL
    table[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    table = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL
    self.parse_all(table)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    hash = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      id = ?
    SQL
    return nil if hash.empty?
    self.new(hash.first)
  end

  def initialize(params = {})
    params.each do |column, value|
      column = column.to_sym
      raise "unknown attribute '#{column}'" unless self.class.columns.include?(column)
      send("#{column}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map{ |column| send(column) }
  end

  def insert
    columns = self.class.columns.map(&:to_s).join(", ")

    questions = self.class.columns.count.times.map{"?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{columns})
    VALUES
      (#{questions})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    setters = self.class.columns.map { |column| "#{column.to_s} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{setters}
    WHERE
      id = ?
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
