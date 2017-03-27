defmodule AppStore.Lookup do
  @moduledoc """
  Provides access to iTunes Search API #lookup for the Software entity.

  ## Reference
  https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
  """

  use HTTPoison.Base
  use AppStore.API

  def call(id) do
    start()

    case get("/lookup", [], params: %{id: id, entity: "software"}) do
      {:ok, %HTTPoison.Response{body: body}} ->
        List.first(body) || %{}
      {:error, _} ->
        %{}
    end
  end
end
