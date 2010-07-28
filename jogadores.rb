#Classe que manipula os dados dos jogadores
#autor: tadeu luis anestesya@gmail.com

require 'xmlsimple'
require 'rexml/document'

include REXML

class Jogadores
  #recebe o endereço do arquivo XML para ser tratado.  
  def initialize(arquivo_xml)
     @arquivo_xml = arquivo_xml
     #abre o arquivo especificado pelo usuário
     file = File.new(@arquivo_xml)
     @doc = Document.new(file) #gera um documento XML do arquivo
     p "Documento: #{@doc} " 
     @a = "foda-se"
     p @a
  end
  
 ##adiciona os jogadores em um arquivo XML caso receba um vetor com os nomes.
 def add_jogadores(jogadores)
   @@jogadores = Array.new(jogadores)
  
   #insere os jogadores no arquivo XML de participantes
   @@jogadores.each  do |jogador|
     @doc.root.add_element('jogador', {"nome", jogador})
  end
   p @a  
 end
 
  #pega os participantes que estão em um arquivo XML 
  #e os transforma em uma hash com xmlsimple e os insere em um vetor.
  #def get_participantes
  #   @@participantes = XmlSimple.xml_in(@@arquivo_xml, {'KeyAttr' => 'data'})
  #   
  #   #coloca os elementos no array
  #   @jogadores = Array.new; i = 0;
  #  @@participantes.each do |k, v| 
  #      @jogadores[i++] = v
  #   end
  #  p @jogadores
  #end
 
####### fim da classe Jogadores
end 