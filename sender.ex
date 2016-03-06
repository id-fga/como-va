defmodule Funcs do
    def repetir f do
        :timer.sleep(1000)
        f.()
        repetir f
    end

end

{:ok, socket} = :gen_udp.open(0, [])
Funcs.repetir(fn ->
    :gen_udp.send(socket, {224, 1, 1, 1}, 49999, "master_node")
end)

