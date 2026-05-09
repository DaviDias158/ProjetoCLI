defmodule AgendaCli.Contacts do
  def add(contacts, attrs) do
    new_id = System.system_time(:millisecond)
    new_contact = Map.put(attrs, :id, new_id)
    contacts ++ [new_contact]
  end

  def list(contacts) do
    if Enum.empty?(contacts) do
      IO.puts("\nAgenda vazia.\n")
    else
      IO.puts("\n#{String.pad_trailing("ID", 15)} | #{String.pad_trailing("NOME", 20)} | #{String.pad_trailing("TELEFONE", 12)} | #{String.pad_trailing("EMAIL", 25)} | EMPRESA")
      IO.puts(String.duplicate("-", 100))
      Enum.each(contacts, fn c ->
        # Usar Map.get(c, :campo, "") garante que se não existir, ele mostra vazio em vez de dar erro
        id      = Map.get(c, :id, "")
        name    = Map.get(c, :name, "")
        phone   = Map.get(c, :phone, "")
        email   = Map.get(c, :email, "")
        company = Map.get(c, :company, "")

        IO.puts("#{String.pad_trailing(to_string(id), 15)} | #{String.pad_trailing(name, 20)} | #{String.pad_trailing(phone, 12)} | #{String.pad_trailing(email, 25)} | #{company}")
      end)
      IO.puts("\n")
    end
  end

  def search(contacts, field, term) do
    term_down = String.downcase(term)
    Enum.filter(contacts, fn c ->
      value = Map.get(c, field, "") |> to_string() |> String.downcase()
      String.contains?(value, term_down)
    end)
  end

  def delete(contacts, id), do: Enum.reject(contacts, fn c -> c.id == id end)

  def show(contacts, id) do
    case Enum.find(contacts, fn c -> c.id == id end) do
      nil -> IO.puts("Contato não encontrado.")
      c   -> list([c])
    end
  end

  def edit(contacts, id, new_attrs) do
    Enum.map(contacts, fn c ->
      if c.id == id, do: Map.merge(c, new_attrs), else: c
    end)
  end
end
