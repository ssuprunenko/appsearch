defmodule GooglePlay.Lookup do
  @moduledoc """
  Provides access to Google Play Lookup.
  """

  use HTTPoison.Base
  alias GooglePlay.App

  @endpoint "https://play.google.com/store/apps"

  def call(id) do
    start()

    case get("/details", [], params: %{id: id, hl: "en"}) do
      {:ok, %HTTPoison.Response{body: body}} -> body
      {:error, _} -> %{}
    end
  end

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    content = Floki.find(body, ".main-content")
    parse_content(content)
  end

  defp parse_content([]), do: %{}
  defp parse_content(content) do
    ~w(id title icon description developer website rating)a
    |> Enum.map(&(Task.async(fn -> %{field: &1, value: fetch_attr(content, &1)} end)))
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(%App{}, fn(%{field: field, value: value}, acc) ->
      Map.put(acc, field, value)
    end)
    |> fetch_attr(:store_url)
  end

  defp fetch_attr(content, :id) do
    content
    |> Floki.attribute(".details-wrapper", "data-docid")
    |> List.first
  end

  defp fetch_attr(app, :store_url) do
    Map.put(app, :store_url, "https://play.google.com/store/apps/details?id=" <> app.id)
  end

  defp fetch_attr(content, :title) do
    content
    |> Floki.find(".id-app-title")
    |> Floki.text
  end

  defp fetch_attr(content, :icon) do
    content
    |> Floki.attribute(".cover-image", "src")
    |> List.first
    |> String.replace_prefix("//", "https://")
    |> String.replace_suffix("=w300", "")
  end

  defp fetch_attr(content, :description) do
    content
    |> Floki.find("[itemprop=description]")
    |> Floki.text
  end

  defp fetch_attr(content, :developer) do
    content
    |> Floki.find("[itemprop=author] .primary")
    |> Floki.text
  end

  defp fetch_attr(content, :website) do
    content
    |> Floki.attribute(".dev-link", "href")
    |> List.first
    |> String.split(["q=", "&"], parts: 3)
    |> Enum.at(1)
  end

  defp fetch_attr(content, :rating) do
    content
    |> Floki.attribute(".current-rating", "style")
    |> List.first
    |> String.replace(~r/width: |%;/, "")
    |> Float.parse
    |> elem(0)
    |> Kernel.*(0.05)
    |> Float.round(3)
  end
end
