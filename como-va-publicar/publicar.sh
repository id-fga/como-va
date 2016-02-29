#!/bin/bash

usuario=mxt
iface=$1
if [ -z $iface ]; then
    echo "No se especifico interfaz de red"
    exit -1
fi

ip=$(/sbin/ifconfig $iface | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
#iex --name $usuario@$ip --cookie de-chocolate

elixir --name $usuario@$ip -r esperar2.ex --cookie de-chocolate
