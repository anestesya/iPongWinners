#programa feito para meu ipod
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

require 'rubygems'
require 'sinatra'
require 'twitter'

#variável global com os jogadores
$jogadores = ['tadeu', 'daniel', 'mateus', 'brahim', 'heber', 'renan', 'bruno', 'laerte',
               'jandira', 'gledston', 'cris', 'pedro', 'alessandro', 'Helder'];

#página index.
get '/' do
  erb :index
end


#página de duplas
get '/duplas' do 
    @camp = 'Ping Pong - Guenka Software'
    @jogadorA = $jogadores[rand(8)]; @jogadorB = $jogadores[rand(8)]
    @resultA = @resultB = 0
    erb :duplas  
end

#página de um contra um 
get '/single' do
   erb :single
end

#mostra pontuação para as duplas
get '/score_duplas' do
  erb :score_duplas
end

#mostra pontuação para o um contra um 
get '/score_single' do
  erb :score_single
end 