# AntiZapret-VPN-Container

**! Для большей скорости рекомендую ставить [версию без контейнера](https://github.com/GubernievS/AntiZapret-VPN) или [версию в докер контейнере](https://github.com/xtrime-ru/antizapret-vpn-docker) от камрада xtrime-ru!**

Скрипт для автоматического развертывания AntiZapret VPN Container\
\+ Разблокирован YouTube и часть сайтов блокируемых без решения суда

Поддерживается подключение по UDP и TCP\
Используется 443 порт вместо 1194 для обхода блокировки по порту

Протестировано на Ubuntu 20.04 - Процессор: 1 core Память: 1 Gb Хранилище: 10 Gb
***
### Установка:
1. Устанавливать на чистую Ubuntu 20.04 (или новее если памяти 2 Gb и больше)
2. Загрузить [этот файл](https://github.com/GubernievS/AntiZapret-VPN-Container/blob/main/antizapret-vpn.sh) на сервер в папку root по SFTP (например через программу FileZilla)
3. В консоли под root выполнить:
```sh
chmod +x ./antizapret-vpn.sh && ./antizapret-vpn.sh
```
4. Скопировать файл antizapret-client-udp.ovpn или antizapret-client-tcp.ovpn с сервера из папки root
***
Обсуждение скрипта [тут](https://ntc.party/t/скрипт-для-автоматического-развертывания-antizapret-vpn-container-youtube/8379)

Полезные ссылки [раз](https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129) [два](https://bitbucket.org/anticensority/antizapret-vpn-container/src/master)
***
Команды для настройки антизапрета описаны в самом скрипте в комментариях
***
Инструкция по настройке на роутерах [Keenetic](./Keenetic.md) и [TP-Link](./TP-Link.md)
***
Хостинги для VPN принимающие рубли: [vdsina.com](https://www.vdsina.com/?partner=9br77jaat2) со скидкой 10% и [aeza.net](https://aeza.net/?ref=529527) с бонусом 15% (бонус действует 24ч)
