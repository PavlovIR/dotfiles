#!/bin/bash
set -e

resolvconf -u

vanya_gr="95.156.207.78"
vanya_ru="95.81.106.205"
DEF_GW=$(ip route show default | awk '{print $3}')

# Исключить сервер
ip route add ${vanya_gr} via ${DEF_GW}
ip route add ${vanya_ru} via ${DEF_GW}

wg-quick up wg0

# Очистить при завершении
cleanup(){
    echo "Cleaning up…"
    ip route del ${vanya_gr} via ${DEF_GW} || true
    ip route del ${vanya_ru} via ${DEF_GW} || true
}
trap cleanup EXIT
