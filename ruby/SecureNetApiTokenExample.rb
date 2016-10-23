#!/usr/bin/ruby
# Example of calling SecureNet Token API from Ruby
require 'net/http'
require 'uri'
require 'json'

def main
  url = 'https://gwapi.demo.securenet.com/api/'      # Root URL for REST calls
  secureNetId = '99999999'                           # Replace with your own ID
  secureKey = 'xxxxxxxxxxxx'                         # Replace with your own Key
  publicKey = '237df3ce-f81a-4181-bfe6-17a94325c48e' # Replace with your own pubic key from VT

  # Step 1 - Create a temporary token
  puts "=== Sending token request ==="
  body = {
    publicKey: publicKey,
    card: {
      number: '4111111111111111',
      cvv: '123',
      expirationDate: '07/2018',
      address: {
        line1: '123 Main St.',
        city: 'Austin',
        state: 'TX',
        zip: '78759'
      }
    },
    extendedInformation: {
      typeOfGoods: 'PHYSICAL',
    },
    developerApplication: {
      developerId: 12345678,
      version: '1.2'
    },
    addToVault: false
  }
  token_res = post(secureNetId, secureKey, body, url + 'prevault/card')
  puts "message: #{token_res["message"]}"
  puts "token: #{token_res["token"]}"
  
  # Step 2 - Charge using the token
  puts "=== Sending charge using token ==="
  body = {
    amount: 11.00,
    paymentVaultToken: {
      paymentMethodId: token_res["token"],
      publicKey: publicKey
    },
    developerApplication: {
      developerId: 12345678,
      version: '1.2'
    }
  }
  charge_res = post(secureNetId, secureKey, body, url + 'payments/authorize')
  puts "result: #{charge_res["result"]}"
  puts "message: #{charge_res["message"]}"
  puts "transactionId: #{charge_res["transaction"]["transactionId"]}"
end  

# Simplify making a POST request
def post(secureNetId, secureKey, body, url)
  uri = URI.parse(url)                       # Parse the URI
  http = Net::HTTP.new(uri.host, uri.port)   # New HTTP connection
  http.use_ssl = true                        # Must use SSL!
  req = Net::HTTP::Post.new(uri.request_uri) # HTTP POST request 
  req.body = body.to_json                    # Convert hash to json string
  req["Content-Type"] = 'application/json'   # JSON body
  req["Origin"] = 'worldpay.com'             # CORS origin
  req.basic_auth secureNetId, secureKey      # HTTP basic auth
  res = http.request(req)                    # Make the call
  return JSON.parse(res.body)                # Convert JSON to hashmap
end

main                                         # Run the example
