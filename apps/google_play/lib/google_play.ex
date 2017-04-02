defmodule GooglePlay do
  @moduledoc """
  Provides basic functionalities for Google Play.
  """

  alias GooglePlay.Search

  def search(term, params \\ %{}) do
    Search.call(term, params)
  end
end
