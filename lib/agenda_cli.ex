defmodule AgendaCli do
  def main(_args) do
    # Banner inicial no estilo do professor
    IO.puts("""
    --- Agenda Elixir CLI ---
    Comandos: add, list, search, edit, del, show, exit
    ----------------------------
    """)

    contacts = AgendaCli.Store.load()
    loop(contacts)
  end

  defp loop(contacts) do
    input = IO.gets("agenda> ") |> String.trim()

    # O "Cérebro": Primeiro interpreta o comando, depois executa
    case parse(input) do
      {:add, attrs} ->
        if valid_attrs?(attrs) do
          new_contacts = contacts |> AgendaCli.Contacts.add(attrs) |> AgendaCli.Store.save()
          IO.puts("Contato adicionado!")
          loop(new_contacts)
        else
          IO.puts("Erro: Todos os campos são obrigatórios (name company phone email) e o telefone deve ter 11 dígitos.")
          loop(contacts)
        end

      {:search, {field, value}} ->
        results = AgendaCli.Contacts.search(contacts, field, value)
        AgendaCli.Contacts.list(results)
        loop(contacts)

      {:show, id} ->
        AgendaCli.Contacts.show(contacts, id)
        loop(contacts)

      {:del, id} ->
        if Enum.any?(contacts, fn c -> c.id == id end) do
          new_contacts = contacts |> AgendaCli.Contacts.delete(id) |> AgendaCli.Store.save()
          IO.puts("Contato #{id} removido!")
          loop(new_contacts)
        else
          IO.puts("Contato não encontrado.")
          loop(contacts)
        end

      {:edit, {id, flags}} ->
        if Enum.any?(contacts, fn c -> c.id == id end) do
          {params, _, _} = OptionParser.parse(flags,
            switches: [name: :string, company: :string, phone: :string, email: :string])

          new_attrs = Enum.into(params, %{})

          if map_size(new_attrs) > 0 do
            new_contacts = contacts |> AgendaCli.Contacts.edit(id, new_attrs) |> AgendaCli.Store.save()
            IO.puts("Contato #{id} atualizado!")
            loop(new_contacts)
          else
            IO.puts("Nenhuma flag de edição válida detectada.")
            loop(contacts)
          end
        else
          IO.puts("Contato #{id} não existe.")
          loop(contacts)
        end

      :list ->
        AgendaCli.Contacts.list(contacts)
        loop(contacts)

      :exit ->
        IO.puts("Encerrando...")

      {:error, msg} ->
        IO.puts(msg)
        loop(contacts)

      :unknown ->
        IO.puts("Comando inválido!")
        loop(contacts)
    end
  end

  # --- O "INTERPRETADOR" (Parser) no estilo do professor ---

  defp parse("exit"), do: :exit
  defp parse("list"), do: :list

  defp parse("add " <> rest) do
    {params, _, _} = OptionParser.parse(OptionParser.split(rest),
      switches: [name: :string, company: :string, phone: :string, email: :string])
    {:add, Enum.into(params, %{})}
  end

  defp parse("search " <> rest) do
    case parse_search(rest) do
      {field, value} -> {:search, {field, value}}
      :error -> {:error, "Use: search --name, --phone ou --email seguido do valor."}
    end
  end

  defp parse("show " <> id_str) do
    case Integer.parse(id_str) do
      {id, _} -> {:show, id}
      :error -> {:error, "ID inválido. Deve ser um número inteiro."}
    end
  end

  defp parse("del " <> id_str) do
    case Integer.parse(id_str) do
      {id, _} -> {:del, id}
      :error -> {:error, "ID inválido."}
    end
  end

  defp parse("edit " <> rest) do
    parts = OptionParser.split(rest)
    id_str = List.first(parts)
    flags = List.delete_at(parts, 0)

    case Integer.parse(id_str || "") do
      {id, _} -> {:edit, {id, flags}}
      :error -> {:error, "Formato inválido. Use: edit <id> --flag valor"}
    end
  end

  defp parse(_), do: :unknown

  # --- FUNÇÕES AUXILIARES ---

  defp parse_search(string) do
    {params, _, _} = OptionParser.parse(OptionParser.split(string),
      switches: [name: :string, phone: :string, email: :string])

    case List.first(params) do
      {field, value} when value != "" -> {field, value}
      _ -> :error
    end
  end

  defp valid_attrs?(attrs) do
    has_all? = Map.has_key?(attrs, :name) and Map.has_key?(attrs, :phone) and
               Map.has_key?(attrs, :email) and Map.has_key?(attrs, :company)

    if has_all? do
      String.length(attrs.phone) == 11 and String.contains?(attrs.email, "@")
    else
      false
    end
  end
end
