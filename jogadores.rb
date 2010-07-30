#Classe que manipula os dados dos jogadores
#autor: tadeu luis anestesya@gmail.com

require 'xmlsimple'
require 'rexml/document'

include REXML 

class Jogadores
  #inicializa a classe para criar os arquivos. 
  def initialize(arquivo_xml)
     @arquivo_xml = arquivo_xml 
     @doc = abre_arquivo @arquivo_xml
  end #fim da initialize
  
   #método para abrir ou criar arquivos
   #@arquivo = "endereco/do/arquivo.xml"
   #retorna um arquivo no endereço atribuido.
   def abre_arquivo(arquivo) 
     @arquivo = arquivo

     if File.exist? @arquivo then
        p "#{@arquivo} existe"
        file = Document.new File.open @arquivo
     else 
        p "O arquivo #{@arquivo} não existia, tentando criar"
        arquivo = File.new @arquivo_xml, "w+"; arquivo.close; #cria o arquivo e fecha.
        #abre o arquivo e insere o conteúdo básico.
        arquivo = File.open @arquivo_xml, 'wb' 
        arquivo.puts "<?xml version='1.0' encoding='UTF-8'?>"
        arquivo.close
        #em posse do arquivo passamos o XML para a XmlSimple.
        file = Document.new File.new @arquivo_xml
    end
  end #fim do método abre arquivo
   
 ##adiciona os jogadores em um arquivo XML caso receba um vetor com os nomes.
 def add_jogadores(jogadores)
   @jogadores = Array.new(jogadores)
   root = @doc.root; @i=0;
   #testa par saber se existe a raiz dos participantes.   
   if root == nil then
     @doc.add_element('jogadores', {"dirpontos" => "public/files/xml/pontos.xml"})
     root = @doc.root
   end
 
     #insere os jogadores no arquivo XML de participantes
     @jogadores.each do |jogador|
       @i += 1
       #testa se o jogador já está inserido.
        if root.elements[@i] == nil then
          root.add_element('jogador', {"nome", jogador})
        end
	   end #fim do laço
	   
    file = File.open @arquivo_xml, 'wb'
		file.puts @doc
    file.close
 end ##fim do método add_jogadores
 
  #pega os participantes que estão em um arquivo XML 
  #e os transforma em uma hash com xmlsimple e os insere em um vetor.
   def get_participantes
     @participantes = XmlSimple.xml_in(@arquivo_xml, {'KeyAttr' => 'data'})
    #coloca os elementos no array
     @jogadores = Array.new; i = 0; l=0;
        @participantes.each_pair do |c, v|
           #navega nos itens do Hash que estão dentro de um vetor
           if v.class == Array then
             v.each do |index|
               index.each do |j, h|
                  l = l+1
                  @jogadores[l] = h
               end
             end
           end
       end
       @jogadores
   end #fim do get_participantes
 
   def get_partidas
     
   end
 
   def get_resultados
     
   end
 
####### fim da classe Jogadores
end 