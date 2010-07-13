#arquivo que mostra o layout das tabelas
#ele é responsável por organizar os resultados.

require 'rubygems'
require 'sinatra'
require 'erb'

class Tabela
  get '/' do
    @yield = 'tadeu'
    erb :index
  end
end