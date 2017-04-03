defmodule GooglePlay.App do
  @moduledoc """
  Represents App resource.
  """

  defstruct ~w(
    id
    title
    store_url
    icon
    description
    developer
    website
    rating
  )a

  @type t :: %GooglePlay.App{
    id: integer,
    title: binary,
    store_url: binary,
    icon: binary,
    description: binary,
    developer: binary,
    website: binary,
    rating: float
  }
end
