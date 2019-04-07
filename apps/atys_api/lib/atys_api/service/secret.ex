defmodule AtysApi.Service.Secret do
  require AtysApi.Errors
  alias AtysApi.{Errors, Request}

  def create_machine_key(%{
        auth_header: auth_header,
        request_id: request_id,
        project_id: project_id,
        key: key
      }) do
    url = Application.get_env(:atys_api, :secret_url)

    data = %{
      project_id: project_id,
      key: key
    }

    opts = [
      headers: [
        {"Authorization", auth_header}
      ],
      method: :post,
      data: data
    ]

    Request.send(url, request_id, opts)
  end

  def get_machine_key(%{auth_header: auth_header, request_id: request_id, id: id}) do
    url =
      Application.get_env(:atys_api, :secret_url)
      |> URI.merge("/#{id}")
      |> to_string()
      |> URI.encode()

    opts = [
      headers: [
        {"Authorization", auth_header}
      ],
      expected_failures: [
        Errors.reason(:item_not_found)
      ]
    ]

    Request.send(url, request_id, opts)
  end

  def delete_machine_key(%{auth_header: auth_header, request_id: request_id, id: id}) do
    url =
      Application.get_env(:atys_api, :secret_url)
      |> URI.merge("/#{id}")
      |> to_string()
      |> URI.encode()

    opts = [
      headers: [
        {"Authorization", auth_header}
      ],
      method: :delete
    ]

    Request.send(url, request_id, opts)
  end
end
