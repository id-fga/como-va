defmodule ComoVa do
    def main(argv) do
        iniciar
    end

    def iniciar do
        local_ip = Enum.join(Tuple.to_list(MasterListener.get_ip), ".")
        nodename = String.to_atom("comova@"<>local_ip)
        :net_kernel.start([nodename, :longnames])
        listener_pid = MasterListener.start

        Process.register(self, :main)
        :global.register_name(:main, self)

        #Process.register(sender_pid, :sender)
        Process.register(listener_pid, :listener)

        recibir {}
    end

    def recibir(t) do
        receive do
            {:master_es, master_ip}     ->  matar Process.whereis(:sender)
                                            recibir {:master, master_ip}
            {:master_quien, remote_pid} ->  send remote_pid, t
            _                           -> :nada
        end

        recibir t
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
