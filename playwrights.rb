require 'sqlite3'
require_relative 'plays'

class Playwright
  attr_accessor :name, :birth_year

  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM playwrights")
    # p data
    data.map { |datum| Playwright.new(datum) }
  end

  def self.find_by_name(name)
    data = PlayDBConnection.instance.execute("SELECT * FROM playwrights")
    data.each do |datum|
      if datum["name"] == name
        return Playwright.new(datum)
      end
    end
    raise "#{name} not in database"
  end

  def initialize(options)
    @id = options['id']
    @name = options['name']
    @birth_year = options['birth_year']
  end

end
