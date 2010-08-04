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
   user_senha = File.readlines "lock.txt"; feed_path = DIR_XML_FILES+"feed.xml";
   $gc = GoogleConnect.new 'wise', 'ClientLogin', user_senha[0], user_senha[1]
   $feed = $gc.get_sheets
   if File.exist? feed_path
      feed = File.open feed_path, 'wb'
      #pega hora de criação do arquivo
      hora_de_acesso = feed.atime
      hora_atual = Time.now

      #se a tiver passado mais de 10min da criação do arquivo, cria um novo feed
      acesso = hora_atual.min.to_i - hora_de_acesso.min.to_i
      if acesso > 10
        p "Pode gravar um arquivo novo. Passaram-se: #{acesso} da criação do arquivo"
        feed.close
        feed = File.delete feed_path
        if feed == 1
          feed = File.new feed_path, "w+"
          feed.puts $feed
          feed.close
        end
      end #fim do atualiza arquivo
   else
     feed = File.new feed_path, "w+"
     p "Arquivo criado: #{$feed}"
     feed.puts $feed
     feed.close
   end
  
   $jogadores = $feed.get_users("")
   criaListaJogadores = Jogadores.new DIR_XML_FILES + "participantes.xml"
   criaListaJogadores.add_jogadores $jogadores
   $duplas = $feed.get_users("duplas")
   p "Arquivo a ser criado para as duplas #{DIR_XML_FILES} + duplas.xml"
   criaListaDuplas = Jogadores.new DIR_XML_FILES + "duplas.xml"
   criaListaDuplas.add_jogadores $duplas
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
      if File.exist? DIR_XML_FILES + "participantes.xml"
        listaJogadores = Jogadores.new DIR_XML_FILES + "participantes.xml"
        $jogadores =  listaJogadores.get_participantes
      else
        init
      end
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
  if $feed.empty?
    init
  end
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
  if $jogadores.empty?
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
