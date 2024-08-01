# AntiZapret-VPN-Container

Скрипт для автоматического развертывания AntiZapret VPN Container
Разблокирован YouTube и часть сайтов блокируемых без решения суда

Протестировано на Ubuntu 20.04   Процессор: 1 core   Память: 1 Gb   Хранилище: 10 Gb

1. Установить на VDS Ubuntu 20.04
2. Загрузить этот файл на сервер в папку root по SFTP (например через программу FileZilla)
3. В консоли под root выполнить:
chmod +x ./antizapret-vpn.sh && ./antizapret-vpn.sh
4. Указать вручную LXD snap track = 4.0
5. Скопировать файл antizapret-client-tcp.ovpn с сервера из папки root

Полезные ссылки
https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129
https://bitbucket.org/anticensority/antizapret-vpn-container/src/master/

Команды для обновления списка антизапрета и очистка кеша днс
lxc exec antizapret-vpn -- sh -c "LANG=C.UTF-8 /root/antizapret/doall.sh"
lxc exec antizapret-vpn -- sh -c "echo 'cache.clear()' | socat - /run/knot-resolver/control/1"
