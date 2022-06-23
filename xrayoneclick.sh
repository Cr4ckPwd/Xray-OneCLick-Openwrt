clear
NET_ADDR=$(/sbin/ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1] }')
uci add firewall redirect
uci set firewall.@redirect[-1].name='xRay'
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].src='wan'
uci set firewall.@redirect[-1].src_dport='80'
uci set firewall.@redirect[-1].dest_ip=${NET_ADDR}
uci set firewall.@redirect[-1].dest_port='80'
uci commit firewall
/etc/init.d/firewall restart
opkg update
opkg install xray-core
opkg install libpng bash curl
opkg install qrencode libqrencode
opkg install coreutils-base64
uci set xray.enabled.enabled='1'
UUID=$(xray uuid)
NAME=$(uname -m -0)
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
    "port": 80,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "'${UUID}'",
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
IP=$(curl -4 ifconfig.co)
VMESSCODE='{"add":"'${IP}'","aid":"0","host":"v.akamaized.net","id":"'${UUID}'","net":"ws","path":"/","port":"80","ps":"'${name}'","scy":"none","sni":"","tls":"","type":"","v":"2"}'
echo "${VMESSCODE}" >> ./vmess.json
QRVMESS=$(base64 -i ./vmess.json)
QRCODE='vmess://'${QRVMESS}''
echo "${LTDUNG}" >> /etc/xray/config.json
clear
qrencode -t ansiutf8 "${QRCODE}"
echo 'File shell script make by Dũng'
echo 'Gặp vấn đề gì ibox mình hỗ trợ'
echo 'Facebook: https://fb.com/100081210470123'
/etc/init.d/xray start
