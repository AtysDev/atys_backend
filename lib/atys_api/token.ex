defmodule AtysApi.Token do
  require AtysApi.Errors
  alias AtysApi.{Errors, Request}

  def get_token(url, %{auth_header: auth_header, request_id: request_id, user_id: user_id}) do
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
end
