#classe em ruby para conectar no google spreadsheet
#autor: tadeu luis anestesya@gmail.com
#require 'xmlsimple'
require 'net/https'
require 'appengine-apis/urlfetch'
require 'rexml/document'
require 'pp'

#classes locais minhas
require 'feed_parser'
require 'dm-core'
require 'model'

class GoogleConnect
  #declara a variável constante para a lib net utilizada pelo gogle app engine   
  Net::HTTP = AppEngine::URLFetch::HTTP
  
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
      chave = feed.get_spreadsheet_key
      uri_planilha = "http://spreadsheets.google.com/feeds/worksheets/#{chave}/private/full"
      pp "URI: #{uri_planilha}"
      planilha_doc = get_feed(uri_planilha, @headers)
      planilha_doc = FeedParser.new planilha
      
      #cria um resourse seguindo o 'datamodel'
      @dt_planilha = Planilha.create(
          :planilha_id => chave,
          :planilha_uri => uri_planilha,
          :planilha_conteudo => planilha.body
      )
      @dt_planilha.save
            
      #pega a planilha iPongWinners  
      @url_feed_list = planilha_doc.get_url_feed "cellFeed"
      @n_p = get_feed(@url_feed_list, @headers)
      @n_p = FeedParser.new @n_p
      
      @n_p
   end 
   
   ################################
   ##métodos de escrita.
   
   #pega a versão da celula que vai ser atualizada
   #OBS: cada celula tem sua própria versão.
   def get_version_string(uri, headers=nil)
      response = get_feed(uri, headers)
      xml = REXML::Document.new response.body
      edit_link = REXML::XPath.first(xml, '//[@rel="edit"]')
      edit_link_href = edit_link.attribute('href').to_s
      return edit_link_href.split(/\//)[10]
   end
  
   #posta no Google SpreadSheets
   ## para postagem existem 2 métodos também 
   ## o de ListFeed e CellFeed, porém o método de post abaixo
   ## é único para os dois, pois o que diferencia é a URL de POST.
   #http://code.google.com/intl/pt-BR/apis/spreadsheets/articles/using_ruby.html#posting
   def post(uri, data, headers)
     @uri_post = URI.parse(uri)
     https = Net::HTTP.new(@uri_post.host, @uri_post.port)
      return https.post(@uri_post.path, data, headers)
   end
   
   
   #Atualiza por Bacth várias celulas atualizadas de uma unica chamada.
   def batch_update(batch_data, cellfeed_uri)
        headers = @headers
        batch_uri = cellfeed_uri+"/batch"
        
        #cria pedaço do feed para ser atualizado
        batch_request = '<?xml version="1.0" encoding="utf-8" ?>' <<
            ' <feed xmlns="http://www.w3.org/2005/Atom" xmlns:batch="http://schemas.google.com/gdata/batch" xmlns:gs="http://schemas.google.com/spreadsheets/2006" xmlns:gd="http://schemas.google.com/g/2005">' <<
            "<id>#{cellfeed_uri}</id>";
            
                      #cria cada linha da planinlha
                      batch_data.each do |batch_request_data|
                        version_string = get_version_string(cellfeed_uri + '/' + batch_request_data[:cell_id], headers)
                        data = batch_request_data[:data]
                        batch_id = batch_request_data[:batch_id]
                        cell_id = batch_request_data[:cell_id]
                        row = batch_request_data[:cell_id][1,1]
                        column = batch_request_data[:cell_id][3,2]
                        edit_link = cellfeed_uri + '/' + cell_id + '/' + version_string
                        
                        
                        batch_request << "<entry>" << 
                                    "<batch:id>#{batch_id}</batch:id>" <<
                                    '<batch:operation type="update" />' <<
                                    "<id>#{cellfeed_uri}/#{cell_id}</id>" <<
                                    '<link href="' << "#{edit_link}" << '" rel="edit" type="application/atom+xml" />' <<
                                    '<gs:cell col="' << "#{column}" << '" ' << 'inputValue="' << "#{data}" << '" row="' << "#{row}" << '"/>' <<
                                    '</entry>';
                      end#fim do each

            batch_request << '</feed>' #fim do feed, agora é só postar
            headers["Content-Type"] = "application/atom+xml"
            
            return post(batch_uri, batch_request, headers)
   end#fim do metodo
     
  ##fim da classe GoogleConnect
end