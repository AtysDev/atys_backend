# PlugMachineToken

Plug to ensure that a request is called from an authorized machine.

## Installation

```elixir
{:plug_machine_token, git: "git@github.com:AtysDev/plug_machine_token.git", branch: "master"}
```

## Definitions
**Request Server**: The backend server making the outgoing request.
  
**Response Server**: The server that handles the request. We want to only respond if the request comes from the request server

**machine_token**: A JWT token that is signed and passed in the request via an authorization header
  
**secret**: A 256 bit secret used to generate the machine token

## Usage

The flow works like this:
1. Offline: Generate a 256 bit secret
2. Save the key in the server process, to be accessed by the callback (described later)
3. Generate a machine token using the following snippet and save that in the request server:
```elixir
secret = :crypto.strong_rand_bytes(32)
PlugMachineToken.create_machine_token(secret, %{name: "request_server_name_goes_here"})
``` 
4. When making a request, pass the machine_token as an `authorization` header in the request server
5. In the response server, add the plug to your pipeline before handling the response.

```elixir
defmodule MachineKeyStore do
  def get(issuer) do
    case signer do
        "valid_server_1" -> {:ok, <<1::256>>}
        "valid_server_2" -> {:ok, <<99::256>>}
        _ -> {:error, :unrecognized_signer}
      end
  end
end
defmodule MyResponseServer do
  alias Plug.Conn
  use Plug.Builder

  plug PlugMachineToken, get_issuer_secret: &MachineKeyStore.get/1

  # Rest of your plug pipeline here
```

Note that unfortunately, due to the way that the plug macros work, you need to define your get_issuer_secret function in a separate module instead of either a local function or as a anonymous function.