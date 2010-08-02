#programa parseia os feeds do Google
#autor: tadeu luis anestesya@gmail.com

require 'rubygems'
require 'xmlsimple'
require 'xml'
require 'pp' #Import module 'pp' para 'pretty printing'

class FeedParser
	def initialize(documento)
    potas = File.new "#{ENV['PWD']}/xml_do_google.xml", "wb" 
    potas.puts documento.body
    potas.close
	  @doc= XmlSimple.xml_in(documento.body, 'KeyAttr' => 'name')
  end
  
  #imprime o documento na tela em formato HASH visualizavel.
	def show_doc 
	  pp @doc
  end	
       
  #pega a chave da planilha
  def get_spreadsheet_key
    #@chave_planilha = @doc["entry"][0]["id"][0][/full\/(.*)/, 1]  #usa a planilha Torneio Tênis de mesa do usuário tadeu.gaudio
	  #@chave = @doc["entry"][1]["id"][0][/full\/(.*)/, 1]	#usa a planilha iPongWinners do usuário tadeu.gaudio
    @chave = "tjS8wC9jSAR03-0pkf8cIhg" #planilha de tenis de mesa
	end
  
  #dentro do feed pega a URL#listFeed do documento a ser manipulado
  def get_feed_list_url 
     @feedList = @doc["entry"][0]["link"][0]['href']
     ##aqui testar para ver se o google devolve o resultado como HTTPS
     ##como já utilizamos conexão SSL não precisa da extensão https:// na URI e sim http://
     swp_list = URI.parse(@feedList)
     @url_list = "http://" << swp_list.host << swp_list.path 
  end
 
  #pega a URL#cellsFeed
  def get_feed_cell_list
    @cellsFeed = @doc["entry"][0]["link"][1]["href"] 
    swp_list = URI.parse(@cellsFeed)
    @cell_url_list = "http://" << swp_list.host << swp_list.path 
  end
  
  def get_users
    @users = Array.new
    @doc["entry"].each do |user|
      pp "USUÀRIO = #{user["jogador"]}"
      @users[i] = user["jogador"]
    end
    @users
  end

  def get_pontos 
    @pontos = Array.new
    pp @doc
    @doc["entry"].each do |pontos|
      grupo = "_cyevm"
      pp "Jogadores do Grupo A: #{pontos[grupo]} "#=> #{pontos[jogador]}"
      #@users[i] = user["ponstos"]
    end
  end
##fim da Classe FeedParser
end