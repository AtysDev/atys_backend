# Auth

Web endpoint to create and log into an account

## Usage


### Creating an account

```bash
curl --data "email=myemail8@atys.dev&password=foobar" http://localhost:4001/register/
 ```

### Confirming the email confirmation token
```bash
curl --data "token=TOKEN_GOES_HERE" http://localhost:4001/confirm/
```

### Logging in with your username & password
```bash
curl --data "myemail8@atys.dev&password=foobar" http://localhost:4001/login/
```

### Triggering a password reset
```bash
curl http://localhost:4001/password/reset?email=myemail8@atys.dev
```

### Resetting your password
```bash
curl --data "token=YOUR_TOKEN_HERE&password=mycoolnewpassword" http://localhost:4001/password/reset
```

As a reminder, these values require the `Content-Type=application/x-www-form-urlencoded` header to be sent, which cURL does automatically.