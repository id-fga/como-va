defmodule Ping do

    def start do
        spawn(Ping, :esperar, [])
    end

    def esperar do
        receive do
            {:buscar, remitente, nombre, ip} -> send(remitente, conectar(nombre, ip))
        end

        esperar
    end

    def conectar(nombre, ip) do
        case Node.ping(:"#{nombre}@#{ip}") do
            :pong -> {:ok, ip}
            :pang -> {:pang, ip}
        end
    end

end

rango = 2 .. 254
Enum.to_list(rango)
|> Enum.map(fn (octeto) ->
    p = Ping.start
    {p, octeto}
end)
|> Enum.map(fn ({pid, octeto}) ->
    send pid, {:buscar, self, "mxt", "192.168.0.#{octeto}"}
    pid
end)
|> Enum.map(fn (pid) ->
    receive do
        {:ok, ip} -> :ok #IO.puts "Ok para #{inspect pid} con #{ip}"
        {:pang, ip} -> :pang #IO.puts "Error para #{inspect pid} con #{ip}"

    end
end)

l = Node.list
IO.inspect l
