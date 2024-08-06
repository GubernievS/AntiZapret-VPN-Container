# AntiZapret-VPN-Container

Скрипт для автоматического развертывания AntiZapret VPN Container

\+ Разблокирован YouTube и часть сайтов блокируемых без решения суда

Для увеличения скорости используется UDP и 443 порт для обхода блокировки по портам

Протестировано на Ubuntu 20.04 - Процессор: 1 core Память: 1 Gb Хранилище: 10 Gb

1. Установить на VDS Ubuntu 20.04 (или новее если 2 Gb памяти)
2. Загрузить этот файл на сервер в папку root по SFTP (например через программу FileZilla)
3. В консоли под root выполнить:
```sh
chmod +x ./antizapret-vpn.sh && ./antizapret-vpn.sh
```
4. Скопировать файл antizapret-client-udp.ovpn с сервера из папки root

Обсуждение скрипта
https://ntc.party/t/скрипт-для-автоматического-развертывания-antizapret-vpn-container-youtube/8379

Полезные ссылки
https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129
https://bitbucket.org/anticensority/antizapret-vpn-container/src/master/

Изменить файл с личным списком антизапрета include-hosts-custom.txt
```sh
sudo lxc exec antizapret-vpn -- nano /root/antizapret/config/include-hosts-custom.txt
```
Потом выполните команды для обновления списка антизапрета и очистка кеша DNS
```sh
lxc exec antizapret-vpn -- sh -c /root/antizapret/doall.sh
lxc exec antizapret-vpn -- sh -c "echo 'cache.clear()' | socat - /run/knot-resolver/control/1"
```

Изменить конфигурацию OpenVpn сервера с UDP портом
```sh
sudo lxc exec antizapret-vpn -- nano /etc/openvpn/server/antizapret.conf
```
Потом перезапустить OpenVpn сервер
```sh
sudo lxc exec antizapret-vpn -- service openvpn restart
```

Инструкция по настройке на роутере [Keenetic](./Keenetic.md)

