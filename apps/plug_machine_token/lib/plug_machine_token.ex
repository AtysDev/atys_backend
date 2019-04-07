defmodule PlugMachineToken do
  alias JOSE.{JWK, JWS, JWT}
  alias AtysApi.{Errors, Responder}
  import Plug.Conn
  require Errors

  defmodule Issuer do
    @type path :: :wildcard | String.t()
    @type method :: String.t()
    @type issuer_name :: String.t()
    @type allowed_paths :: [{method, [path]}]
    @type issuers_paths :: %{required(issuer_name) => allowed_paths}

    @callback get_secret(String.t()) :: {:ok, String.t()} | {:error, atom()}
    @callback get_issuers_paths() :: issuers_paths

    @spec is_allowed?(Plug.Conn.t(), allowed_paths) :: boolean()
    def is_allowed?(%Plug.Conn{method: method, path_info: conn_path}, allowed_paths \\ []) do
      Enum.any?(allowed_paths, fn
        {^method, allowed_path} ->
          route_matches?(conn_path: conn_path, allowed_path: allowed_path)

        _ ->
          false
      end)
    end

    @spec route_matches?(conn_path: [String.t()], allowed_path: path) :: boolean
    defp route_matches?(conn_path: conn_path, allowed_path: allowed_path)
         when length(conn_path) != length(allowed_path),
         do: false

    defp route_matches?(conn_path: conn_path, allowed_path: allowed_path) do
      Enum.zip(conn_path, allowed_path)
      |> Enum.all?(fn
        {a, b} when a == b -> true
        {_a, :wildcard} -> true
        _ -> false
      end)
    end
  end

  @jws JWS.from_map({%{alg: :jose_jws_alg_hmac}, %{"alg" => "HS256", "typ" => "JWT"}})
  @algorithms ["HS256"]

  @spec init(keyword()) :: %{issuer: module(), issuers_paths: Issuer.issuers_paths()}
  def init(options) do
    issuer = Keyword.fetch!(options, :issuer)
    issuers_paths = apply(issuer, :get_issuers_paths, [])
    %{issuer: issuer, issuers_paths: issuers_paths}
  end

  def call(conn, %{issuer: issuer, issuers_paths: issuers_paths}) do
    with {:ok, auth_header} <- get_authorization(conn),
         {:ok, issuer_name} <- get_unverified_issuer(auth_header),
         :ok <- validate_issuer_path(conn, issuer_name, issuers_paths),
         {:ok, issuer_secret} <- get_issuer_secret(issuer, issuer_name),
         :ok <- validate_issuer_secret(issuer_secret),
         jwk <- JWK.from_oct(issuer_secret),
         {:ok, _jwt} <- validate_authorization(auth_header, jwk: jwk, issuer: issuer_name) do
      conn
    else
      error -> Responder.handle_error(conn, error, send_response: true) |> halt()
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
      [_value] -> unauthorized(:authorization_header_not_bearer)
      [_value | _values] -> unauthorized(:too_many_authorization_headers)
      _ -> unauthorized(:missing_authorization_header)
    end
  end

  defp get_unverified_issuer(auth_header) do
    try do
      case JWT.peek(auth_header) do
        %JWT{fields: %{"iss" => issuer}} -> {:ok, issuer}
        _ -> unauthorized(:invalid_authorization_header)
      end
    rescue
      _e -> unauthorized(:invalid_authorization_header)
    end
  end

  defp validate_issuer_path(conn, issuer_name, issuers_paths) do
    issuer_paths = Map.get(issuers_paths, issuer_name, [])

    case PlugMachineToken.Issuer.is_allowed?(conn, issuer_paths) do
      true -> :ok
      false -> unauthorized(:issuer_not_authorized)
    end
  end

  defp get_issuer_secret(issuer_mod, issuer_name) do
    case apply(issuer_mod, :get_secret, [issuer_name]) do
      {:ok, secret} -> {:ok, secret}
      {:error, error} -> unauthorized(error)
      _ -> unauthorized(:invalid_issuer_callback_response)
    end
  end

  defp validate_issuer_secret(<<_rest::size(256)>>), do: :ok
  defp validate_issuer_secret(_), do: unauthorized(:invalid_issuer_secret)

  defp validate_authorization(auth_header, jwk: jwk, issuer: issuer) do
    case JWT.verify_strict(jwk, @algorithms, auth_header) do
      {true, %JWT{fields: %{"iss" => ^issuer, "exp" => _exp}} = jwt, @jws} ->
        validate_expiration(jwt)

      {true, %JWT{fields: %{"iss" => ^issuer}} = jwt, @jws} ->
        {:ok, jwt}

      _ ->
        unauthorized(:bad_signature)
    end
  end

  defp validate_expiration(%JWT{fields: %{"exp" => exp}} = jwt) do
    with {:ok, expires_at} <- DateTime.from_unix(exp),
         :lt <- DateTime.compare(DateTime.utc_now(), expires_at) do
      {:ok, jwt}
    else
      _ -> unauthorized(:bad_signature)
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

  defp unauthorized(details), do: {:error, Errors.reason(:unauthorized), %{details: details}}
end
