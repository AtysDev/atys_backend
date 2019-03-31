# Auth

Web endpoint to create and log into an account

## Usage


### Creating an account

```bash
curl -H "Content-Type: application/json" --data '{"data":{"email":"myemail8@atys.dev","password":"foobar"}}' -v http://localhost:4001/register
 ```

### Confirming the email confirmation token
```bash
curl -H "Content-Type: application/json" --data '{"data":{"token":"TOKEN_GOES_HERE"}}' -v http://localhost:4001/confirm
```

### Logging in with your username & password
```bash
curl -H "Content-Type: application/json" --data '{"data":{"email":"myemail8@atys.dev","password":"foobar"}}' -v http://localhost:4001/login
```

### Triggering a password reset
```bash
curl http://localhost:4001/password/reset?email=myemail8@atys.dev
```

### Resetting your password
```bash
curl -H "Content-Type: application/json" --data '{"data":{"token":"TOKEN_GOES_HERE","password":"foobar"}}' -v http://localhost:4001/reset
```

As a reminder, these values require the `Content-Type=application/json` header to be sent.