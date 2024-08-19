# AntiZapret-VPN-Container

**! Рекомендую ставить [эту версию](https://github.com/GubernievS/AntiZapret-VPN) без контейнерй !**

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
Обсуждение скрипта\
https://ntc.party/t/скрипт-для-автоматического-развертывания-antizapret-vpn-container-youtube/8379

Полезные ссылки\
https://ntc.party/t/контейнер-vpn-антизапрета-для-установки-на-собственный-сервер/129 \
https://bitbucket.org/anticensority/antizapret-vpn-container/src/master/
***
Команды для настройки антизапрета описаны в самом скрипте в комментариях
***
Инструкция по настройке на роутерах [Keenetic](./Keenetic.md) и [TP-Link](./TP-Link.md)

