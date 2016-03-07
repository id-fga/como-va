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
            {:ok, {sender_ip, _port, "master_node"}} -> decide_ip(sender_ip, socket)
            {:ok, {get_ip, _port, "kill"}} -> IO.puts "Me tengo que morir"
            _ -> :error
        end

        loop(socket)
    end

    defp decide_ip(sender_ip, socket) do
        string_sender_ip = Enum.join(Tuple.to_list(sender_ip), ".")
        string_local_ip = Enum.join(Tuple.to_list(get_ip), ".")

        local_oct = get_oct(get_ip, 4)
        sender_oct = get_oct(sender_ip, 4)

        IO.puts "----------------------------"
        IO.puts "Sender es: " <> string_sender_ip
        IO.puts "Local  es: " <> string_local_ip

        cond do
            sender_oct < local_oct
                -> IO.puts "Sender es menor, el es el maestro"

            sender_oct == local_oct
                ->  IO.puts "Sender es igual, es un mensaje propio"

            true
                ->  IO.puts "Sender es mayor, yo soy el maestro"
                    IO.puts string_sender_ip <> " Debe morir"
                    :gen_udp.send(socket, {224, 1, 1, 1}, 49999, "kill")
        end

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

