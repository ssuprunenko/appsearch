defmodule AppStore.App do
  @moduledoc """
  Represents an App (Software) resource.

  ## Reference
  https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api
  """

  defstruct ~w(
    trackId
    trackCensoredName
    trackViewUrl
    artworkUrl60
    artworkUrl100
    description
    artistName
  )a

  @type t :: %AppStore.App{
    trackId: integer,
    trackCensoredName: binary,
    trackViewUrl: binary,
    artworkUrl60: binary,
    artworkUrl100: binary,
    description: binary,
    artistName: binary
  }
end
