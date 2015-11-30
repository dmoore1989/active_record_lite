require_relative 'db_connection'

module Searchable
  def where(params)
    where_line = params.map{ |k, _| "#{k} = ?"}.join(" AND ")
    values = params.values
    results = DBConnection.execute(<<-SQL, *values)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{where_line}
    SQL

    results.map{ |result| self.new(result) }
  end
end
