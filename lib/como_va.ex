defmodule MasterListener do
    use GenServer

    def start do
        GenServer.start(__MODULE__, :ok, [])
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

        IO.puts "LISTENER > " <> to_string(:erlang.system_time)

        case decidir(local_oct, sender_oct) do
            :harakiri       ->  harakiri
            _               ->  :keepalive
        end

        IO.puts "----------------------------"

        {:noreply, state}
    end

    def decidir(local, sender) when local > sender do
        IO.puts "LISTENER > Local  es: " <> to_string(local)
        IO.puts "LISTENER > Sender es: " <> to_string(sender)
        :harakiri
    end

    def decidir(local, sender) do
        :discard
    end

    defp get_oct(ip, pos) do
        elem(ip, pos - 1)
    end

    defp get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
    end

    defp harakiri do
        IO.puts "LISTENER > El puede ser el maestro, debo morir"
        main_pid = Process.whereis(:main)
        send main_pid, :reiniciar
    end
end

defmodule Sender do
    def start do
        spawn(Sender, :init, [])
    end

    def init do
        {:ok, s} = :gen_udp.open(0, [])
        loop(s)
    end

    def loop(s) do
        IO.puts "SENDER > Yo soy el maestro"
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
        sender_pid = Sender.start
        {:ok, listener_pid} = MasterListener.start

        #TODO: Hacer con una lista de tuplas, iterando y registrando
        Process.register(self, :main)
        Process.register(sender_pid, :sender)
        Process.register(listener_pid, :listener)

        #TODO: Rehacer, revisar unregister, agregar sleep random
        receive do
            :reiniciar  ->  Process.exit(Process.whereis(:sender), :kill)
                            Process.exit(Process.whereis(:listener), :kill)
                            Process.unregister(:main)
                            IO.puts "MAIN > Todo esta muerto"
                            IO.puts "MAIN > Espero y vuelvo a arrancar"
                            :timer.sleep(5000)
                            iniciar
        end
    end
end

#:timer.sleep(:infinity)
