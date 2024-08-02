#
# Скрипт для автоматического развертывания AntiZapret VPN Container
# + Разблокирован YouTube и часть сайтов блокируемых без решения суда
# Для увеличения скорости YouTube используется UDP порт
#
# Версия 3.1 от 02.08.2024
# https://github.com/GubernievS/AntiZapret-VPN-Container
#
# Протестировано на Ubuntu 20.04   Процессор: 1 core   Память: 1 Gb   Хранилище: 10 Gb
#
# 1. Установить на VDS Ubuntu 20.04
# 2. Загрузить этот файл на сервер в папку root по SFTP (например через программу FileZilla)
# 3. В консоли под root выполнить:
# chmod +x ./antizapret-vpn.sh && ./antizapret-vpn.sh
# 4. На запрос системы выберите вручную LXD snap track = 4.0 или выше
# 5. Скопировать файл antizapret-client-udp.ovpn с сервера из папки root
#
# Полезные ссылки
# https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129
# https://bitbucket.org/anticensority/antizapret-vpn-container/src/master/
#
# Команды для обновления списка антизапрета и очистка кеша днс
# lxc exec antizapret-vpn -- sh -c "LANG=C.UTF-8 /root/antizapret/doall.sh"
# lxc exec antizapret-vpn -- sh -c "echo 'cache.clear()' | socat - /run/knot-resolver/control/1"
#
# ====================================================================================================
#
# Обновляем Ubuntu
sudo apt update && sudo apt upgrade -y
#
# Устанавливаем LXD и настраиваем
sudo apt install lxd -y
#
#  !!! На запрос системы выберите вручную LXD snap track = 4.0 или выше !!!
#
sudo lxd init --auto
#
# Импортируем и инициализируем контейнер
sudo lxc image import https://antizapret.prostovpn.org/container-images/az-vpn --alias antizapret-vpn-img
sudo lxc init antizapret-vpn-img antizapret-vpn
#
# Открываем порт только для UDP, TCP не используем
sudo lxc config device add antizapret-vpn proxy_1194_udp proxy listen=udp:[::]:1194 connect=udp:127.0.0.1:1194
# sudo lxc config device add antizapret-vpn proxy_1194 proxy listen=tcp:[::]:1194 connect=tcp:127.0.0.1:1194
#
# Запускаем контейнер и ждем пока сгенерируется файл подключения ovpn
sudo lxc start antizapret-vpn && sleep 10
#
# Настроим OpenVpn, изменяем настройки только для UDP
# Удалим txqueuelen, keepalive, comp-lzo
sudo lxc exec antizapret-vpn -- sed -i "/\b\(txqueuelen\|keepalive\|comp-lzo\)\b/d" /etc/openvpn/server/antizapret.conf
sudo lxc exec antizapret-vpn -- sed -i "/\b\(txqueuelen\|keepalive\|comp-lzo\)\b/d" /root/easy-rsa-ipsec/templates/openvpn-udp-unified.conf
sudo lxc exec antizapret-vpn -- sed -i "/\b\(txqueuelen\|keepalive\|comp-lzo\)\b/d" /root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-udp.ovpn
#
# Отключим OpenVpn TCP
sudo lxc exec antizapret-vpn -- systemctl disable openvpn-server@antizapret-tcp
#
# Перезапускаем контейнер
sudo lxc restart antizapret-vpn
#
# Получаем файл подключения только по UDP, TCP не используем
sudo lxc file pull antizapret-vpn/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-udp.ovpn antizapret-client-udp.ovpn
# sudo lxc file pull antizapret-vpn/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn antizapret-client-tcp.ovpn
#
# Применим патчи:
# 1. Патч для устройств Apple
# https://ntc.party/t/ios-macos-openvpn/4468
sudo lxc exec antizapret-vpn -- apt update && sudo apt upgrade -y
sudo lxc exec antizapret-vpn -- apt remove --purge python3-dnslib -y
sudo lxc exec antizapret-vpn -- apt autoremove -y
sudo lxc exec antizapret-vpn -- apt install python3-pip socat -y
sudo lxc exec antizapret-vpn -- pip3 install dnslib
sudo lxc exec antizapret-vpn -- wget https://raw.githubusercontent.com/nzkhammatov/antizapret_ios_patch/main/p.patch -O /root/dnsmap/p.patch
sudo lxc exec antizapret-vpn -- sh -c "cd /root/dnsmap && patch -i p.patch"
#
# 2. Патч для исключения домена с кириллическим именем в названии
# https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129/560
sudo lxc exec antizapret-vpn -- sed -i "s/idn/grep -Fv 'bеllonа' | CHARSET=UTF-8 idn/g" /root/antizapret/parse.sh
#
# Добавляем свои адреса в исключения
sudo lxc exec antizapret-vpn -- sh -c "echo 'youtube.com
youtu.be
ytimg.com
ggpht.com
googleusercontent.com
googlevideo.com
google.com
googleapis.com
bbc.co.uk
bbci.co.uk
digitalocean.com
vpngate.net
adguard.com
avira.com
mullvad.net
tor.eff.org
is.gd
s-trade.com
linktr.ee
radiojar.com
anicult.org
1plus1tv.ru
rutracker.cc
ua' >> /root/antizapret/config/include-hosts-custom.txt"
#
# Дополнительные правки для YouTube
sudo lxc exec antizapret-vpn -- sed -i "/\b\(youtube\|youtu\|ytimg\|ggpht\|googleusercontent\)\b/d" /root/antizapret/config/exclude-hosts-dist.txt
#
sudo lxc exec antizapret-vpn -- sed -i "/\b\(googleusercontent\)\b/d" /root/antizapret/config/exclude-regexp-dist.awk
#
# Обновим списки антизапрета
lxc exec antizapret-vpn -- sh -c "LANG=C.UTF-8 /root/antizapret/doall.sh"
