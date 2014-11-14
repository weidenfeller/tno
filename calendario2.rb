require 'sequel'
require 'singleton'

module Evento
  attr_accessor :id, :descripcion, :tipo

  def initialize
  end
end
class Evaluacion
  include Evento

  TIPO_EVALUACION = 1

  attr_accessor :clase

  def initialize
    @tipo = TIPO_EVALUACION
    super
  end
end
class Recordatorio
  include Evento

  TIPO_RECORDATORIO = 2

  attr_accessor :curso

  def initialize
    @tipo = TIPO_RECORDATORIO
    super
  end
end

`rm calendario.db`
DB = Sequel.sqlite 'calendario.db'
DB.transaction do
  DB.create_table! :eventos do
    primary_key :id
    String :descripcion,    null: false
    Integer :tipo,          null: false
  end
  EVENTOS = DB[:eventos]

  DB.create_table! :evaluaciones do
    foreign_key :id, :eventos
    Integer :clase_id
  end
  EVALUACIONES = DB[:evaluaciones]

  DB.create_table! :recordatorios do
    primary_key :id
    Integer :curso_id
  end
  RECORDATORIOS = DB[:recordatorios]
end

module EventoDAO
  def save(e)
    e.id = EVENTOS.insert(
      descripcion: e.descripcion,
      tipo: e.tipo
    )
  end
end
class EvaluacionDAO
  include EventoDAO, Singleton

  def save(e)
    super e
    EVALUACIONES << {
      id: e.id,
      # Verificar si es ID valido
      # No es foreign_key porque no es una tabla
      clase_id: 1
    }
  end
end
class RecordatorioDAO
  include EventoDAO, Singleton

  def save(r)
    super r
    RECORDATORIOS << {
      id: r.id,
      # Verificar si es ID valido
      # No es foreign_key porque no es una tabla
      curso_id: 1
    }
  end
end

e_dao = EvaluacionDAO.instance
r_dao = RecordatorioDAO.instance

e = Evaluacion.new
e.descripcion = 'desc1'

r = Recordatorio.new
r.descripcion = 'desc2'

DB.transaction do
  (1..30_000).each { e_dao.save e }
  (1..30_000).each { r_dao.save r }
end

puts "Eventos: #{EVENTOS.count}"
puts "Evaluaciones: #{EVALUACIONES.count}"
puts "Recordatorios: #{RECORDATORIOS.count}"
