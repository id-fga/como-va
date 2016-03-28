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

        recibir({"", []}, 0)
    end

    def filtrar_lista(rn, nl) do
        Enum.filter(nl, fn(e) ->
                [nombre, _] = Atom.to_string(e) |> String.split("@")
                nombre == rn
        end)
    end

    def recibir({master_ip, nodos}, retries) do
        receive do
            {:master_es, master_ip}                     ->  
                                                            if matar(retries) do
                                                                recibir({master_ip, []}, retries + 1)
                                                            end
            {:master_quien, remote_pid}                 ->  send remote_pid, {:master, master_ip}
            {:traer_lista, register_name, remote_pid}   ->  send remote_pid, {:lista, filtrar_lista(register_name, Node.list)}
            _                                           -> :nada
        end

        recibir({master_ip, nodos}, retries)
    end

    def matar(tries) do
        :global.sync
        case Process.whereis(:sender) do
            nil -> false
            pid -> do_matar(pid, tries)
        end
    end

    defp do_matar(p, 10) do
        IO.puts "Tries es 10"
        IO.puts "HARAKIRI"
        p = Process.whereis(:main)
        Process.exit(p, :kill)
    end

    defp do_matar(p, t) do
        IO.puts "Tries es #{t}"
        IO.puts "Sender debe morir #{inspect p}"
        Process.unregister(:sender)
        Process.exit(p, :kill)
        true
    end
end


#:timer.sleep(:infinity)
