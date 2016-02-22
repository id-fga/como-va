defmodule Funcs do
    def start do
      pid = spawn(Funcs, :nodeping, [])
    end

  def nodeping do
    receive do
      {remitente, name, ip} ->  case Node.ping :"mxt@#{ip}" do
                                  :pong ->  #Node.connect
                                            r = Node.connect(:"mxt@#{ip}")
                                            :global.sync()
                                            pid = :global.whereis_name("server-mxt")
                                            IO.puts "#{inspect pid}"
                                            send pid, {self, "Te saludo"}
                                            send remitente, "#{ip}"
                                  :pang ->  send remitente, :pang
                                end
    end
  end


  def recibir (tope) do
    receive do
      :pang -> :pang
      m -> IO.puts "#{m}"
    end

    if tope == 1 do
      IO.inspect Node.list
      IO.puts "Fin"
    else
      recibir tope - 1
    end

  end

end



lista = ["www.amazon.com", "www.google.com.ar", "www.yahoo.com.arrr"]

#p1 = Funcs.start
#send p1, {self, 1, "www.yahoo.com"}

#p2 = Funcs.start
#send p2, {self, 1, "www.amazon.com"}

#p3 = Funcs.start
#send p3, {self, 1, "www.google.com.ar"}



Enum.to_list(2 .. 255)
|> Enum.map(fn (o) ->
  name = "mxt"
  ip = "192.168.0.#{o}"

  p = Funcs.start
  send p, {self, name, ip}
end)


Funcs.recibir(254)
