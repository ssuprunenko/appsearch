defimpl Poison.Encoder, for: GooglePlay.App do
  def encode(app, options) do
    response = %{
      id: app.id,
      name: app.title,
      url: app.store_url,
      icon: app.icon,
      description: app.description,
      developer: app.developer,
      website: app.website,
      store: "Google Play"
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
