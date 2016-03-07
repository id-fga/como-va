defmodule Sender do
    def start do
        spawn(Sender, :repetir, [])
    end

    def repetir do
        {:ok, s} = :gen_udp.open(0, [])
        :timer.sleep(1000)
        :gen_udp.send(s, {224, 1, 1, 1}, 49999, "master_node")
        repetir
    end

end

defmodule MasterListener do
    def start() do
        spawn(MasterListener, :init, [])
    end

    def init() do
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
        loop(socket)
    end

    defp loop(socket) do
        case :gen_udp.recv(socket, 0) do
            {:ok, {sender_ip, _port, "master_node"}} -> decide_ip(sender_ip, socket)
            _ -> :error
        end

        loop(socket)
    end

    defp decide_ip(sender_ip, socket) do
        string_sender_ip = Enum.join(Tuple.to_list(sender_ip), ".")
        string_local_ip = Enum.join(Tuple.to_list(get_ip), ".")

        local_oct = get_oct(get_ip, 4)
        sender_oct = get_oct(sender_ip, 4)

        cond do
            sender_oct < local_oct
                ->  IO.puts "----------------------------"
                    IO.puts "Sender es: " <> string_sender_ip
                    IO.puts "Local  es: " <> string_local_ip
                    IO.puts "Sender es menor, el puede ser el maestro"
                    IO.puts "Debo morir"

            sender_oct == local_oct
                ->  :nada
                #->  IO.puts "Sender es igual, es un mensaje propio"

            true
                ->  IO.puts "----------------------------"
                    IO.puts "Sender es: " <> string_sender_ip
                    IO.puts "Local  es: " <> string_local_ip
                    IO.puts "Sender es mayor, yo soy el maestro"
                    #:gen_tcp.send(socket, sender_ip, 1234, "kill")
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

Sender.start
MasterListener.start
