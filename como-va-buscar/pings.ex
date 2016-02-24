defmodule Funcs do
    def start() do
      spawn(Funcs, :esperar, [])
    end

  def esperar do
    receive do
      {:connect, remitente, name, ip} -> send remitente, connect(name, ip)
    end
    esperar
  end

  def connect(name, ip) do
    case Node.connect :"#{name}@#{ip}" do
        :true ->  {:ok, ip}
        :false -> {:error, ip}
    end
  end
end

defmodule Main do
  def start do
    rango = 2 .. 254
    Enum.to_list(rango)
    |> Enum.map(fn (o) ->
      pid = Funcs.start
      #{pid, "mxt", "10.6.1.#{o}"}
      {pid, "mxt", "192.168.0.#{o}"}
    end)
  end

  def mensajear (pid_list) do
    Enum.to_list(pid_list)
    |> Enum.map(fn (pid_element) -> 
      {pid, name, ip} = pid_element

      send pid, {:connect, self, name, ip}
      pid
    end)
  end

  def esperar (pid) do
    Enum.to_list(pid)
    |> Enum.map(fn (pid) ->

      receive do
        {:error, ip} -> :error
        {:ok, ip} -> :ok

        after 50 -> :timeout
   
      end

    end)
  end

  def loop (pid_list) do
    IO.puts "\nEscaneando todo"
    mensajear pid_list
    esperar pid_list

    l = :global.registered_names
    IO.inspect l
    IO.puts "Termino todo\n"

    loop pid_list
  end


end

Main.start
|> Main.loop
  



