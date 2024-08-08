#
# Скрипт для автоматического развертывания AntiZapret VPN Container
# + Разблокирован YouTube и часть сайтов блокируемых без решения суда
# Для увеличения скорости используется UDP и 443 порт для обхода блокировки по портам
#
# Версия 5.7 от 07.08.2024
# https://github.com/GubernievS/AntiZapret-VPN-Container
#
# Протестировано на Ubuntu 20.04 - Процессор: 1 core Память: 1 Gb Хранилище: 10 Gb
#
# Установка:
# 1. Устанавливать на чистую Ubuntu 20.04 (или новее если памяти 2 Gb и больше)
# 2. Загрузить этот файл на сервер в папку root по SFTP (например через программу FileZilla)
# 3. В консоли под root выполнить:
# chmod +x ./antizapret-vpn.sh && ./antizapret-vpn.sh
# 4. Скопировать файл antizapret-client-udp.ovpn с сервера из папки root
#
# Обсуждение скрипта
# https://ntc.party/t/скрипт-для-автоматического-развертывания-antizapret-vpn-container-youtube/8379
#
# Полезные ссылки
# https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129
# https://bitbucket.org/anticensority/antizapret-vpn-container/src/master/
#
# Изменить файл с личным списком антизапрета include-hosts-custom.txt
# sudo lxc exec antizapret-vpn -- nano /root/antizapret/config/include-hosts-custom.txt
# Потом выполните команды для обновления списка антизапрета и очистка кеша DNS
# sudo lxc exec antizapret-vpn -- /root/antizapret/doall.sh
# sudo lxc exec antizapret-vpn -- sh -c "echo 'cache.clear()' | socat - /run/knot-resolver/control/1"
#
# Изменить конфигурацию OpenVpn сервера с UDP портом
# sudo lxc exec antizapret-vpn -- nano /etc/openvpn/server/antizapret.conf
# Потом перезапустить OpenVpn сервер
# sudo lxc exec antizapret-vpn -- service openvpn restart
#
# Посмотреть статистику подключений OpenVpn (выход Ctrl+X)
# sudo lxc exec antizapret-vpn -- nano /etc/openvpn/server/logs/status.log -v
#
# ====================================================================================================
#
# Обновляем Ubuntu
sudo apt update && sudo apt upgrade -y
#
# Устанавливаем LXD и настраиваем
sudo apt install snapd -y
sudo snap install lxd --channel=latest/stable
sudo lxd init --auto
#
# Импортируем и инициализируем контейнер
sudo lxc image import https://antizapret.prostovpn.org/container-images/az-vpn --alias antizapret-vpn-img
sudo lxc init antizapret-vpn-img antizapret-vpn
#
# Открываем порт только для UDP, TCP не используем
sudo lxc config device add antizapret-vpn proxy_443_udp proxy listen=udp:[::]:443 connect=udp:127.0.0.1:443
# sudo lxc config device add antizapret-vpn proxy_1194 proxy listen=tcp:[::]:1194 connect=tcp:127.0.0.1:1194
#
# Запускаем контейнер и ждем пока сгенерируется файл подключения ovpn
sudo lxc start antizapret-vpn && sleep 10
#
# Настраиваем OpenVpn, изменяем настройки только для UDP
# Удалим keepalive, comp-lzo, увеличим txqueuelen до 1000, добавим fast-io и cipher AES-128-GCM, изменим порт с 1194 на 443
sudo lxc exec antizapret-vpn -- sed -i '/^[[:space:]]*$/d;/\b\(txqueuelen\|keepalive\)\b/d;s/comp-lzo/port 443\
txqueuelen 1000\
fast-io/g' /etc/openvpn/server/antizapret.conf
sudo lxc exec antizapret-vpn -- sed -i '/^[@#]/d;/^[[:space:]]*$/d;s/comp-lzo/port 443\
cipher AES-128-GCM/g' /root/easy-rsa-ipsec/templates/openvpn-udp-unified.conf
sudo lxc exec antizapret-vpn -- sed -i '/^[@#]/d;/^[[:space:]]*$/d;s/comp-lzo/port 443\
cipher AES-128-GCM/g' /root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-udp.ovpn
#
# Отключаем OpenVpn TCP
sudo lxc exec antizapret-vpn -- systemctl disable openvpn-server@antizapret-tcp
#
# Получаем файл подключения только по UDP, TCP не используем
sudo lxc file pull antizapret-vpn/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-udp.ovpn antizapret-client-udp.ovpn
# sudo lxc file pull antizapret-vpn/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn antizapret-client-tcp.ovpn
#
# Ставим патч для устройств Apple https://ntc.party/t/ios-macos-openvpn/4468
sudo lxc exec antizapret-vpn -- apt update && sudo apt upgrade -y
sudo lxc exec antizapret-vpn -- apt remove --purge python3-dnslib -y
sudo lxc exec antizapret-vpn -- apt autoremove -y
sudo lxc exec antizapret-vpn -- apt install python3-pip socat -y
sudo lxc exec antizapret-vpn -- pip3 install dnslib
sudo lxc exec antizapret-vpn -- wget https://raw.githubusercontent.com/nzkhammatov/antizapret_ios_patch/main/p.patch -O /root/dnsmap/p.patch
sudo lxc exec antizapret-vpn -- sh -c "cd /root/dnsmap && patch -i p.patch"
#
# Обновляем antizapret до последней версии из репозитория
sudo lxc exec antizapret-vpn -- mv -f /root/antizapret/process.sh /root/antizapret-process.sh
sudo lxc exec antizapret-vpn -- rm -rf /root/antizapret
sudo lxc exec antizapret-vpn -- git clone https://bitbucket.org/anticensority/antizapret-pac-generator-light.git /root/antizapret
sudo lxc exec antizapret-vpn -- mv -f /root/antizapret-process.sh /root/antizapret/process.sh
#
# Добавляем свои адреса в исключения и адреса из https://bitbucket.org/anticensority/russian-unlisted-blocks/src/master/readme.txt
sudo lxc exec antizapret-vpn -- sh -c "echo 'youtube.com
googlevideo.com
ytimg.com
ggpht.com
googleapis.com
gstatic.com
gvt1.com
gvt2.com
gvt3.com
digitalocean.com
strava.com
adguard-vpn.com
tor.eff.org
news.google.com
play.google.com
twimg.com
bbc.co.uk
bbci.co.uk
radiojar.com
xvideos.com
doubleclick.net
windscribe.com
vpngate.net
rebrand.ly
adguard.com
antizapret.prostovpn.org
avira.com
mullvad.net
invent.kde.org
s-trade.com
ua
is.gd
1plus1tv.ru
linktr.ee
is.gd
anicult.org
12putinu.net
padlet.com' > /root/antizapret/config/include-hosts-custom.txt"
#
# Удаляем исключения из исключений
sudo lxc exec antizapret-vpn -- sed -i "/\b\(youtube\|youtu\|ytimg\|ggpht\|googleusercontent\|cloudfront\|ftcdn\)\b/d" /root/antizapret/config/exclude-hosts-dist.txt
sudo lxc exec antizapret-vpn -- sed -i "/\b\(googleusercontent\|cloudfront\|deviantart\)\b/d" /root/antizapret/config/exclude-regexp-dist.awk
#
# Добавляем AdGuard DNS для блокировки рекламы, отслеживающих модулей и фишинга
sudo lxc exec antizapret-vpn -- sh -c "echo '
policy.add(policy.all(policy.FORWARD({\'94.140.14.14\'})))
policy.add(policy.all(policy.FORWARD({\'94.140.15.15\'})))' >> /etc/knot-resolver/kresd.conf"
#
# Обновляем списки антизапрета
sudo lxc exec antizapret-vpn -- /root/antizapret/doall.sh
sudo lxc exec antizapret-vpn -- sh -c "echo 'cache.clear()' | socat - /run/knot-resolver/control/1"
#
# Перезапускаем контейнер антизапрета
sudo lxc restart antizapret-vpn
