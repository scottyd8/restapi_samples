#!/usr/bin/ruby
# Example of calling SecureNet Charge API from Ruby
require 'net/http'
require 'uri'
require 'json'

secureNetId = '9999999' # Replace with your own ID
secureKey = 'xxxxxxxxxxxx' # Replace with your own Key
url = 'https://gwapi.demo.securenet.com/api/Payments/Charge'
charge = {
  amount: 8.00,
  card: {
    number: '4111111111111111',
    cvv: '123',
    expirationDate: '07/2018',
    address: {
      company: 'Nov8 Inc',
      line1: '123 Main St.',
      city: 'Austin',
      state: 'TX',
      zip: '78759'
    }
  },
  extendedInformation: {
    typeOfGoods: 'PHYSICAL'
  },
  developerApplication: {
    developerId: 12345678,
    version: '1.2'
  }
}

uri = URI.parse(url)                       # Parse the URI
http = Net::HTTP.new(uri.host, uri.port)   # New HTTP connection
http.use_ssl = true                        # Must use SSL!
req = Net::HTTP::Post.new(uri.request_uri) # HTTP POST request 
req.body = charge.to_json                  # Convert hashmap to string
req["Content-Type"] = 'application/json'   # JSON body
req.basic_auth secureNetId, secureKey      # HTTP basic auth
res = http.request(req)                    # Make the call
res_body = JSON.parse(res.body)            # Convert JSON to hashmap

puts "http response code: #{res.code}"
puts "success: #{res_body["success"]}"
puts "result: #{res_body["result"]}"
puts "message: #{res_body["message"]}"
puts "transactionId: #{res_body["transaction"]["transactionId"]}"