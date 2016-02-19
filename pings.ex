defmodule Funcs do
    def start do
      pid = spawn(Funcs, :ping, [])
    end

  def ping do
    receive do
      {remitente, c, u} ->  IO.puts "Me llega de #{inspect remitente} para #{u}"
                            case System.cmd("ping", ["-c", "#{c}", u]) do
                              {_output, 0} -> send remitente, "OK: Termine con #{u}"
                              {_output, 1} -> send remitente, "ERROR: Termine con #{u}"
                              {_output, 2} -> send remitente, "ERROR: Termine con #{u}"
                            end
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



lista = ["www.amazon.com", "www.google.com.ar", "www.yahoo.com.arrr"]

#p1 = Funcs.start
#send p1, {self, 1, "www.yahoo.com"}

#p2 = Funcs.start
#send p2, {self, 1, "www.amazon.com"}

#p3 = Funcs.start
#send p3, {self, 1, "www.google.com.ar"}



lista
|> Enum.map(fn (url) ->
  p = Funcs.start
  send p, {self, 1, url}
end)


Funcs.recibir(length(lista))
