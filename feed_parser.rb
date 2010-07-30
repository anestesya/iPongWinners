#programa parseia os feeds do Google
#autor: tadeu luis anestesya@gmail.com

require 'rubygems'
require 'xmlsimple'
require 'pp' #Import module 'pp' para 'pretty printing'

class FeedParser
	def initialize(documento)
	  @doc= XmlSimple.xml_in(documento.body, 'KeyAttr' => 'name')
        end
        #imprime o documento na tela em formato HASH visualizavel.
	def show_doc
	  pp @doc
        end	
       
    	#pega a chave da planilha
   	def get_spreadsheet_key
	   @chave_planilha =@doc["entry"][0]["id"][0][/full\/(.*)/, 1]	
	end

 
##fim da Classe FeedParser
end
