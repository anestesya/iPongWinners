#classe em ruby para conectar no google spreadsheet
#autor: tadeu luis anestesya@gmail.com
require 'xmlsimple'
require 'net/https'
require 'feed_parser'
require 'pp'

class GoogleConnect
  
  #CONSTANTES UTILIZADA NAS CONEXÔES
  GOOGLE_URL = 'www.google.com'
  GOOGLE_SSL_PORT = "443"
  GOOGLE_URL_FEED_PRIVATE = ''
  GOOGLE_AUTH_PATH = '/accounts/ClientLogin' #esse auth path é a forma de atutenticação que o google prove para aplicações instaladas
  GOOGLE_USER_FEED = 'http://spreadsheets.google.com/feeds/spreadsheets/private/full'
    
  #inicializa as variáveis de coneção
  def initialize(service, auth_type, user, password)
      @service = service
      @auth_type = auth_type
      @user = user
      @password = password
   end 

   #pega usuario, senha e autentica, caso positivo
   #retorna uma chave de autenticação para acesso dos serviços
   def get_authKey
     #monta dados enviados no POST
     meus_dados = 'accountType=HOSTED_OR_GOOGLE&Email=' << @user << '&Passwd='<< @password << '&service=' << @service
     @headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
     
      #faz requisição de autenticação
      @http = Net::HTTP.new(GOOGLE_URL, GOOGLE_SSL_PORT)
      @http.use_ssl = true
      
      resp, meus_dados = @http.post(GOOGLE_AUTH_PATH, meus_dados, @headers)
      #parseia o resultado e pega o token em caso positivo.
      auth_token = meus_dados[/Auth=(.*)/, 1]
      @headers["Authorization"] = "GoogleLogin auth=#{auth_token}"
   end

   #pega os feeds que o o usuário tem.
   #retorna um xml
   def get_feed(uri, headers=nil)
     @uri = URI.parse(uri)
        #pega todos os feeds
        Net::HTTP.start(@uri.host, @uri.port) do |http|
          return http.get(@uri.path, headers)
        end
   end
    
   #mostra o conteúdo do feed 
   def get_feed_item
     get_authKey
     feed = get_feed(GOOGLE_USER_FEED, @headers)
     @f = FeedParser.new feed
   end
   
   #pega o conteúdo de uma planilha específica
   def get_sheets
      feed = get_feed_item
      chave = @f.get_spreadsheet_key
      uri_planilha = "http://spreadsheets.google.com/feeds/worksheets/#{chave}/private/full"
      pp "URI: #{uri_planilha}"
      planilha = get_feed(uri_planilha, @headers)
      planilha = FeedParser.new planilha
      
      #pega a planilha iPongWinners  
      @url_feed_list = planilha.get_feed_cell_list_url
      @n_p = get_feed(@url_feed_list, @headers)
      @n_p = FeedParser.new @n_p
   end 
   
   ################################
   ##métodos de escrita.
   #posta no listFeed
   def post(uri, data, headers)
     @uri_post = URI.parse(uri)
     https = Net::HTTP.new(@uri_post.host, @uri_post.port)
      return https.post(@uri_post.path, data, headers)
   end
   
   #atualiza conteudo da linha
   def post_feedList
     @headers["Content-Type"] = "application/atom+xml"
     #adicionar nova linha
      nova_linha = '<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">' << 
                        '<gsx:language xmlns:gsx="http://schemas.google.com/spreadsheets/2006/extended">ruby</gsx:language>' << 
                        '<gsx:website xmlns:gsx="http://schemas.google.com/spreadsheets/2006/extended">http://ruby-lang.org</gsx:website>' << 
                   '</atom:entry>';
                   
      p nova_linha             
      post_response = post(@url_feed_list, nova_linha, @headers)
      p post_response.body
   end
   
  ##fim da classe GoogleConnect
end
