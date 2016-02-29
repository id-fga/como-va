defmodule Ping do

    def start do
        spawn(Ping, :esperar, [])
    end

    def esperar do
        receive do
            {:cmd_ping, remitente, ip} -> send(remitente, cmd_ping(ip))
        end
        esperar 
    end

    def cmd_ping(ip) do
        case System.cmd("ping", ["-c", "1", "#{ip}"]) do
            {_, 0} -> {:ok, ip}
            {_, _} -> {:error, ip}

        end
    end

end


rango = 2 .. 254

Enum.to_list(rango)
|> Enum.map(fn (octeto) ->
    pid = Ping.start
    send pid, {:cmd_ping, self, "192.168.0.#{octeto}"}
    pid
end)
|> Enum.map(fn (pid) ->
    receive do
        {:ok, ip} -> Node.connect(:"mxt@#{ip}")
        {:error, ip} -> :error
    end
end)

l = Node.list
IO.inspect l
