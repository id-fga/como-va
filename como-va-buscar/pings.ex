defmodule Funcs do
    def start(name, ip) do
      yo = self
      pid = spawn(Funcs, :nodeping, [yo, name, ip])
    end

  def nodeping(yo, name, ip) do
    case Node.ping :"#{name}@#{ip}" do
        :pong -> send yo, "#{ip}"
        :pang -> send yo, :pang
    end
  end
end



rango = 2 .. 254
Enum.to_list(rango)
|> Enum.map(fn (o) ->
    Funcs.start("mxt", "192.168.0.#{o}")
end)
|> Enum.map(fn (o) ->

    receive do
        :pang -> :pang
        m -> IO.puts "#{m}"
        after 50 -> :timeout
    end
    
end)

