defmodule AtysApi.Service.Project do
  alias AtysApi.{Errors, Request}
  require Errors

  def create_project(%{auth_header: auth_header, request_id: request_id, token: token, name: name}) do
    url = Application.get_env(:atys_api, :project_url)

    data = %{
      token: token,
      name: name
    }

    opts = [
      headers: [
        {"Authorization", auth_header}
      ],
      method: :post,
      data: data,
      expected_failures: [
        Errors.reason(:unauthorized),
        Errors.reason(:item_not_found)
      ]
    ]
    Request.send(url, request_id, opts)
  end
end
