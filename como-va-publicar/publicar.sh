#!/bin/bash

iface=eth1

ip=$(/sbin/ifconfig eth1 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
iex --name mxt@$ip --cookie de-chocolate
