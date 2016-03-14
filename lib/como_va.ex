defmodule MasterListener do
    use GenServer

    def start do
        #GenServer.start(MasterListener, :ok, [])
        spawn(MasterListener, :init, [])
    end

    def init do
        udp_options = [
            :binary,
            active:          false,
            add_membership:  { {224,1,1,1}, {0,0,0,0} },
            multicast_if:    {0,0,0,0},
            multicast_loop:  false,
            multicast_ttl:   4,
            reuseaddr:       true
        ]

        {:ok, socket} = :gen_udp.open(49999, udp_options)
        loop(socket, {})
    end

    def loop(socket, master) do

        local_ip = get_ip

        case :gen_udp.recv(socket, 0, 5000) do
            {:ok, {^local_ip, _, _}}                -> :ignore
            {:ok, {sender_ip, _, "master_node"}}    ->  IO.puts "Master es #{inspect sender_ip}"
                                                        send :main, :kill_sender

            {:error, :timeout}                      ->  IO.puts "Estan todos callados"
                                                        sender_pid = Sender.start
                                                        Process.register(sender_pid, :sender)
        end

        loop(socket, {})
    end

    defp get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
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
        #sender_pid = Sender.start
        listener_pid = MasterListener.start

        #TODO: Hacer con una lista de tuplas, iterando y registrando
        Process.register(self, :main)
        #Process.register(sender_pid, :sender)
        Process.register(listener_pid, :listener)

        recibir
    end

    def recibir do
        receive do
            #:reiniciar  -> #Process.exit(Process.whereis(:sender), :kill)
                            #Process.exit(Process.whereis(:listener), :kill)
                            #Process.unregister(:main)
                            #IO.puts "MAIN > Todo esta muerto"
                            #IO.puts "MAIN > Espero y vuelvo a arrancar"
                            #:timer.sleep(5000)
                            #iniciar

            :kill_sender -> 
                            matar Process.whereis(:sender)
                            #matar(Process.alive?(Process.whereis(:sender)))
                            recibir 
            _ -> :nada
        end
    end

    def matar(nil) do
        IO.puts "Nada"
    end

    def matar(pid) do
        IO.puts "Sender debe morir #{inspect pid}"
        Process.unregister(:sender)
        Process.exit(pid, :kill)
    end
end

#:timer.sleep(:infinity)
