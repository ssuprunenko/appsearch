defmodule GooglePlay do
  @moduledoc """
  Provides basic functionalities for Google Play.
  """

  alias GooglePlay.Search
  alias GooglePlay.Lookup

  def search(term, params \\ %{}) do
    Search.call(term, params)
  end

  def lookup(id) do
    Lookup.call(id)
  end
end
