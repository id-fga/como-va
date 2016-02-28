#!/bin/bash

usuario=buscar

iface=$1
if [ -z $iface ]; then
    echo "No se especifico interfaz de red"
    exit -1
fi

ip=$(/sbin/ifconfig $iface | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

echo "Iniciando $usuario@$ip"
elixir --name $usuario@$ip -r pings2.ex --cookie de-chocolate
