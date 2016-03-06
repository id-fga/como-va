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

    def loop(socket) do
        case :gen_udp.recv(socket, 0) do
            {:ok, {{oct_1, oct_2, oct_3, oct_4}, _port, msg}} -> IO.inspect msg
        end

        loop(socket)
    end
end


MasterListener.start

