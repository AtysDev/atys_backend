defmodule AtysApi.Service.Secret do
  require AtysApi.Errors
  alias AtysApi.Request

  def create_machine_key(%{auth_header: auth_header, request_id: request_id, project_id: project_id, key: key}) do
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
end
