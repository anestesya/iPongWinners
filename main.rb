#Feito para ser usado com iPhone/iPad, Android ou Palm-pre... ou qualquer
#dispositivo que tenha acesso web.
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

require 'rubygems'
require 'sinatra'
require 'jogadores'

#variável global com os jogadores
DIR_XML_FILES = "public/files/xml"

$jogadores = [ 'Luiz Gustavo', 'Brahim Neto', 'Mateus Balconi', 'Bruno Yamada', 'Helder Belan', 'Heber Nascimento', 'Alessandro Almeida',
'Fernando Luizão','Daniel Luvizotto', 'Gledston Santana', 'David Renó','Chris Andrew','Laerte Zaccarelli','Pedro Nogueira','Tadeu Gaudio',
'João Paulo', 'Renan Barbosa','Jandira Guenka Palma'];

$duplas_grupoA = ['DANIEL/TADEU', 'RENAN/DAVID', 'HEBER/LAERTE', 'LUIZ GUSTAVO/CHRIS'];
$duplas_grupoB = ['MATEUS/JOÃO PAULO', 'BRAHIM/BRUNO', 'HELDER/LUIZÃO', 'GLEDSTON/ALESSANDRO'];

#HOME #############################################################
#página index.
get '/' do
  jogadores = Jogadores.new DIR_XML_FILES+"participantes.xml"
  duplas_a = Jogadores.new DIR_XML_FILES+"duplas_grupoA.xml"
  duplas_b = Jogadores.new DIR_XML_FILES+"duplas_grupoB.xml" 

  jogadores.add_jogadores $jogadores
  duplas_a.add_jogadores $duplas_grupoA
  duplas_b.add_jogadores $duplas_grupoB
 
 erb :index
end

#JOGADORES #######################################################
#página de jogadores 
get '/players' do 
 erb :players 
end

#UM CONTRA UM #####################################################
#página de um contra um i
get '/single' do
   erb :single
end

#mostra pontuação para o um contra um 
get '/score_single' do
  erb :score_single
end

post '/score_single' do
  p "Vencedor: #{params[:vencedor]} | Tempo da partida: #{params[:tempo]}"
 
  $partida += {
    'set' => params[:set],
    'tempo' => params[:tempo],
    'jogador_a' => params[:jogador_a],
    'jogador_b' => params[:jogador_b],
    'pnt_jogador_a' => params[:pnt_jogador_a],
    'pnt_jogador_b' => params[:pnt_jogador_b]
  }
  erb :score_single
end

#DUPLAS ############################################################
#página de duplas
get '/duplas' do 
    @duplas = $duplas_grupoA + $duplas_grupoB
    erb :duplas  
end

#mostra pontuação para as duplas
get '/score_duplas' do
  @duplas = $duplas_grupoA + $duplas_grupoB
  erb :score_duplas
end

post '/score_duplas' do
 p "Jogadores: #{params[:jogador_b]} ==== #{params[:jogador_a]}"
 p "Vencedor: #{params[:vencedor]} | Tempo da partida: #{params[:tempo]}"
 
  @duplas = [params[:set], params[:tempo], params[:jogador_a], params[:jogador_b], params[:pnt_jogador_a], params[:pnt_jogador_b]];
  
  erb :score_duplas
end
