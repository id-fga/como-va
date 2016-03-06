defmodule MasterListener do
    def start do
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
        loop socket
    end

    defp loop(socket) do
        case :gen_udp.recv(socket, 0) do
            {:ok, {{oct_1, oct_2, oct_3, oct_4}, _port, "master_node"}} -> decide_ip(oct_4)
            _ -> :error
        end

        loop(socket)
    end

    defp decide_ip(oct) do
        local_oct = get_oct(get_ip, 4)
        IO.puts "----------------------------"
        IO.puts local_oct
        IO.puts oct
    end

    defp get_oct(ip, pos) do
        elem(ip, pos - 1)
    end

    defp get_ip do
        {:ok, val} = :inet.getif() 
        elem(hd(val), 0)
    end
end


MasterListener.start

