# Example of using User Defined Fields
import requests

auth = ('8008966', 'MgvfuwWMGUJl')
url = 'https://gwapi.demo.securenet.com/api'


# Call the WPT API, return the response
def get(path, auth):
    response = requests.get(url + path,
                            headers={"content-type": "application/json"},
                            auth=auth,
                            verify=True)
    print_response(response)
    if response.ok:
        return response
    else:
        quit()


# Call the WPT API, return the response
def post(path, input, auth):
    response = requests.post(url + path,
                             headers={"content-type": "application/json"},
                             auth=auth,
                             json=input,
                             verify=True)
    print_response(response)
    if response.ok:
        return response
    else:
        quit()


def print_response(response):
    print("HTTP Status Code: {}".format(response.status_code))
    json = response.json()
    if (response.ok):
        print("success: {}".format(json["success"]))
        print("result: {}".format(json["result"]))
        print("message: {}".format(json["message"]))


# Create a new transation with UDF data
auth_data = {
    'amount': 1.23,
    'card': {
        'number': '4111111111111111',
        'cvv': '123',
        'expirationDate': '07/2018',
    },
    'developerApplication': {
        'developerId': 12345678,
        'version': '1.2'
    },
    'extendedInformation': {
        'userDefinedFields': [
            {'udfName': 'udf1', 'udfValue': 'One'},
            {'udfName': 'udf2', 'udfValue': 'Green'}
        ]
    }
}
print("Sending charge request with UDF's")
response = post('/payments/charge', auth_data, auth)
print("transactionId: {}".format(response.json()["transaction"]["transactionId"]))
tranid = response.json()['transaction']['transactionId']

# Fetch the transaction
search_data = {
    'transactionId': tranid,
    'developerApplication': {
        'developerId': 12345678,
        'version': '1.2'
    },
}
print("Retrieving details for transaction id: {}".format(tranid))
response = post('/transactions/search', search_data, auth)
print('User Defined Fields:')
for udf in response.json()['transactions'][0]['userDefinedFields']:
    print('{}: {}'.format(udf['udfName'], udf['udfValue']))

# Create a customer with a UDF
cust_data = {
    'firstName': 'Fred',
    'lastName': 'Flintstone',
    'developerApplication': {
        'developerId': 12345678,
        'version': '1.2'
    },
    'userDefinedFields': [
        {'udfName': 'udf1', 'udfValue': 'Wilma'},
    ]
}
print("Adding a customer with UDF's")
response = post('/customers', cust_data, auth)
print("customerId: {}".format(response.json()["customerId"]))
custid = response.json()['customerId']

# Fetch the transaction
print("Retrieving details for customer id: {}".format(custid))
response = get('/customers/' + custid, auth)
print('User Defined Fields:')
for udf in response.json()['vaultCustomer']['userDefinedFields']:
    print('{}: {}'.format(udf['udfName'], udf['udfValue']))
