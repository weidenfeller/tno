require 'sequel'

DB = Sequel.sqlite 'resultado.db'

DB.create_table! :resultados do
  primary_key :id
  Integer :evaluacion_id
  Integer :alumno_id
  String :calificacion
  Boolean :aprobado
end
RESULTADOS = DB[:resultados]

class Resultado
  attr_accessor :id, :evaluacion, :alumno, :calificacion, :aprobado
end

class ResultadoDAO

end
