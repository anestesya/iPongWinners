#modelo de dados baseados em ORC, para utilizar com a BIG TABLE
#A Big Table é uma base de dados distribuída feita pelos engenheiros
#do google e tem por objetivo manipular quantidades enormes de dados.
#autor: tadeu gaudio anestesya.posterous.com 
#email: anestesya@gmail.com
require 'rubygems'
require 'dm-core'

#Configura a gem DataMapper para usar o sistema de armazenamendo App Engine
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "appengine://auto")
DataMapper::Model.raise_on_save_failure = true

class Planilha
  include DataMapper::Resource
  
  property :planilha_id,        Serial
  property :planilha_uri,       String
  property :planilha_timestamp, Time
  property :planilha_conteudo,  Text
  
end#fim da classe Planilha

class Usuario
  include DataMapper::Resource
  
  has n, :partidas
  
  property :user_id,      Integer
  property :user_name,    String
  property :user_email,   String
  property :user_twitter, String
  
end#fim da classe usuario

class Partida
  include DataMapper::Resource
  
  has n, :tempos #associação 1 para muitas partidas (one-to-many)
  
  property :partida_id,          Integer
  property :partida_dia,         Date
  property :partida_hora,        DateTime
  property :partida_tima_a,      String
  property :partida_time_b,      String
  property :partida_tempos,      String
  property :partida_duracao,     Time
  property :partida_resultado,   String
  belongs_to :usuario
  
end#fim da classe partida

class Tempo 
  include DataMapper::Resource
  belongs_to :partida #significa que pode-se ter varias clases dessa na partida
  property :tempos_id,       String #essa chave deve ser formada 
                                    #partida_id.partida_tima_a.partida_time_b.id_deste_tempo
  property :tempos_duracao,  Time
end#fim da classe tempos