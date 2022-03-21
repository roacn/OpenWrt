#!/bin/bash

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip

cp -Rf /etc/config/network /mnt/network

if [[ -f /etc/crontabs/root ]]; then
  sed -i '/mp\/luci-/d' /etc/crontabs/root && echo "0 1 * * 1 rm -rf /tmp/luci-*cache > /dev/null 2>&1" >> /etc/crontabs/root
else
  mkdir -p /etc/crontabs
  echo "0 1 * * 1 rm -rf /tmp/luci-*cache > /dev/null 2>&1" > /etc/crontabs/root
  chmod -R 755 /etc/crontabs
fi

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  source /etc/openwrt_release
  sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
fi

if [[ -d /usr/share/AdGuardHome ]] && [[ -f /etc/init.d/AdGuardHome ]]; then
 chmod -R 775 /usr/share/AdGuardHome /etc/init.d/AdGuardHome
else
  rm -fr /etc/config/AdGuardHome.yaml
  rm -fr /etc/AdGuardHome.yaml
fi

chmod -R 775 /etc/init.d /usr/share

if [[ -f /etc/init.d/ddnsto ]]; then
 chmod 775 /etc/init.d/ddnsto
 /etc/init.d/ddnsto enable
fi

if [[ -d /usr/lib/lua/luci/view/themes/argon ]]; then
  uci set argon.@global[0].bing_background=0
  uci commit argon
fi

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
