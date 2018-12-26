require 'sqlite3'
require 'singleton'

class PlayDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('plays.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Play
  attr_accessor :title, :year, :playwright_id

  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM plays")
    p data
    data.map { |datum| Play.new(datum) }
  end

  def self.find_by_title(title)
    data = PlayDBConnection.instance.execute("SELECT * FROM plays")
    data.each do |datum|
      if datum["title"] == title
        return Play.new(datum)
      end
    end
    raise "#{title} not in database"
  end

  def self.find_by_playwright(name)
    data = PlayDBConnection.instance.execute("SELECT * FROM plays")
    playwright_arr = PlayDBConnection.instance.execute(<<-SQL, name)
      SELECT
        id
      FROM
        playwrights
      WHERE
        name = ?
    SQL

    playwright_id = playwright_arr[0]["id"] unless playwright_arr.empty?
    plays_by_playwright = []

    data.each do |datum|
      if datum["playwright_id"] == playwright_id
        plays_by_playwright << Play.new(datum)
      end
    end
    return plays_by_playwright unless plays_by_playwright.empty?
    raise "#{name} doesn't have plays in the database"
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @year = options['year']
    @playwright_id = options['playwright_id']
  end

  def create
    raise "#{self} already in database" if self.id
    PlayDBConnection.instance.execute(<<-SQL, self.title, self.year, self.playwright_id)
      INSERT INTO
        plays (title, year, playwright_id)
      VALUES
        (?, ?, ?)
    SQL
    self.id = PlayDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.id
    PlayDBConnection.instance.execute(<<-SQL, self.title, self.year, self.playwright_id, self.id)
      UPDATE
        plays
      SET
        title = ?, year = ?, playwright_id = ?
      WHERE
        id = ?
    SQL
  end
end
