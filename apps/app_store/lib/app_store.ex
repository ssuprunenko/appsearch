defmodule AppStore do
  @moduledoc """
  Provides basic functionalities for iTunes Search API.
  """

  alias AppStore.Search

  def search(term, params \\ %{}) do
    Search.call(term, params)
  end
end
