require 'rubygems'
require 'active_support'
require 'net/http'
require 'net/https'
http = Net::HTTP.new('api.twitter.com', 443)
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.start
request = Net::HTTP::Post.new('/1/statuses/update.xml')
request.basic_auth 'o_clockr', '1n0d3_50t'
annotations = [{'website' => {'tadeuluis' => 'http://anestesya.posterous.com'}}]
request.set_form_data 'status'      => "test #{Time.now.to_i}",
                      'annotations' => annotations.to_json
p annotations.to_json
response = http.request(request)
puts response.body
