require_relative "lib/sql_object.rb"

class Cat < SQLObject
  belongs_to(:owner, {
    primary_key: :id,
    foreign_key: :owner_id,
    class_name: "Human"
    })

  has_one_through(:house, :owner, :house)


  self.finalize!

end

class Human < SQLObject
  self.table_name = "humans"
  has_many(:cats)
  belongs_to(:house)

  self.finalize!
end


class House < SQLObject
  has_many(:humans)
  has_one_through(:cats, :humans, :cats)

  self.finalize!
end
