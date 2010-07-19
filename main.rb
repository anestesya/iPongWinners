#programa feito para meu ipod
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

require 'rubygems'
require 'sinatra'
require 'twitter'

#variável global com os jogadores
$jogadores = ['tadeu', 'daniel', 'mateus', 'brahim', 'heber', 'renan', 'bruno', 'laerte',
               'jandira', 'gledston', 'cris', 'pedro', 'alessandro', 'Helder', 'joao paulo'];
#nome do campeonato
$camp = 'Ping Pong - Guenka Software'

#página index.
get '/' do
  erb :index
end

#página de jogadores 
get '/players' do 
 erb :players 
end

#página de duplas
get '/duplas' do 
    
    @duplas = Array.new(8)
    
    (0..9).each do |i| 
      if i+1 == 10 
        i= 9
      end
      @duplas[i] = [$jogadores[i], $jogadores[i+1]]
    end
 
    @jogadorA = $jogadores[rand(8)]; @jogadorB = $jogadores[rand(8)]
    @resultA = @resultB = 0
    erb :duplas  
end

#página de um contra um i
get '/single' do
   erb :single
end

#mostra pontuação para as duplas
get '/score_duplas' do
   @duplas = Array.new(8)
    
    (0..9).each do |i| 
      if i+1 == 10 
        i= 9
      end
      @duplas[i] = [$jogadores[i], $jogadores[i+1]]
    end
  erb :score_duplas
end

#mostra pontuação para o um contra um 
get '/score_single' do
  erb :score_single
end