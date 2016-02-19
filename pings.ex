defmodule Funcs do
    def start do
      pid = spawn(Funcs, :ping, [])
    end

  def ping do
    receive do
      {remitente, c, u} ->  IO.puts "Me llega de #{inspect remitente} para #{u}"
                            System.cmd("ping", ["-c", "#{c}", u])
                            send remitente, "Termine con #{u}"
    end
  end


  def recibir (tope) do
    receive do
      m -> 

        IO.puts "#{m}"

        if tope == 1 do
          IO.puts "Fin"
        else
          recibir tope - 1
        end
    end

  end

end



#lista = ["www.google.com.ar", "www.yahoo.com.ar"]

p1 = Funcs.start
send p1, {self, 7, "www.yahoo.com"}

p2 = Funcs.start
send p2, {self, 4, "www.google.com.ar"}

p3 = Funcs.start
send p3, {self, 2, "www.erlang.org"}


Funcs.recibir(3)

