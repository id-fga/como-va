defmodule ComoVa do
    def main(argv) do
        iniciar
    end

    def iniciar do
        local_ip = Enum.join(Tuple.to_list(MasterListener.get_ip), ".")
        nodename = String.to_atom("comova@"<>local_ip)
        :net_kernel.start([nodename, :longnames])
        :erlang.set_cookie(node, :"de-chocolate")
        listener_pid = MasterListener.start

        global_process = String.to_atom("main-"<>local_ip)

        Process.register(self, :main)
        :global.register_name(global_process, self)

        #Process.register(sender_pid, :sender)
        Process.register(listener_pid, :listener)

        recibir {"", []}
    end

    def filtrar_lista(rn, nl) do
        IO.puts "Lista entera #{inspect nl}"
        IO.puts "Listra filrada para #{inspect rn}"
        Enum.map(nl, fn(n) ->
            sn = Atom.to_string(n)
            case String.split(sn, "@") do
                [^rn, _]    -> n
                _           -> :nada
            end
        end) |> IO.inspect
    end

    def recibir({master_ip, nodos}) do
        receive do
            {:master_es, master_ip}                     ->  matar Process.whereis(:sender)
                                                            recibir({master_ip, []})
            {:master_quien, remote_pid}                 ->  send remote_pid, {:master, master_ip}
            {:traer_lista, register_name, remote_pid}   ->  filtrar_lista(register_name, Node.list)
            _                                           -> :nada
        end

        recibir {master_ip, nodos}
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
