#!/usr/bin/python
# Example of calling SecureNet Charge API from Python
import requests

secureNetId = '8008966'  # Replace with your own ID
secureKey = 'MgvfuwWMGUJl'  # Replace with your own Key
url = 'https://gwapi.demo.securenet.com/api/Payments/Charge'
data = {
    'amount': 1.23,
    'check': {
        'firstName': 'Fred',
        'lastName': 'Flintstone',
        'routingNumber': 222371863,
        'accountNumber': 123456
    },
    'developerApplication': {
        'developerId': 12345678,
        'version': '1.2'
    }
}

print("Sending charge request")
response = requests.post(
    url,
    headers={"content-type": "application/json"},
    auth=(secureNetId, secureKey),
    json=data,
    verify=True)

print("HTTP Status Code: {0}".format(response.status_code))
if (response.ok):
    json = response.json()
    print("success: {0}".format(json["success"]))
    print("result: {0}".format(json["result"]))
    print("message: {0}".format(json["message"]))
    print("transactionId: {0}".format(json["transaction"]["transactionId"]))
