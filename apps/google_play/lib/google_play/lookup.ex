defmodule GooglePlay.Lookup do
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
    id = Floki.attribute(content, ".details-wrapper", "data-docid") |> List.first
    store_url = "https://play.google.com/store/apps/details?id=" <> id

    %App{
      id: id,
      title: fetch_attr(content, :title),
      store_url: store_url,
      icon: fetch_attr(content, :icon),
      description: fetch_attr(content, :description),
      developer: fetch_attr(content, :developer),
      website: fetch_attr(content, :website),
      rating: fetch_attr(content, :rating)
    }
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
