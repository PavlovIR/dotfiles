#!/usr/bin/env bash
#
# При исчезновении текущего аудио-выхода — ставим mute на все оставшиеся, чтобы 
# «остановить» звук.

# Считаем имя дефолтного sink (например: alsa_output.pci-0000_00_1f.3.analog-stereo)
default_sink=$(wpctl status --name \
  | awk '/^\*.*Sink/ {print $2}' )
if [[ -z "$default_sink" ]]; then
  echo "Не удалось определить текущий Sink!" >&2
  exit 1
fi
echo "Мониторим вывод: $default_sink …"

while sleep 2; do
  # Проверяем, встречается ли имя default_sink в выводе wpctl
  if ! wpctl status --name | grep -qF "$default_sink"; then
    echo "$(date +'%T') » $default_sink исчез — ставим mute всем Sinks"
    # Перебираем все sink’ы по имени и мутим
    wpctl status --name \
      | awk '/Sink/ { print $2 }' \
      | while read -r sink; do
          wpctl set-muted "$sink" true
        done
    exit 0
  fi
done

