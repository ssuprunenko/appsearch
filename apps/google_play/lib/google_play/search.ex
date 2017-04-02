defmodule GooglePlay.Search do
  @moduledoc """
  Provides access to Google Play Search.
  """

  use HTTPoison.Base
  alias GooglePlay.App

  @endpoint "https://play.google.com/store"
  @limit 10

  def call(term, params \\ %{}) do
    start()

    case get("/search", [], params: process_params(params, term)) do
      {:ok, %HTTPoison.Response{body: body}} ->
        limit =
          params
          |> Map.put_new(:limit, params["limit"] || @limit)
          |> results_limit

        Enum.take(body, limit)
      {:error, _} -> []
    end
  end

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    body
    |> Floki.find(".card")
    |> Stream.map(fn(app) -> parse(app) end)
  end

  defp results_limit(%{limit: limit}) when is_binary(limit) do
    case Integer.parse(limit) do
      {number, ""} -> number
      :error -> @limit
    end
  end
  defp results_limit(%{limit: limit}) when is_integer(limit), do: limit
  defp results_limit(_), do: @limit

  defp process_params(params, term) do
    params
    |> Map.put(:q, term)
    |> Map.put(:c, "apps")
    |> Map.put_new(:hl, "en")
  end

  defp parse(card) do
    id = fetch_attr(card, :id)
    store_url = "https://play.google.com/store/apps/details?id=" <> id

    %App{
      id: id,
      title: fetch_attr(card, :title),
      store_url: store_url,
      icon_url_170: fetch_attr(card, :icon_url_170),
      icon_url_340: fetch_attr(card, :icon_url_340),
      description: fetch_attr(card, :description),
      developer: fetch_attr(card, :developer),
      rating: fetch_attr(card, :rating)
    }
  end

  defp fetch_attr(card, :id) do
    card
    |> Floki.attribute(".title", "href")
    |> List.first
    |> String.split("id=", parts: 2, trim: true)
    |> List.last
  end

  defp fetch_attr(card, :title) do
    card
    |> Floki.attribute(".title", "title")
    |> List.first
  end

  defp fetch_attr(card, :icon_url_170) do
    card
    |> Floki.attribute(".cover-image", "data-cover-small")
    |> List.first
    |> String.replace_prefix("//", "https://")
  end

  defp fetch_attr(card, :icon_url_340) do
    card
    |> Floki.attribute(".cover-image", "data-cover-large")
    |> List.first
    |> String.replace_prefix("//", "https://")
  end

  defp fetch_attr(card, :description) do
    card
    |> Floki.find(".description")
    |> Floki.text
    |> String.trim
  end

  defp fetch_attr(card, :developer) do
    card
    |> Floki.find(".subtitle")
    |> Floki.text
  end

  defp fetch_attr(card, :rating) do
    card
    |> Floki.attribute(".current-rating", "style")
    |> List.first
    |> String.replace(~r/width: |%;/, "")
    |> Float.parse
    |> elem(0)
    |> Kernel.*(0.05)
    |> Float.round(3)
  end
end
