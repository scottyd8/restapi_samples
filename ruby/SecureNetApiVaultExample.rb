#!/usr/bin/ruby
# Example of calling SecureNet Vault API from Ruby
require 'net/http'
require 'uri'
require 'json'

def main
  url = 'https://gwapi.demo.securenet.com/api/' # Root URL for REST calls
  secureNetId = '9999999'                       # Replace with your own ID
  secureKey = 'xxxxxxxxxxxx'                    # Replace with your own Key

  # Step 1 - Create a customer
  puts "===== Create Customer ====="
  body = {
    firstName: 'Joe',
    lastName: 'Customer',
    phoneNumber: '512-122-1211',
    emailAddress: 'some@emailaddress.com',
    address: {
      line1: '123 Main St.',
      city: 'Austin',
      state: 'TX',
      zip: '78759'
    },
    company: 'Problem Unicorn',
    developerApplication: {
      developerId: 12345678,
      version: '1.2'
    }
  }
  cust_res = post(secureNetId, secureKey, body, url + 'customers')
  customer_id = cust_res["customerId"]
  puts "message: #{cust_res["message"]}"
  puts "customerId: #{customer_id}"

  # Step 2 - Add card to customer's vault
  puts "===== Create PaymentAccount ====="
  body = {
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
    developerApplication: {
      developerId: 12345678,
      version: '1.2'
    },
    accountDuplicateCheckIndicator: 0
  }
  account_res = post(secureNetId, secureKey, body, url + "customers/#{customer_id}/paymentmethod") 
  payment_id = account_res["vaultPaymentMethod"]["paymentId"]
  puts "message: #{account_res["message"]}"
  puts "paymentId: #{payment_id}"

  # Step 3 - Charge using the token
  puts "===== Sending charge using vaulted payment account ====="
  body = {
    amount: 11.00,
    paymentVaultToken: {
      customerId: customer_id,
      paymentMethodId: payment_id,
      paymentType: 'CREDIT_CARD'
    },
    developerApplication: {
      developerId: 12345678,
      version: '1.2'
    }
  }
  charge_res = post(secureNetId, secureKey, body, url + 'payments/charge') 
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

main                                         # Run the examples






