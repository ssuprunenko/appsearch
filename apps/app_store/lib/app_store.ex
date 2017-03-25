defmodule AppStore do
  alias AppStore.Search

  def search(term, params \\ %{}) do
    Search.call(term, params)
  end
end
