defmodule AgendaCli.Store do
  @file_path "contacts.json"

  def load() do
    case File.read(@file_path) do
      {:ok, content} ->
        content
        |> Jason.decode!(keys: :atoms)
      {:error, _} ->
        []
    end
  end

  def save(contacts) do
    binary = Jason.encode!(contacts, pretty: true)
    File.write!(@file_path, binary)
    contacts
  end
end
