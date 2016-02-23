defmodule Funcs do
    def start() do
      spawn(Funcs, :esperar, [])
    end

  def esperar do
    receive do
      {:connect, remitente, name, ip} -> send remitente, connect(name, ip)
    end
  end

  def connect(name, ip) do
    case Node.connect :"#{name}@#{ip}" do
        :true -> "#{ip}"
        :false -> :error
    end
  end
end



rango = 2 .. 254
Enum.to_list(rango)
|> Enum.map(fn (o) ->
    pid = Funcs.start
    send pid, {:connect, self, "mxt", "10.6.1.#{o}"}
end)
|> Enum.map(fn (pid) ->

  receive do
    :error -> :error
    m -> IO.puts "#{m}"

    after 50 -> :timeout
  end
    
end)

l = :global.registered_names
IO.inspect l

