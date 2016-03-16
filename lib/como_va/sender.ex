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
