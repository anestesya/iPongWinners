#Feito para ser usado com iPhone/iPad, Android ou Palm-pre... ou qualquer
#dispositivo que tenha acesso web.
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

require 'rubygems'
require 'sinatra'
require 'pp'

#libs do programa
require 'google_connect'
require 'model'
require 'jogadores'

#variável global com os jogadores
$feed = ""

 #inicializa a conexãe e busca jogadores.
 def init
   p "Inicializando........"
   user_senha = File.readlines "lock.txt";
   $gc = GoogleConnect.new 'wise', 'ClientLogin', user_senha[0], user_senha[1]
 end

  #Verifica quando o feed foi atualizado
  def checkFeed
        #hora_de_acesso = feed.atime #pega hora de criação do arquivo
        #hora_atual = Time.now
        #acesso = hora_atual.min.to_i - hora_de_acesso.min.to_i
       
        #se o arquivo não existir
        #vai criar o arquivo pela primeira vez.
        p "Atualizar feed."
        init #inicializa conexão com o google
        feed = $gc.get_sheets
               
        participantes feed
  end #fim do verifica_criacao_arquivo

  #Recebe um objeto do tipo FeedParser.
  #gera lista de feed para participantes e a modalidade de duplas.
 def participantes(feedParser) 
   feed_parser = feedParser
   
   jogadores = feed_parser.get_users("")
   #criaListaJogadores = Jogadores.new DIR_XML_FILES + "participantes.xml"
   #criaListaJogadores.add_jogadores jogadores
#   p "#{DIR_XML_FILES}participantes.xml                   [OK]"
        
   duplas = feed_parser.get_users("duplas")
 #  criaListaDuplas = Jogadores.new DIR_XML_FILES + "duplas.xml"
  # criaListaDuplas.add_jogadores duplas
  # p "#{DIR_XML_FILES}duplas.xml                          [OK]"
  
  pp jogadores
  pp duplas
 end#fim do método de iniciar


###############################################################################
###### SERVER #################################################################
###############################################################################
#página index.
get '/' do
   #checkFeed
   erb :index
end

#página de jogadores 
get "/players" do
    erb :players 
end

#página de um contra um i
get '/single' do
   erb :single
end

#mostra pontuação para o um contra um 
get '/score_single' do
        init #inicializa conexão com o google
        feed = $gc.get_sheets
        @pontuacao = feed.get_pontos
        #feed.get_jogos
  erb :score_single
end

post '/score_single' do
    vencedor = params[:vencedor].gsub /[0-9]\-/, ""
    vencedor = vencedor.gsub /^( )*/, ""
    vencedor = vencedor.upcase
    if vencedor == "TADEU"
            dados_a_serem_atualizados = [ {:batch_id => 'A1', :cell_id => 'R6C10', :data => '2'}]
             #atualiza via feeds
            init
            feed = $gc.get_sheets
            update_uri = feed.get_uri_to_update
            rsp = $gc.batch_update(dados_a_serem_atualizados, update_uri)
            p "Resultado da atualizacao dos dados: #{rsp}"
            
            
    elsif vencedor == "LUIS GUSTAVO"
            dados_a_serem_atualizados = [ {:batch_id => 'A2', :cell_id => 'R4C10', :data => '3'}]
             #atualiza via feeds
            init
            feed = $gc.get_sheets
            update_uri = feed.get_uri_to_update
            rsp = $gc.batch_update(dados_a_serem_atualizados, update_uri)
            p "Resultado da atualizacao dos dados: #{rsp}"
    end
  
            feed = $gc.get_sheets
            @pontuacao = feed.get_pontos
     
   #erb :score_single
end


#DUPLAS ############################################################
#página de duplas
get '/duplas' do 
    erb :duplas  
end

#mostra pontuação para as duplas
get '/score_duplas' do
  erb :score_duplas
end

post '/score_duplas' do
  p "Jogadores: #{params[:jogador_b]} ==== #{params[:jogador_a]}"
  p "Vencedor: #{params[:vencedor]} | Tempo da partida: #{params[:tempo]}"
 
  @duplas = [params[:set], params[:tempo], params[:jogador_a], params[:jogador_b], params[:pnt_jogador_a], params[:pnt_jogador_b]];
  
  erb :score_duplas
end
