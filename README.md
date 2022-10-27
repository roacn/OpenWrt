![x86-64-lxc](https://github.com/roacn/build-actions/workflows/编译x86-64-lxc固件/badge.svg?)
![x86-64](https://github.com/roacn/build-actions/workflows/编译x86-64固件/badge.svg?)
![armvirt](https://github.com/roacn/build-actions/workflows/编译armvirt固件/badge.svg?)





### 介绍

---

| 源码                                                         | Luci版本                          | 内核版本        | 说明                    |
| ------------------------------------------------------------ | --------------------------------- | --------------- | ----------------------- |
| [![Lede](https://img.shields.io/badge/source-Lede-deeppink.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede) | 18.06                             | 5.4、5.10、5.15 |                         |
| [![lienol](https://img.shields.io/badge/source-Lienol-tomato.svg?style=flat&logo=appveyor)](https://github.com/Lienol/openwrt/tree/19.07) | 19.07、21.02、22.03               | 4.14            |                         |
| [![Mortal](https://img.shields.io/badge/source-Mortal-yellow.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt/tree/openwrt-21.02) | 21.02                             | 5.4             |                         |
| [![Tianling](https://img.shields.io/badge/source-Tianling-green.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt/tree/openwrt-18.06) | 18.06                             | 4.19、4.14      |                         |
| [![Lede](https://img.shields.io/badge/source-Lede-deeppink.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede) | 18.06                             | 5.4、5.10、5.15 | N1和晶晨系列CPU盒子专用 |
| [![openwrt](https://img.shields.io/badge/source-openwrt-blue.svg?style=flat&logo=appveyor)](https://github.com/openwrt/openwrt) | 17.01、18.06、19.07、21.02、22.03 | 5.4、5.10       | OpenWrt                 |
| [![apps](https://img.shields.io/badge/packages-roa-orange.svg?style=flat&logo=appveyor)](https://github.com/roacn/openwrt-packages) | 18.06、19.07                      | 5.4、5.10、5.15 | 常用插件库              |
| [![apps](https://img.shields.io/badge/applications-roa-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/roacn/compile-packages) | 18.06、19.07                      | 5.4、5.10、5.15 | 插件编译，定时更新      |





### 编译

---

- 《[lxc容器OpenWrt一键安装、更新](https://github.com/roacn/pve)》

- 《[IPV4/IPV6选择](https://github.com/roacn/shuoming/blob/master/%E5%85%B6%E4%BB%96%E8%AF%B4%E6%98%8E.md)》

- 《[NTFS格式U盘挂载](https://github.com/roacn/shuoming/blob/master/NTFS%E6%A0%BC%E5%BC%8F%E4%BC%98%E7%9B%98%E6%8C%82%E8%BD%BD)》

- 《[X86编译时选固件格式和设置overlay空间容量](https://github.com/roacn/shuoming/blob/master/overlay.md)》

- 《[固件vmdk格式转换](https://github.com/roacn/myFavorites/blob/main/ESXI/%E5%9B%BA%E4%BB%B6vmdk%E6%A0%BC%E5%BC%8F%E8%BD%AC%E6%8D%A2.md)》






### 说明

---

OpenWrt用作lxc容器部署时，会有部分兼容性问题，做了以下补丁，目前完美运行。

lxc版本OpenWrt部分补丁：

-  autocore.patch——修改CPU信息显示
-  ethinfo.patch——修复ethtool: bad command line argument(s) For more information run ethtool -h错误
-  index.patch——修复最大连接数无法获取而显示默认4096
-  sysctl.patch——网络优化





### 鸣谢

---

> [`coolsnowwolf`](https://github.com/coolsnowwolf/lede.git) [`Hyy2001X`](https://github.com/Hyy2001X/AutoBuild-Actions) [`ophub`](https://github.com/ophub/amlogic-s9xxx-openwrt)  [`nicholas-opensource`](https://github.com/nicholas-opensource/OpenWrt-Autobuild) [`281677160`](https://github.com/281677160) [`感谢各位大佬提供的各种各样的插件`](#/README.md)

