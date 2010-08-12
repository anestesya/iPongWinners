#programa parseia os feeds do Google
#autor: tadeu luis anestesya@gmail.com

require 'rubygems'
require 'xmlsimple'
require 'pp' #Import module 'pp' para 'pretty printing'

class FeedParser
  def initialize(documento)
    p "Vamos criar um xml para ser visto."
    potas = File.new "#{ENV['PWD']}/cellFeed.xml", "wb" 
    potas.puts documento.body
    potas.close
    @doc= XmlSimple.xml_in(documento.body, 'KeyAttr' => 'name')
  end
  
  #imprime o documento na tela em formato HASH visualizavel.
  def show_doc 
    pp @doc
  end
  
  #retorna o documento para fims de leitura e testes.
  def get_doc 
    @doc
  end

  #pega a chave da planilha
  def get_spreadsheet_key
    #@chave_planilha = @doc["entry"][0]["id"][0][/full\/(.*)/, 1] usa a planilha Torneio Tênis de mesa do usuário tadeu.gaudio
    #@chave = @doc["entry"][1]["id"][0][/full\/(.*)/, 1]	usa a planilha iPongWinners do usuário tadeu.gaudio
    @chave = "tjS8wC9jSAR03-0pkf8cIhg" #planilha de tenis de mesa
  end
  
  #dentro do feed pega a URL#listFeed do documento a ser manipulado
  #A URL retornada é utilizada na hora de parsear os dados
  # e é muito importante.
  def get_url_feed(tipo)
     #verifica o tipo do feed para pegar manipular os dados de forma direferenciada
     if tipo == "listFeed"
       @feedType = @doc["entry"][0]["link"][0]['href']
     elsif tipo == "cellFeed"
       @feedType = @doc["entry"][0]["link"][1]["href"]
     end
     
     #como já utilizamos conexão SSL não precisa da extensão https:// na URI e sim http://
     swp_list = URI.parse(@feedType)
     @url_feed = "http://" << swp_list.host << swp_list.path
  end
 
  #retorna a URI completa para inserir dados utilizando o método de cedulas.
  def get_uri_to_update
       #p "Linha: #{linha} Coluna: #{coluna}"
       uri_rc = @doc["id"][0]
      # uri_rc += "/R#{linha}C#{coluna}" #URI para a Linha A coluna B
        uri_rc = uri_rc.gsub "https://", "http://"
  end  
  
  #pega os usuários que estão participando do campeonato
  #devolve um vetor de @duplas ou de @users 
  # * opcao = "" => devolve vetor de usuários simples @users
  # * opcao = "duplas" devolve vetor de usuários @duplas
  def get_users(opcao)
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
	     end##fim do doc["entry"]
     
     #se tiver alguma opção ele retorna as duplas
      p "Opcao: #{opcao.empty?}"
     unless opcao.empty?
	       @duplas
     else
	       @users
     end
  end


  #Pega a pontuação dos resultados
  def get_pontos    
        @pontos = Array.new; users = Array.new;
            @doc["entry"].each do |pontos|    
                     coluna = pontos["cell"][0]["col"] 
                     linha = pontos["cell"][0]["row"]
                     valor = pontos["cell"][0]["inputValue"]
                    
                     #Pega os jogadores dos grupos A e C
                     if coluna == "8" || coluna == "15"
                       xpr = valor.match /(GRUPO) (.*)/
                       if xpr == nil
                          users.push valor
                       end
                     end
                     
                      #pega a pontuação dos usuários.
                      if coluna == "10" || coluna == "17"
                         if linha.to_i > 3
                            if valor == "0"
                              #p "Linha: #{linha}, Coluna 10, valor: #{valor.to_i.to_int}"
                              @pontos.push 0
                             elsif !(valor.to_i == 0)
                             # p "LInha #{linha}, valor: #{valor}"
                              @pontos.push valor
                             end
                         end
                     end
             end#varre_feed
                              
             #cria vetor com user_ponto["Tadeu"] = "0"
             j = 0; @user_score = {};
             users.each do |u|
               score ={u => @pontos[j]}
               @user_score = @user_score.merge(score) 
               j+=1
             end
         @user_score
  end#fim do get_pontos
    
    #pega  as datas dos jogos e as coloca em um vetor
    def get_jogos
        @dt = Array.new; @dados = ""; vetor = Array.new; contador=0;
        @doc["entry"].each do |pontos| 
             #p "Contador: #{contador}"
             linha = pontos["cell"][0]["row"]
             coluna = pontos["cell"][0]["col"] 
             valor = pontos["cell"][0]["inputValue"]
             #pega as datas dos jogos
               if linha.to_i > 2 && contador > 3
                 p "Jogo: #{valor} #{pontos["cell"][0]["col"][2]} #{pontos["cell"][0]["col"][3] } X #{pontos["cell"][0]["col"][5] } #{pontos["cell"][0]["col"][6] } "
               end#fim da linha
             
              contador += contador
#             if coluna == "2"
#               if linha.to_i > 2
#                  pp "Jogador A: #{valor} #{contador}"
#                  jogador_a = valor
#                  @dados += valor + " "
#                end              
#             end
#             
#             if coluna == "3"
#               if linha.to_i > 2
#                 pp "Pontos A: #{valor} #{contador}"
#                 pontos_a = valor
#                 @dados += valor + " "
#               end
#             end
#             
#             if coluna == "4"
#               if linha.to_i > 2
#                    pp "Versus: #{valor} #{contador}"
#                    versus = valor
#                    @dados += valor + " "
#                end
#              end
#                  
#              if coluna == "5"
#                if linha.to_i > 2
#                   pp "Pontos B: #{valor} #{contador}"
#                    pontos_b = valor
#                    @dados += valor + " "
#                end
#              end
#                  
#              if coluna == "6"
#                 if linha.to_i > 2
#                      pp "Jogador: #{valor} #{contador}"
#                      jogador_b = valor
#                      @dados += valor
#                end
#              end
              
            end#fim teste principal
    end#fim do get_datas
##fim da Classe FeedParser
end
