#!/bin/bash

usuario=buscar
ip=$(sudo ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

echo "Iniciando $usuario@$ip"
elixir --name $usuario@$ip -r pings2.ex --cookie de-chocolate