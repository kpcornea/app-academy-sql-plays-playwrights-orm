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

  def create
    raise "#{self} already in database" if @id
    PlayDBConnection.instance.execute(<<-SQL, @name, @birth_year)
      INSERT INTO
        playwrights (name, birth_year)
      VALUES
        (?, ?)
    SQL
    @id = PlayDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    PlayDBConnection.instance.execute(<<-SQL, @name, @birth_year, @id)
      UPDATE
        playwrights
      SET
        name = ?, birth_year = ?
      WHERE
        id = ?
    SQL
  end

  def get_plays
    data = PlayDBConnection.instance.execute("SELECT * FROM plays")
    plays_by_playwright = []

    data.each do |datum|
      if datum["playwright_id"] == @id
        plays_by_playwright << Play.new(datum)
      end
    end
    return plays_by_playwright unless plays_by_playwright.empty?
    raise "#{name} doesn't have plays in the database"
  end

end
