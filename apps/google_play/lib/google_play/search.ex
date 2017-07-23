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
    |> Stream.map(fn(app) -> parse_content(app) end)
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

  defp parse_content(card) do
    ~w(id title icon description developer rating)a
    |> Enum.map(&(Task.async(fn -> %{field: &1, value: fetch_attr(card, &1)} end)))
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(%App{}, fn(%{field: field, value: value}, acc) ->
      Map.put(acc, field, value)
    end)
    |> fetch_attr(:store_url)
  end

  defp fetch_attr(app, :store_url) do
    Map.put(app, :store_url, "https://play.google.com/store/apps/details?id=" <> app.id)
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

  defp fetch_attr(card, :icon) do
    card
    |> Floki.attribute(".cover-image", "data-cover-large")
    |> List.first
    |> String.replace_prefix("//", "https://")
    |> String.replace_suffix("=w340", "")
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
    width =
      card
      |> Floki.attribute(".current-rating", "style")
      |> List.first

    case width do
      nil -> nil
      _ ->
        width
        |> String.replace(~r/width: |%;/, "")
        |> Float.parse
        |> elem(0)
        |> Kernel.*(0.05)
        |> Float.round(3)
    end
  end
end
