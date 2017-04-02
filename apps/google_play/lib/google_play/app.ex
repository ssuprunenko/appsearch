defmodule GooglePlay.App do
  @moduledoc """
  Represents App resource.
  """

  defstruct ~w(
    id
    title
    store_url
    icon_url_170
    icon_url_340
    description
    developer
    rating
  )a

  @type t :: %GooglePlay.App{
    id: integer,
    title: binary,
    store_url: binary,
    icon_url_170: binary,
    icon_url_340: binary,
    description: binary,
    developer: binary,
    rating: float
  }
end
