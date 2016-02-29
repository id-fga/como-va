defmodule Lista do

    def mostrar do

        l = Node.list
        IO.inspect l

        :timer.sleep 1000
        mostrar
    end

end

Lista.mostrar
