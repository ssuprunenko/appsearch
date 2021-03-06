defmodule API do
  @moduledoc """
  Documentation for API.
  """

  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, "<h1 style='text-align:center;margin-top:50px;'>Appsearch</h1>")
  end

  get "/search" do
    conn = fetch_query_params(conn)
    apps = API.Apps.search(conn.params["term"], conn.params)

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "public, max-age=86400")
    |> send_resp(200, Poison.encode!(apps, fields: conn.params["fields"]))
  end

  # App Store
  get "/itunes/search" do
    conn = fetch_query_params(conn)
    apps = AppStore.search(conn.params["term"], conn.params)

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "public, max-age=86400")
    |> send_resp(200, Poison.encode!(apps, fields: conn.params["fields"]))
  end

  get "/itunes/lookup" do
    conn = fetch_query_params(conn)
    app = AppStore.lookup(conn.params["id"])

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "public, max-age=604800")
    |> send_resp(200, Poison.encode!(app, fields: conn.params["fields"]))
  end

  # Google Play
  get "/google/search" do
    conn = fetch_query_params(conn)
    apps = GooglePlay.search(conn.params["term"], conn.params)

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "public, max-age=86400")
    |> send_resp(200, Poison.encode!(apps, fields: conn.params["fields"]))
  end

  get "/google/lookup" do
    conn = fetch_query_params(conn)
    app = GooglePlay.lookup(conn.params["id"])

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "public, max-age=604800")
    |> send_resp(200, Poison.encode!(app, fields: conn.params["fields"]))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
