defmodule AtysApi.Service.Token do
  require AtysApi.Errors
  alias AtysApi.{Errors, Request}

  def create_token(%{auth_header: auth_header, request_id: request_id, user_id: user_id}) do
    url = Application.get_env(:atys_api, :token_url)

    data = %{
      user_id: user_id
    }

    opts = [
      headers: [
        {"Authorization", auth_header}
      ],
      method: :post,
      expected_failures: [
        Errors.reason(:cache_full)
      ],
      data: data
    ]

    Request.send(url, request_id, opts)
  end

  def get_user_id(%{auth_header: auth_header, request_id: request_id, token: token}) do
    url = Application.get_env(:atys_api, :token_url)

    data = %{
      token: token
    }

    opts = [
      headers: [
        {"Authorization", auth_header}
      ],
      method: :get,
      expected_failures: [
        Errors.reason(:item_not_found)
      ],
      data: data
    ]

    Request.send(url, request_id, opts)
  end
end
