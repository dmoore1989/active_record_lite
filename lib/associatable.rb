require 'active_support/inflector'
require 'byebug'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.singularize.constantize
  end

  def table_name
    class_name.downcase.concat("s")
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
    @foreign_key = options[:foreign_key] ? options[:foreign_key] : name.to_s.singularize.concat("_id").underscore.to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
    @foreign_key = options[:foreign_key] ? options[:foreign_key] : self_class_name.to_s.singularize.concat("_id").underscore.to_sym
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    options = self.assoc_options[name]
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(options.primary_key => foreign_key.to_s).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self, options)
    options = self.assoc_options[name]
    define_method(name) do
      primary_key = self.send(options.primary_key)
      target_class = options.model_class
      target_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end


  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_foreign = self.send(through_options.foreign_key)

      lookup = DBConnection.execute(<<-SQL, through_foreign)
      SELECT
        #{source_options.table_name}.*
      FROM
        #{through_options.table_name}
      JOIN
        #{source_options.table_name}
      ON
        #{source_options.table_name}.#{through_options.primary_key} AND #{through_options.table_name}.#{source_options.foreign_key}
      WHERE
        #{source_options.table_name}.id = ?
      SQL

      source_options.model_class.new(lookup.first)
    end

  end
end
