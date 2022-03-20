#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>

echo "--------------diy-part start--------------"
echo
echo '修改 IP设置'
cat >$NETIP <<-EOF
uci delete network.wan                                                               # 删除wan口
uci delete network.wan6                                                             # 删除wan6口
uci set network.lan=interface                                                     # lan口接口 
uci set network.lan.device='br-lan'                                            # lan口设备
uci set network.lan.type='bridge'                                               # lan口桥接
uci set network.lan.proto='static'                                               # lan口静态IP
uci set network.lan.ipaddr='192.168.1.5'                                    # IPv4 地址(openwrt后台地址)
uci set network.lan.netmask='255.255.255.0'                             # IPv4 子网掩码
uci set network.lan.gateway='192.168.1.1'                                 # IPv4 网关
uci set network.lan.broadcast='192.168.1.255'                           # IPv4 广播
uci set network.lan.dns='211.136.150.66 223.5.5.5'                    # DNS(多个DNS要用空格分开)
uci set network.lan.delegate='0'                                                 # 去掉LAN口使用内置的 IPv6 管理
uci set network.lan.ifname='lan1 lan2 lan3 wan'                        # 设置物理接口为lan1 lan2 lan3 wan
#uci set network.lan.mtu='1492'                                                 # lan口mtu设置为1492
uci delete network.lan.ip6assign                                                 #接口→LAN→IPv6 分配长度——关闭，恢复uci set network.lan.ip6assign='64'
uci commit network
uci delete dhcp.lan.ra                                                                  # 路由通告服务，设置为“已禁用”
uci delete dhcp.lan.ra_management                                           # 路由通告服务，设置为“已禁用”
uci delete dhcp.lan.dhcpv6                                                         # DHCPv6 服务，设置为“已禁用”
uci set dhcp.lan.ignore='1'                                                          # 关闭DHCP功能
uci set dhcp.@dnsmasq[0].filter_aaaa='1'                                   # DHCP/DNS→高级设置→解析 IPv6 DNS 记录——禁止
uci set dhcp.@dnsmasq[0].cachesize='0'                                    # DHCP/DNS→高级设置→DNS 查询缓存的大小——设置为'0'
uci add dhcp domain
uci set dhcp.@domain[0].name='mi'                                           # 网络→主机名→主机目录——“mi”
uci set dhcp.@domain[0].ip='192.168.1.5'                                  # 对应IP解析——192.168.1.5
uci add dhcp domain
uci set dhcp.@domain[1].name='cdn.jsdelivr.net'                       # 网络→主机名→主机目录——“cdn.jsdelivr.net”
uci set dhcp.@domain[1].ip='104.16.86.20'                                 # 对应IP解析——'104.16.86.20'
uci commit dhcp
uci delete firewall.@defaults[0].syn_flood                                   # 防火墙→SYN-flood 防御——关闭；默认开启
uci set firewall.@defaults[0].fullcone='1'                                     # 防火墙→FullCone-NAT——启用；默认关闭
uci commit firewall
uci set dropbear.@dropbear[0].Port='8822'                                # SSH端口设置为'8822'
uci commit dropbear
uci set system.@system[0].hostname='MI'                                 # 修改主机名称为MI
sed -i 's/\/bin\/login/\/bin\/login -f root/' /etc/config/ttyd       # 设置ttyd免帐号登录，如若开启，进入OPENWRT后可能要重启一次才生效
EOF

echo '选择argon为默认主题'
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

echo '增加个性名字 ${Author} 默认为你的github帐号'
sed -i "s/OpenWrt /Ss. compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ

echo '恢复OPKG软件源为snapshot'
sed -i '/openwrt_luci/d' $ZZZ

echo '去除防火墙规则'
sed -i '/to-ports 53/d' $ZZZ

echo '设置密码为空'
sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ

# echo 'ramips机型,默认内核5.4，修改内核为5.10'
# sed -i 's/PATCHVER:=5.4/PATCHVER:=5.10/g' target/linux/ramips/Makefile

