defmodule SecretParserTest do
  alias Token.SecretsParser
  use ExUnit.Case, async: true

  test "Parses valid secrets" do
    auth_secret = Base.url_encode64(<<1::256>>)
    other_secret = Base.url_encode64(<<2::256>>)
    secrets = %{
      "auth" => auth_secret,
      "other" => other_secret
    }

    expected = %{
      "auth" => <<1::256>>,
      "other" => <<2::256>>
    }

    assert {:ok, ^expected}= Jason.encode!(secrets) |> SecretsParser.parse()
  end

  test "Throws an error when secrets is nil" do
    assert {:error, :secrets_string_not_json} = SecretsParser.parse(nil)
  end

  test "Throws an error when secrets isn't json" do
    assert {:error, :secrets_string_not_json} = SecretsParser.parse("not a json")
  end

  test "Throws an error when secrets isn't a map" do
    assert {:error, :secrets_string_not_json} = SecretsParser.parse("[]")
  end

  test "Throws when the secret isn't url encoded" do
    assert {:error, :secret_not_url_base64} = Jason.encode!(%{"auth" => "not!encoded"})
      |> SecretsParser.parse()
  end

  test "Throws an error when the secret isn't 256 bits" do
    auth_secret = Base.url_encode64(<<1::128>>)
    assert {:error, :incorrect_secret_size} = Jason.encode!(%{"auth" => auth_secret})
      |> SecretsParser.parse()
  end
end
