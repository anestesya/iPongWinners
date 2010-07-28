#classe em ruby para conectar no google spreadsheet
#autor: tadeu luis anestesya@gmail.com
require 'xmlsimple'

class GoogleConnect
  def initialize(service, auth_type, user, password)
      @@service = service
      @@auth_type = auth_type
      @@user = user
      @@password = password
   end 

   def parseXML(arquivo, tipo_de_arquivo_de_retorno)
       @@arquivo = arquivo
       @@tipo_de_arquivo_de_retorno = tipo_de_arquivo_de_retorno
   end

   def get_user
       @@user
   end
   
   def get_retorno
       @@tipo_de_arquivo_de_retorno
   end
end
