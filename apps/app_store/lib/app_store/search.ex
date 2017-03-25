defmodule AppStore.Search do
  @moduledoc """
  Provides access to iTunes Search API for the Software entity.

  ## Reference
  https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
  """

  use HTTPoison.Base
  alias AppStore.App

  @endpoint "https://itunes.apple.com"
  @limit 10

  def call(term, params \\ %{}) do
    start()

    case get("/search", [], params: process_params(params, term)) do
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
    @endpoint <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!(as: %{"results" => [%App{}]})
    |> Map.get("results")
  end
end
