defmodule Server do
#	def start do
#		p = spawn(Server, :esperar, [])
#		:global.register_name("server-mxt", p)
#	end

	def esperar do
		IO.puts "Espero clientes"
		receive do
			{remitente, m} -> 	IO.puts "Llega #{m} de #{inspect remitente}"
						send self, "mmm"
		end

		esperar

	end
end

#pid = Server.start
#IO.puts "#{inspect pid}"

:global.register_name("server-192.168.0.5", self)
Server.esperar

#receive do
#	m -> IO.puts "Fin"
#end
