defmodule API do
  @moduledoc """
  Documentation for API.
  """

  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/search" do
    conn = fetch_query_params(conn)
    apps = AppStore.search(conn.params["term"], conn.params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(apps))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
