defmodule API.Apps do
  @moduledoc false

  def search(term, params \\ %{}) do
    appstore_task = Task.async(fn -> AppStore.search(term, params) end)
    googleplay_task = Task.async(fn -> GooglePlay.search(term, params) end)

    Task.await(appstore_task) ++ Task.await(googleplay_task)
  end
end
