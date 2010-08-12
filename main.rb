#Feito para ser usado com iPhone/iPad, Android ou Palm-pre... ou qualquer
#dispositivo que tenha acesso web.
#ele vai armazenar os resultados do Campeonato de Ping Pong da Guenka
#autor: anesteysa@gmail.com

require 'rubygems'
require 'sinatra'
require 'pp'

#libs do programa
require 'jogadores'
require 'google_connect'

DIR_XML_FILES = "public/files/xml/"

#variável global com os jogadores
$feed = ""; $feed_path = DIR_XML_FILES+"feed.xml";

 #inicializa a conexãe e busca jogadores.
 def init
   p "Inicializando........"
   user_senha = File.readlines "lock.txt";
   $gc = GoogleConnect.new 'wise', 'ClientLogin', user_senha[0], user_senha[1]
 end

  #Verifica se o arquivo de feed existe, caso ele exista verifica a hora de criacao
  # se for maior que 10 min cria um novo retorna o Feed.
  def verifica_criacao_arquivos
      
      if File.exist? $feed_path
        #pega hora de criação do arquivo
        feed = File.open $feed_path, 'wb'
        hora_de_acesso = feed.atime
        hora_atual = Time.now
        acesso = hora_atual.min.to_i - hora_de_acesso.min.to_i
       
        #atualiza arquivo se passado mais de 10min da criação do arquivo, cria um novo feed
        if acesso > 0
             p "Pode gravar um arquivo novo. Passaram-se: #{acesso} da criação do arquivo"
             apagar = File.delete $feed_path
             apagar = File.delete DIR_XML_FILES+"participantes.xml"
             apagar = File.delete DIR_XML_FILES+"duplas.xml"
             p "Resultado da remocao do arquivo:           [#{apagar}]"
                 if apagar == 1
                    init #inicializa a conexão com o google
                    $feed = $gc.get_sheets
                    novo_feed = File.new $feed_path, "wb"
                    novo_feed.puts $feed.get_doc
                    novo_feed.close
                    participantes $feed
                 end
        else 
          p "O arquivo de feed ja esta atualizado"
        end

      #se o arquivo não existir
      else
        #vai criar o arquivo pela primeira vez.
        p "Criando arquivos de feed pela primeira vez....."
        init #inicializa conexão com o google
        feed = $gc.get_sheets
        
        novo_feed = File.new $feed_path, "wb"
        p "#{$feed_path}:                                      [OK]"
        novo_feed.puts feed.get_doc
        novo_feed.close
               
        participantes feed
        return File.open $feed_path
      end
  end #fim do verifica_criacao_arquivo

#Recebe um objeto do tipo FeedParser.
 #gera lista de feed para participantes e a modalidade de duplas.
 def participantes(feedParser) 
   feed_parser = feedParser
   
   jogadores = feed_parser.get_users("")
   criaListaJogadores = Jogadores.new DIR_XML_FILES + "participantes.xml"
   criaListaJogadores.add_jogadores jogadores
   p "#{DIR_XML_FILES}participantes.xml                   [OK]"
        
   duplas = feed_parser.get_users("duplas")
   criaListaDuplas = Jogadores.new DIR_XML_FILES + "duplas.xml"
   criaListaDuplas.add_jogadores duplas
   p "#{DIR_XML_FILES}duplas.xml                          [OK]"
 end#fim do método de iniciar


###############################################################################
###### SERVER #################################################################
###############################################################################
#página index.
get '/' do
   #se não existe feed, não existe informação
   #então inicializar a coneção com o Google.
   verifica_criacao_arquivos
   erb :index
end

#página de jogadores 
get "/players" do
      
      if File.exist? DIR_XML_FILES + "participantes.xml"
        listaJogadores = Jogadores.new DIR_XML_FILES + "participantes.xml"
        @jogadores =  listaJogadores.get_participantes
      else
        verifica_criacao_arquivos
      end
    erb :players 
end

#página de um contra um i
get '/single' do
   if File.exist? DIR_XML_FILES + "participantes.xml"
        listaJogadores = Jogadores.new DIR_XML_FILES + "participantes.xml"
        @jogadores =  listaJogadores.get_participantes
      else
        verifica_criacao_arquivos
   end
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
     
   erb :score_single
end


#DUPLAS ############################################################
#página de duplas
get '/duplas' do 
      if File.exist? DIR_XML_FILES + "duplas.xml"
        listaJogadores = Jogadores.new DIR_XML_FILES + "duplas.xml"
        @duplas =  listaJogadores.get_participantes
        pp @duplas
      else
        verifica_criacao_arquivos
      end
    erb :duplas  
end

#mostra pontuação para as duplas
get '/score_duplas' do
    if File.exist? DIR_XML_FILES+ "duplas.xml"
        listaJogadores = Jogadores.new DIR_XML_FILES + "duplas.xml"
        @score_duplas =  listaJogadores.get_participantes
      else
        verifica_criacao_arquivos
      end
  erb :score_duplas
end

post '/score_duplas' do
  p "Jogadores: #{params[:jogador_b]} ==== #{params[:jogador_a]}"
  p "Vencedor: #{params[:vencedor]} | Tempo da partida: #{params[:tempo]}"
 
  @duplas = [params[:set], params[:tempo], params[:jogador_a], params[:jogador_b], params[:pnt_jogador_a], params[:pnt_jogador_b]];
  
  erb :score_duplas
end
