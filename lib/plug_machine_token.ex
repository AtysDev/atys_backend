defmodule PlugMachineToken do
  alias JOSE.{JWK, JWS, JWT}
  import Plug.Conn

  @type issuer_callback ::
          (String.t() -> {:ok, String.t()} | {:error, atom} | {:error, String.t()})

  @jws JWS.from_map({%{alg: :jose_jws_alg_hmac}, %{"alg" => "HS256", "typ" => "JWT"}})
  @algorithms ["HS256"]

  @spec init(keyword()) :: %{get_issuer_secret_fn: issuer_callback}
  def init(options) do
    callback = Keyword.fetch!(options, :get_issuer_secret)
    %{get_issuer_secret_fn: callback}
  end

  def call(conn, %{get_issuer_secret_fn: get_issuer_secret_fn}) do
    with {:ok, auth_header} <- get_authorization(conn),
         {:ok, issuer} <- get_unverified_issuer(auth_header),
         {:ok, issuer_secret} <- get_issuer_secret_fn.(issuer),
         :ok <- validate_issuer_secret(issuer_secret),
         jwk <- JWK.from_oct(issuer_secret),
         {:ok, _jwt} <- validate_authorization(auth_header, jwk: jwk, issuer: issuer) do
      conn
    else
      {:error, :invalid_issuer_secret} -> send_resp(conn, 500, "invalid_issuer_secret") |> halt()
      {:error, error} -> send_resp(conn, 403, Atom.to_string(error)) |> halt()
    end
  end

  def create_machine_token(secret, %{name: name, expires_at: expires_at}) do
    body = %{"iss" => name, "exp" => DateTime.to_unix(expires_at)}
    do_create_machine_token(secret, body)
  end

  def create_machine_token(secret, %{name: name}) do
    body = %{"iss" => name}
    do_create_machine_token(secret, body)
  end

  defp get_authorization(conn) do
    # cowboy req headers are always lowercase
    # https://github.com/ninenines/cowboy/blob/master/doc/src/manual/cowboy_req.headers.asciidoc
    case get_req_header(conn, "authorization") do
      ["Bearer " <> value] -> {:ok, value}
      [_value] -> {:error, :authorization_header_not_bearer}
      [_value | _values] -> {:error, :too_many_authorization_headers}
      _ -> {:error, :missing_authorization_header}
    end
  end

  defp get_unverified_issuer(auth_header) do
    try do
      case JWT.peek(auth_header) do
        %JWT{fields: %{"iss" => issuer}} -> {:ok, issuer}
        _ -> {:error, :invalid_authorization_header}
      end
    rescue
      _e -> {:error, :invalid_authorization_header}
    end
  end

  defp validate_issuer_secret(<<_rest::size(256)>>), do: :ok
  defp validate_issuer_secret(_), do: {:error, :invalid_issuer_secret}

  defp validate_authorization(auth_header, jwk: jwk, issuer: issuer) do
    case JWT.verify_strict(jwk, @algorithms, auth_header) do
      {true, %JWT{fields: %{"iss" => ^issuer, "exp" => _exp}} = jwt, @jws} -> validate_expiration(jwt)
      {true, %JWT{fields: %{"iss" => ^issuer}} = jwt, @jws} -> {:ok, jwt}
      _ -> {:error, :bad_signature}
    end
  end

  defp validate_expiration(%JWT{fields: %{"exp" => exp}} = jwt) do
    with {:ok, expires_at} <- DateTime.from_unix(exp),
    :lt <- DateTime.compare(DateTime.utc_now(), expires_at) do
      {:ok, jwt}
    else
      _ -> {:error, :bad_signature}
    end
  end

  defp do_create_machine_token(<<_rest::size(256)>> = secret, body) do
    jwk = JWK.from_oct(secret)

    jwt =
      JWT.sign(jwk, %{"alg" => "HS256"}, body)
      |> JWS.compact()
      |> elem(1)

    "Bearer " <> jwt
  end
end
