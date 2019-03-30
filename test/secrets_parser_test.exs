defmodule SecretParserTest do
  alias PlugMachineToken.SecretsParser
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

  @tag capture_log: true
  test "Throws an error when secrets is nil" do
    assert {:error, :unexpected} = SecretsParser.parse(nil)
  end

  @tag capture_log: true
  test "Throws an error when secrets isn't json" do
    assert {:error, :unexpected} = SecretsParser.parse("not a json")
  end

  @tag capture_log: true
  test "Throws an error when secrets isn't a map" do
    assert {:error, :unexpected} = SecretsParser.parse("[]")
  end

  @tag capture_log: true
  test "Throws when the secret isn't url encoded" do
    assert {:error, :unexpected} = Jason.encode!(%{"auth" => "not!encoded"})
      |> SecretsParser.parse()
  end

  @tag capture_log: true
  test "Throws an error when the secret isn't 256 bits" do
    auth_secret = Base.url_encode64(<<1::128>>)
    assert {:error, :unexpected} = Jason.encode!(%{"auth" => auth_secret})
      |> SecretsParser.parse()
  end
end
