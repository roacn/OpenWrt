[![Lede](https://img.shields.io/badge/source-Lede-deeppink.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede)
[![openwrt](https://img.shields.io/badge/source-openwrt-tomato.svg?style=flat&logo=appveyor)](https://github.com/openwrt/openwrt)
[![lienol](https://img.shields.io/badge/source-Lienol-yellow.svg?style=flat&logo=appveyor)](https://github.com/Lienol/openwrt)
[![Mortal](https://img.shields.io/badge/source-Mortal-green.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt)
[![apps](https://img.shields.io/badge/packages-roa-orange.svg?style=flat&logo=appveyor)](https://github.com/roacn/openwrt-packages) 


### 介绍

---

使用Lede或Openwrt源码在线编译x86固件！

<br />



### 固件编译

---

- [添加secrets](https://github.com/roacn/common/blob/main/doc/secrets.md )

| Secrets名称        | 功能                        | 备注 |
| ------------------ | --------------------------- | ---- |
| REPO_TOKEN         | Gtihub actions 编译用 token | 必须 |
| TELEGRAM_CHAT_ID   | Telegram 通知个人 ID        | 可选 |
| TELEGRAM_BOT_TOKEN | Telegram 通知 token         | 可选 |
| PUSH_PLUS_TOKEN    | Pushplus 微信通知 token     | 可选 |



- [开启缓存加速](https://github.com/roacn/common/blob/main/doc/ccache.md)



- [基本uci命令](https://github.com/roacn/common/blob/main/doc/UCI.md)



- [基本lxc操作命令](https://github.com/roacn/common/blob/main/doc/pct.md)

<br />



### 固件安装、更新

---


  - PVE lxc容器Openwrt


    - 《[lxc容器OpenWrt一键安装、更新](https://github.com/roacn/pve)》

  - 普通OpenWrt


    - 命令行输入`autoupdate`更新，详见其命令行说明；或使用`luci-app-autoupdate`插件更新(编译默认安装)

​    <br />




### 说明

---







OpenWrt用作lxc容器部署时，会有部分兼容性问题，做了以下补丁。

lxc版本OpenWrt部分补丁：

-  autocore.patch——修改CPU信息显示
-  ethinfo.patch——修复ethtool: bad command line argument(s) For more information run ethtool -h错误
-  index.patch——修复最大连接数无法获取而显示默认4096
-  sysctl.patch——网络优化

<br />



### 鸣谢

---

`coolsnowwolf` `Hyy2001X` `nicholas-opensource` `281677160` 感谢各位大佬

