defmodule AppStore.Search do
  use HTTPoison.Base

  @limit 10
  @expected_fields [:artworkUrl60, :trackCensoredName, :trackViewUrl]

  def call(term, params \\ %{}) do
    start()
    case get("search", [], params: process_params(params, term)) do
      {:ok, %HTTPoison.Response{body: body}} -> body
      {:error, _} -> []
    end
  end

  def process_params(params, term) do
    params
    |> Map.put(:term, term)
    |> Map.put(:entity, "software")
    |> Map.put_new(:limit, @limit)
  end

  def process_url(url) do
    "https://itunes.apple.com/" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:results)
    |> Enum.map(fn(app) -> Map.take(app, @expected_fields) end)
  end
end
