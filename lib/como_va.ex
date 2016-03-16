defmodule ComoVa do
    def main(argv) do
        iniciar
    end

    def iniciar do
        #sender_pid = Sender.start
        listener_pid = MasterListener.start
        Prueba.start

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
