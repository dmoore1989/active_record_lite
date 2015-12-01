#Active Record Lite

Active Record Lite is an ORM based off the functionality of Rails active record.  It utilizes the power of Ruby's metaprogramming and db_connection to create useful methods that allows Ruby to interact with a SQLite3 database.

## Notes for Project

This was one of the most intriguing projects I did at appAcademy.  It allowed me to see what goes on under the hood in Rails and some of the powerful functionality Ruby and other programming languages contain. Heavily used is Ruby's send (to allow the calling of attribute setters stored as strings) and the define_method which allows us to define (attribute getters and setters and the definition of associations).

## How to Use

This project can be used by requiring 'sql_object.rb' in your project and having  Model classes that correspond to your database inherit SQLObject. Please see the example.rb and cats.sql included in this repository to see a sample of this functionality.

###Available Methods:

* SQLObject::all
* SQLObject::first
* SQLObject::last
* SQLObject::find(id)
* SQLObject#save
* SQLObject::where(params)
* SQLObject::belongs_to
* SQLObject::has_many
