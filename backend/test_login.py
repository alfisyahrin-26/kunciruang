import urllib.request
import json
import urllib.error

try:
    data = json.dumps({'username': 'admin@gmail.com', 'password': 'password'}).encode()
    req = urllib.request.Request('http://localhost:8080/api/auth/login', data=data, headers={'Content-Type': 'application/json'})
    response = urllib.request.urlopen(req)
    print("Success:", response.read().decode())
except urllib.error.HTTPError as e:
    print("Error:", e.code)
    print(e.read().decode())
