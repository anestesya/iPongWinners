#programa feito para meu ipod
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

#arquivo que mostra o layout das tabelas
#ele é responsável por organizar os resultados.

require 'rubygems'
require 'sinatra'
require 'twitter'

get '/' do
    
    @camp = 'Ping Pong - Guenka Software'
    @jogadorA = 'Tadeu'
    @jogadorB = 'Daniel'
    @resultA = @resultB = 0
    
    erb :index
end
