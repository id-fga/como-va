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
        :erlang.set_cookie(node, :"de-chocolate")
        loop(socket, {})
    end

    def loop(socket, master) do

        r = 2 .. 10
        timeout_list = Enum.map(r, fn n -> n * 1000 end)
        timeout = Enum.random(timeout_list)
        IO.puts "----------------------------------------"

        local_ip = get_ip

        case :gen_udp.recv(socket, 0, timeout) do
            {:ok, {^local_ip, _, _}}                -> :ignore

            {:ok, {sender_ip, _, "master_node"}}    ->  IO.puts "Master es #{inspect sender_ip}"
                                                        send :main, {:master_es, Enum.join(Tuple.to_list(sender_ip), ".")}

            {:error, :timeout}                      ->  IO.puts "Estan todos callados, espere " <> to_string(timeout)
                                                        send :main, {:master_es, Enum.join(Tuple.to_list(get_ip), ".")}
                                                        sender_pid = Sender.start
                                                        Process.register(sender_pid, :sender)
        end

        loop(socket, {})
    end

    def get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
    end
end
