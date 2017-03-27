defmodule AppStore.API do
  defmacro __using__(_) do
    quote do
      alias AppStore.App

      @endpoint "https://itunes.apple.com"

      def process_url(url) do
        @endpoint <> url
      end

      def process_response_body(body) do
        body
        |> Poison.decode!(as: %{"results" => [%App{}]})
        |> Map.get("results")
      end
    end
  end
end
