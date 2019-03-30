# Secret

## Creating a new machine_key

```elixir
AtysApi.Service.Secret.create_machine_key(%{auth_header: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9qZWN0In0.cCv-qhkgjUzGlDk1QDckdq1WY5eNdm8ldkwgMswtjMg", request_id: "1", project_id: "613ad646-be72-465f-a749-5822e85e8a10", key: "my cool key"})
```

## Getting a machine_key

```elixir
AtysApi.Service.Secret.get_machine_key(%{auth_header: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2YXVsdCJ9.UAeEJ70l5YfyZ_4z_Qi4oD0U1En2ZdRZiKlEWsSUlRs", request_id: "1", id: "MACHINE_KEY_ID_HERE"})
```
