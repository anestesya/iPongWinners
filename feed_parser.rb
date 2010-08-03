#programa parseia os feeds do Google
#autor: tadeu luis anestesya@gmail.com

require 'rubygems'
require 'xmlsimple'
require 'pp' #Import module 'pp' para 'pretty printing'

class FeedParser
	def initialize(documento)
    #potas = File.new "#{ENV['PWD']}/xml_do_google.xml", "wb" 
    #potas.puts documento.body
    #potas.close
        @doc= XmlSimple.xml_in(documento.body, 'KeyAttr' => 'name')
  end
  
  #imprime o documento na tela em formato HASH visualizavel.
	def show_doc 
	  pp @doc
	end

  def get_doc 
    @doc
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
  def get_feed_cell_list_url
    @cellsFeed = @doc["entry"][0]["link"][1]["href"] 
    swp_list = URI.parse(@cellsFeed)
    @cell_url_list = "http://" << swp_list.host << swp_list.path 
  end
  
  def get_users
    @users = Array.new; @duplas = Array.new; i=0; d=0;
    @doc["entry"].each do |user|
	coluna = user["cell"][0]["col"]
	jogador = user["cell"][0]["inputValue"]
	if coluna == "2" || coluna == '6'
                #testa para saber se o jogador já está no vetor
                unless @users.include? jogador
                   jogadores = jogador.split "/"
                   if jogadores.size == 2
			jogadores = jogadores.sort
		        unless @duplas.include? jogadores
				d +=1
				@duplas[d] = jogadores
			 end
		   else
                    	 i+=1
		    	@users[i] = jogador
                    end
                end     
 	end
     end
	pp  "Jogadores #{@users}"
	pp "Duplas: #{@duplas}"
	@users
  end

  def get_pontos 
    #@pontos = Array.new
     
    @doc["entry"].each do |pontos|    
             coluna = pontos["cell"][0]["col"] 
             linha = pontos["cell"][0]["row"]
             valor = pontos["cell"][0]["inputValue"]
             if coluna == "2"
            	 pp "Coluna: #{valor}"
	     end        
      #@users[i] = user["ponstos"]
    end
  end
##fim da Classe FeedParser
end
