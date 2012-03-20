require 'sdbm'

module DB
  # TODO: this API promotes not closing databases. Is that bad?
  def self.[](name)
    SDBM.new File.expand_path("../../../../db/#{name}", __FILE__)
  end
end