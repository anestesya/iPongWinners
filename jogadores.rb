#Classe que manipula os dados dos jogadores
#autor: tadeu luis anestesya@gmail.com

require 'xmlsimple'
require 'rexml/document'

include REXML

class Jogadores
  #variáveis que são passadas pelos objetos.
  @@doc = ""
    
  #recebe o endereço do arquivo XML para ser tratado.  
  def initialize(arquivo_xml)
     @arquivo_xml = arquivo_xml 
     if File.exist? @arquivo_xml then
        p "#{@arquivo_xml} existe"
        @@doc = Document.new File.new @arquivo_xml
     else 
        p "O arquivo #{@arquivo_xml} não existia, tentando criar"
        arquivo = File.new @arquivo_xml, "w+"
        arquivo.close
        arquivo = File.open @arquivo_xml, 'wb'
	arquivo.puts "<?xml version='1.0' encoding='UTF-8'?> <jogadores dirpontos='jogadores/pontos'></jogadores>"
        arquivo.close
        @@doc = Document.new File.new @arquivo_xml
     end
  end
  
 ##adiciona os jogadores em um arquivo XML caso receba um vetor com os nomes.
 def add_jogadores(jogadores)
   @jogadores = Array.new(jogadores)
   #insere os jogadores no arquivo XML de participantes
   @jogadores.each  do |jogador|
     @@doc.root.add_element('jogador', {"nome", jogador})
  end
	file = File.open @arquivo_xml, 'wb'
		file.puts @@doc
        file.close
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
