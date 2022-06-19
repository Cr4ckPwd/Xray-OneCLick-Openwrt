#!/bin/sh
clear
NET_ADDR=$(/sbin/ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1] }')
uci add firewall redirect
uci set firewall.@redirect[-1].name='xRay'
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].src='wan'
uci set firewall.@redirect[-1].src_dport='88'
uci set firewall.@redirect[-1].dest_ip=${NET_ADDR}
uci set firewall.@redirect[-1].dest_port='88'
uci commit firewall
service firewall restart
opkg update
opkg install xray-core
opkg install libpng bash curl
opkg install qrencode libqrencode
uci set xray.enabled.enabled='1'
LTDUNG='{
  "log": {},
  "api": {
      "tag": "api",
      "services": ["HandlerService", "LoggerService", "StatsService"]
  },
  "dns": {},
  "routing": {},
  "policy": {
      "system": {
          "statsInboundUplink": true,
          "statsInboundDownlink": true
      }
  },
  "inbounds": [
      {
    "port": 88,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "ea70b8eb-ea4e-4cba-83ff-72510b4317e2",
          "level": 0,
          "email": "lethedung@admin.com"
        }
      ]
    },
    "streamSettings": {
      "network": "ws",
      "security": "none"
    }
      }
  ],
  "outbounds": [
      {
          "protocol": "freedom"
      }
  ],
  "transport": {},
  "stats": {},
  "reverse": {}
}'

QRCODE='vmess://eyJhZGQiOiIxMjMuMjcuMjguNDQiLCJhaWQiOiIwIiwiaG9zdCI6InYuYWthbWFpemVkLm5ldCIsImlkIjoiZWE3MGI4ZWItZWE0ZS00Y2JhLTgzZmYtNzI1MTBiNDMxN2UyIiwibmV0Ijoid3MiLCJwYXRoIjoiLyIsInBvcnQiOiI4MCIsInBzIjoiVGhheSAxMjMuMjcuMjguNDQgdGjDoG5oIGlwIGPhu6dhIGLhuqFuIiwic2N5Ijoibm9uZSIsInNuaSI6IiIsInRscyI6IiIsInR5cGUiOiIiLCJ2IjoiMiJ9'
echo "${LTDUNG}" >> /etc/xray/config.json
echo 'Nếu không có xuất hiện thông báo lỗi thì việc cài đặt và cấu hình xray sever đã hoàn tất'
echo 'Nhấn enter để tiếp tục'
read
clear
qrencode -t ansiutf8 "${QRCODE}"
IP=$(curl -4 ifconfig.co)
echo 'Quét qr thay ip bằng ip của bạn': "${IP}"
echo 'File shell script make by Dũng'
echo 'Gặp vấn đề gì ibox mình hỗ trợ'
echo 'Facebook: https://fb.com/100081210470123'
echo 'Đăng nhập vào trang quản lý openwrt vào theo mục System -> Startup -> tìm kiếm service tên xray và nhấn start'
echo 'Thank you for used'

