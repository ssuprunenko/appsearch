defimpl Poison.Encoder, for: AppStore.App do
  def encode(app, options) do
    response = %{
      id: app.trackId,
      name: app.trackCensoredName,
      url: app.trackViewUrl,
      icon: app.artworkUrl100,
      description: app.description,
      developer: app.artistName,
      store: "App Store"
    }

    response
    |> specify_fields(options[:fields])
    |> Poison.Encoder.Map.encode(options)
  end

  defp specify_fields(response, fields_string) do
    if fields_string do
      fields =
        fields_string
        |> String.split(",")
        |> Enum.map(fn(attr) -> String.to_atom(attr) end)

      Map.take(response, fields)
    else
      response
    end
  end
end
