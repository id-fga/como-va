defmodule MasterListener do
    use GenServer

    def start do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def init(:ok) do
        udp_options = [
            :binary,
            active:          10,
            add_membership:  { {224,1,1,1}, {0,0,0,0} },
            multicast_if:    {0,0,0,0},
            multicast_loop:  false,
            multicast_ttl:   4,
            reuseaddr:       true
        ]

        {:ok, socket} = :gen_udp.open(49999, udp_options)
    end

    def handle_info({:udp, socket, {_, _, _, sender_oct}, port, "master_node"}, state) do
        :inet.setopts(socket, [active: 1])

        string_local_ip = Enum.join(Tuple.to_list(get_ip), ".")
        local_oct = get_oct(get_ip, 4)

        IO.puts "Sender es: " <> to_string(sender_oct)
        IO.puts "Local  es: " <> to_string(local_oct)

        case decidir(local_oct, sender_oct) do
            :harakiri       -> IO.puts "El puede ser el maestro, debo morir"
            :keepalive      -> IO.puts "Yo puedo ser el maestro"
            _               -> :nada
        end

        IO.puts "----------------------------"

        {:noreply, state}
    end

    def decidir(local, sender) when local == sender do
        :igual
    end

    def decidir(local, sender) when local > sender do
        :harakiri
    end

    def decidir(local, sender) when local < sender do
        :keepalive
    end

    defp get_oct(ip, pos) do
        elem(ip, pos - 1)
    end

    defp get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
    end
end

defmodule Sender do
    def start do
        IO.puts "Start Sender"
        spawn(Sender, :init, [])
    end

    def init do
        {:ok, s} = :gen_udp.open(0, [])
        loop(s)
    end

    def loop(s) do
        IO.puts "Yo soy el maestro"
        :timer.sleep(1000)
        :gen_udp.send(s, {224, 1, 1, 1}, 49999, "master_node")
        loop(s)
    end

end

defmodule ComoVa do
    def main(argv) do
        iniciar
    end

    def iniciar do
        [Sender.start, MasterListener.start]
        |> Enum.map(fn (p) ->
            IO.inspect p
        end)
    end

end

#:timer.sleep(:infinity)