# 解锁固件分区更改至同目录settings.ini文件UNLOCK_PARTITIONS设置项，设置为true，编译固件即为解锁分区的。
# 小米路由器Pro，修改Bdata分区为可写，ssh永久开启专用，一般为路由器刷成砖后用TTL线刷时才会有相应使用，平时须保持read-only状态！！！
# https://github.com/coolsnowwolf/lede/blob/master/target/linux/ramips/dts/mt7621_xiaomi_mi-router-3-pro.dts
# 将修改过的dts文件放入以下url路径
# https://github.com/roacn/build-actions/blob/main/build/Lede_source_R3P/diy/target/linux/ramips/dts/mt7621_xiaomi_mi-router-3-pro.dts

# 在线更新删除不想保留固件的某个文件，在EOF跟EOF直接加入删除代码，比如： rm /etc/config/luci，rm /etc/opkg/distfeeds.conf
#cat >$DELETE <<-EOF
#EOF

#############################################pushd#############################################
pushd feeds/luci
cd applications

echo "添加插件 luci-app-advanced"
rm -rf ./luci-app-advanced
git clone https://github.com/sirpdboy/luci-app-advanced

cd ../themes

echo "添加主题 new theme neobird"
rm -rf ./luci-theme-neobird
git clone https://github.com/thinktip/luci-theme-neobird.git

#############################################
#echo "添加插件 luci-app-aliyundrive-webdav"
#rm -rf ./luci-app-aliyundrive-webdav
#rm -rf ./aliyundrive-webdav
#svn co https://github.com/messense/aliyundrive-webdav/trunk/openwrt/luci-app-aliyundrive-webdav
#svn co https://github.com/messense/aliyundrive-webdav/trunk/openwrt/aliyundrive-webdav

#echo "添加插件 luci-app-diskman"
#rm -rf ./luci-app-diskman
#git clone --depth=1 https://github.com/lisaac/luci-app-diskman
#mkdir parted
#cp luci-app-diskman/Parted.Makefile parted/Makefile

#echo "添加插件 luci-app-onliner (need luci-app-nlbwmon)"
#git clone --depth=1 https://github.com/rufengsuixing/luci-app-onliner

#echo "添加插件 luci-app-serverchan"
#rm -rf ./luci-app-serverchan
#git clone --depth=1 https://github.com/tty228/luci-app-serverchan

#echo "添加插件 luci-app-dockerman"
#rm -rf ./luci-app-dockerman
#rm -rf ./luci-lib-docker
#svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman
#svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker

#echo "添加插件 luci-app-passwall"
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall

#echo "添加插件 luci-app-ssr-plus"
#git clone --depth=1 https://github.com/fw876/helloworld luci-app-ssr-plus

#echo "添加主题 luci-theme-argon"
#rm -rf ./luci-theme-argon
#git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon

#echo "添加主题 new theme jj"
#git clone --depth=1 https://github.com/netitgo/luci-theme-jj.git
#############################################

popd
#############################################popd#############################################

#############################################pushd#############################################
#Clone community packages to package/community
#mkdir package/community
#pushd package/community

#echo "克隆 kenzok8/openwrt-packages"
#git clone --depth=1 https://github.com/kenzok8/openwrt-packages
##使用原作者
#rm -rf ./openwrt-packages/{luci-app-diskman,luci-app-serverchan,luci-app-aliyundrive-webdav,aliyundrive-webdav}
#rm -rf ./openwrt-packages/{luci-app-passwall,luci-app-ssr-plus,luci-app-ssr-mudb-server,naiveproxy,tcping}
#rm -rf ./openwrt-packages/{luci-theme-argon_new,luci-app-jd-dailybonus}
##smartdns源码出问题，暂删除
#rm -rf ./openwrt-packages/{luci-app-smartdns,smartdns}

#echo "克隆 kenzok8/small"
#git clone --depth=1 https://github.com/kenzok8/small
#rm -rf ./small/{shadowsocks-rust,shadowsocksr-libev,v2ray-core,v2ray-plugin,xray-core,xray-plugin}

#popd
#############################################popd#############################################

echo "修改插件名字"
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"Turbo ACC"/g' `grep "Turbo ACC 网络加速" -rl ./`
#sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./`

# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间
cat >${GITHUB_WORKSPACE}/Clear <<-EOF
rm -rf config.buildinfo
rm -rf feeds.buildinfo
rm -rf version.buildinfo
rm -rf *.manifest
rm -rf sha256sums
EOF

echo
echo "--------------diy-part end--------------"
