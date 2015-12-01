require_relative "lib/sql_object.rb"

class Cat < SQLObject

  self.finalize!

end

class Human < SQLObject
  self.finalize!
  has_many(cats, )

end


class Home < SQLObject
