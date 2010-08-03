#Feito para ser usado com iPhone/iPad, Android ou Palm-pre... ou qualquer
#dispositivo que tenha acesso web.
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

require 'rubygems'
require 'sinatra'

#libs do programa
require 'jogadores'
require 'google_connect'

#variável global com os jogadores
DIR_XML_FILES = "public/files/xml/"
$feed = ""; $jogadores =""; $duplas="";
 #inicializa a conexãe e busca jogadores.
 def init
   $gc = GoogleConnect.new 'wise', 'ClientLogin', 'tadeu.gaudio@guenka.com.br', 'd3f1n3c0m'
   $feed = $gc.get_sheets
   $jogadores = $feed.get_users("")
   $duplas = $feed.get_users("duplas")
 end#fim do método de iniciar


#página index.
get '/' do
   #se não existe feed, não existe informação
   #então inicializar a coneção com o Google.
   if $feed.empty?
      init
   end
   erb :index
end

#página de jogadores 
get '/players' do
    if $jogadores.empty?
      init
    end
    erb :players 
end

#página de um contra um i
get '/single' do
   if $jogadores.empty?
      init
    end
   erb :single
end

#mostra pontuação para o um contra um 
get '/score_single' do
  erb :score_single
end

post '/score_single' do
  p "Vencedor: #{params[:vencedor]} | Tempo da partida: #{params[:tempo]}"
  erb :score_single
end

#DUPLAS ############################################################
#página de duplas
get '/duplas' do 
    if $duplas.empty?
      init
    end
    erb :duplas  
end

#mostra pontuação para as duplas
get '/score_duplas' do
  if $jogadore.empty?
      init
  end
  @duplas = $duplas_grupoA + $duplas_grupoB
  erb :score_duplas
end

post '/score_duplas' do
 p "Jogadores: #{params[:jogador_b]} ==== #{params[:jogador_a]}"
 p "Vencedor: #{params[:vencedor]} | Tempo da partida: #{params[:tempo]}"
 
  @duplas = [params[:set], params[:tempo], params[:jogador_a], params[:jogador_b], params[:pnt_jogador_a], params[:pnt_jogador_b]];
  
  erb :score_duplas
end
