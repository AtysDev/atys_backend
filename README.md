# Token

Web endpoint to get and set expiring tokens

##Usage

### Setting a token value
You need a machine token, and then to set a cache, send a POST request to / with post data of v={value to cache}

Returns: 200 & the cache key when successfull

```bash
 curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KMPAftLfdvY7uABGBpl21Aww" --data "v=hello" http://localhost:4000/
 ```

### Retrieving a token value.
With the cache key returned from a POST request (see above), you can query that value by making a GET request with a query param of v= where v is the cache key

```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhdXRoIn0.KZIiseeYISnFQXDFAIx9MPAftLfdvY7uABGBpl21Aww" http://localhost:4000/?v=A3Xiuwm3B2Aq_r8n32M7GZ-spJ9bSGFzjLeCW4Rm41-2
```