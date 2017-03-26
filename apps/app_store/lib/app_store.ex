defmodule AppStore do
  @moduledoc """
  Provides basic functionalities for iTunes Search API.
  """

  alias AppStore.Search
  alias AppStore.Lookup

  def search(term, params \\ %{}) do
    Search.call(term, params)
  end

  def lookup(id) do
    Lookup.call(id)
  end
end
