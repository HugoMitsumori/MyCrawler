require 'mechanize'


USERNAME = ARGV[0]
PASSWORD = ARGV[1]
URL = "https://extra2.bsgi.org.br"

agent = Mechanize.new
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#cert_store = OpenSSL::X509::Store.new
#cert_store.add_file 'cacert.pem'
#agent.cert_store = cert_store

#ca_path = File.expand_path 'cacert.pem'
#agent.agent.http.ca_file = ca_path


page = agent.get URL
puts page

