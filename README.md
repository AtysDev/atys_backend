# Token

Web endpoint to get and set expiring tokens

## Usage

### Setting a token value

```elixir
AtysApi.Token.create_token(%{auth_header: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww", request_id: 1, user_id: 42})
```

### Retrieving a token value.
With the cache key returned from a POST request (see above), you can query that value by making a GET request with a query param of v= where v is the cache key

```bash
AtysApi.Token.get_user_id(%{auth_header: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww", request_id: 1, token: "TOKEN_GOES_HERE})
```
