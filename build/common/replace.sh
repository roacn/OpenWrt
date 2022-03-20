#!/usr/bin/env bash

#====================================================
#	Author:	281677160
#	Dscription: openwrt onekey Management
#	github: https://github.com/281677160/build-actions
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[1;36m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
GX=" ${Red}[恭喜]${Font}"
ERROR="${Red}[ERROR]${Font}"

function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOR() {
  echo -e "${Red} $1 ${Font}"
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
}
function ECHOBG() {
  echo
  echo -e "${GreenBG} $1 ${Font}"
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG() {
  echo -e "${Green} $1 ${Font}"
  echo
}
function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function print_gg() {
  echo
  echo -e "${GX}${Green} $1 ${Font}"
  echo
}

ECHOB "加载数据中,请稍后..."
if [[ -f /bin/openwrt_info ]]; then
  chmod +x /bin/openwrt_info && source /bin/openwrt_info
else
  print_error "未检测到openwrt_info文件,无法运行更新程序!"
  exit 1
fi
export Github="${Github}"
export Apidz="${Github##*com/}"
export Author="${Apidz%/*}"
export CangKu="${Apidz##*/}"
export Github_API="https://api.github.com/repos/${Apidz}/releases/tags/AutoUpdate"
export Github_Release="${Github_Release}"
[[ ! -d "${Download_Path}" ]] && mkdir -p ${Download_Path} || rm -fr ${Download_Path}/*
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
export PKG_List="${Download_Path}/Installed_PKG_List"
export Kernel="$(egrep -o "Version: [0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control |sed s/[[:space:]]//g |cut -d ":" -f2)"
case ${DEFAULT_Device} in
x86-64)
  if [[ -d /sys/firmware/efi ]]; then
    export BOOT_Type="UEFI"
    export EFI_Mode="UEFI"
  else
    export BOOT_Type="Legacy"
    export EFI_Mode="Legacy"
  fi
  ;;
  *)
    export BOOT_Type="Sysupg"
    export EFI_Mode="squashfs"
esac

opapi() {
  wget -q ${Github_API} -O ${Download_Tags} > /dev/null 2>&1
  if [[ $? -ne 0 ]];then
  wget -q -P ${Download_Path} https://pd.zwc365.com/${Github_Release}/Github_Tags -O ${Download_Path}/Github_Tags > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
      wget -q -P ${Download_Path} https://ghproxy.com/${Github_Release}/Github_Tags -O ${Download_Path}/Github_Tags > /dev/null 2>&1
    fi
    if [[ $? -ne 0 ]];then
      print_error "获取固件版本信息失败,请检测网络,或者您更改的Github地址为无效地址,或者您的仓库是私库,或者发布已被删除!"
      echo
      exit 1
    fi
  fi
}

menuaz() {
  ECHOG "正在下载云端固件,请耐心等待..."
  cd ${Download_Path}
  if [[ "$(cat ${Download_Path}/Installed_PKG_List)" =~ curl ]]; then
    export Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
    if [ ! "$Google_Check" == 301 ];then
      echo
      wget -q --show-progress --progress=bar:force:noscroll "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
      if [[ $? -ne 0 ]];then
        wget -q --show-progress --progress=bar:force:noscroll "https://pd.zwc365.com/${Github_Release}/${Firmware}" -O ${Firmware}
	if [[ $? -ne 0 ]];then
	  print_error "下载云端固件失败,请尝试手动安装!"
	  exit 1
	else
	  print_ok "下载云端固件成功!"
	fi
      else
        print_ok "下载云端固件成功!"
      fi
  else
      echo
      wget -q --show-progress --progress=bar:force:noscroll "${Github_Release}/${Firmware}" -O ${Firmware}
      if [[ $? -ne 0 ]];then
        wget -q --show-progress --progress=bar:force:noscroll "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
        if [[ $? -ne 0 ]];then
          print_error "下载云端固件失败,请尝试手动安装!"
          exit 1
        else
          print_ok "下载云端固件成功!"
        fi
      else
        print_ok "下载云端固件成功!"
      fi
    fi
  fi
}

function anzhuang() {
  cd ${Download_Path}
  export CLOUD_MD5=$(md5sum ${Firmware} | cut -c1-3)
  export CLOUD_256=$(sha256sum ${Firmware} | cut -c1-3)
  export MD5_256=$(echo ${Firmware} | egrep -o "[a-zA-Z0-9]+.${Firmware_Type}" | sed -r "s/(.*).${Firmware_Type}/\1/")
  export CURRENT_MD5="$(echo "${MD5_256}" | cut -c1-3)"
  export CURRENT_256="$(echo "${MD5_256}" | cut -c 4-)"
  [[ ${CURRENT_MD5} != ${CLOUD_MD5} ]] && {
    print_error "MD5对比失败,固件可能在下载时损坏,请检查网络后重试!"
    exit 1
  }
  [[ ${CURRENT_256} != ${CLOUD_256} ]] && {
    print_error "SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!"
    exit 1
  }
  chmod 777 ${Firmware}
  [[ "$(cat ${PKG_List})" =~ gzip ]] && opkg remove gzip > /dev/null 2>&1
  ECHOG "正在更新固件,更新期间请不要断开电源或重启设备 ..."
  sleep 2
  sysupgrade -F -n ${Firmware}
}


function Firmware_Path() {
  export Name_1="$(egrep -o "${zuozhe_1}-${DEFAULT_Device}-.*-${BOOT_Type}-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
  export Name_2="$(egrep -o "${zuozhe_2}-${DEFAULT_Device}-.*-${BOOT_Type}-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"
  export Name_3="$(egrep -o "${zuozhe_3}-${DEFAULT_Device}-.*-${BOOT_Type}-.*.${Firmware_Type}" ${Download_Path}/Github_Tags | awk 'END {print}')"

  if [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
    gujian3="${Name_3}"
    gg3="3、${Name_3}"
  elif [[ -n "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_2}"
    gg2="2、${Name_2}"
  elif [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
    gujian2="${Name_3}"
    gg3="2、${Name_3}"
  elif [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_2}"
    gg2="1、${Name_2}"
    gujian2="${Name_3}"
    gg3="2、${Name_3}"
  elif [[ -n "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_1}"
    gg1="1、${Name_1}"
  elif [[ -z "${Name_1}" ]] && [[ -n "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
    gujian1="${Name_2}"
    gg2="1、${Name_2}"
  elif [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -n "${Name_3}" ]]; then
    gujian1="${Name_3}"
    gg3="1、${Name_3}"
  fi
}

menuws() {
  clear
  echo
  echo
  ECHOYY " 当前源码：${REPO_Name} / ${Luci_Edition} / ${Kernel}"
  ECHOYY " 固件格式：${EFI_Mode}.${Firmware_Type}"
  ECHOYY " 设备型号：${DEFAULT_Device}"
  echo
  if [[ -z "${Name_1}" ]] && [[ -z "${Name_2}" ]] && [[ -z "${Name_3}" ]]; then
   print_error "无其他作者固件,如需要更换请先编译出 ${tixinggg} 的固件!"
   sleep 1
   exit 1
  else
    print_gg "检测到有如下固件可供选择（敬告：如若转换,则不保留配置安装固件）"
  fi
  if [[ -z "${gg1}" ]] && [[ -z "${gg2}" ]]; then
     [[ -n "${gg3}" ]] && ECHOBG " ${gg3}"
  elif [[ -z "${gg1}" ]]; then
    [[ -n "${gg2}" ]] && ECHOBG " ${gg2}"
    [[ -n "${gg3}" ]] && ECHOBG " ${gg3}"
  else
    [[ -n "${gg1}" ]] && ECHOBG " ${gg1}"
    [[ -n "${gg2}" ]] && ECHOBG " ${gg2}"
    [[ -n "${gg3}" ]] && ECHOBG " ${gg3}"
  fi
  ECHOBG " Q、退出程序"
  echo
  echo
  XUANZHEOP=" 请输入数字,或按[Q/q]退出"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      Firmware="${gujian1}"
      menuaz
      anzhuang
    break
    ;;
    2)
      Firmware="${gujian2}"
      menuaz
      anzhuang
    break
    ;;
    3)
      Firmware="${gujian3}"
      menuaz
      anzhuang
    break
    ;;
    [Qq])
      ECHOR " 您选择了退出程序"
      echo
      exit 0
    break
    ;;
    *)
      XUANZHEOP=" 请输入正确的数字编号,或按[Q/q]退出!"
    ;;
    esac
    done
}

menu() {
  if [[ ${REPO_Name} == "lede" ]]; then
    export zuozhe_1="18.06_tl-Tianling"
    export zuozhe_2="21.02-mortal"
    export zuozhe_3="20.06-lienol"
    export tixinggg="Tianling、mortal或lienol"
    opapi
    Firmware_Path
    menuws
    clear
  elif [[ ${REPO_Name} == "lienol" ]]; then
    export zuozhe_1="18.06-lede"
    export zuozhe_2="21.02-mortal"
    export zuozhe_3="18.06_tl-Tianling"
    export tixinggg="lede、mortal或Tianling"
    opapi
    Firmware_Path
    menuws
    clear
  elif [[ ${REPO_Name} == "mortal" ]]; then
    export zuozhe_1="18.06-lede"
    export zuozhe_2="20.06-lienol"
    export zuozhe_3="18.06_tl-Tianling"
    export tixinggg="lede、lienol或Tianling"
    opapi
    Firmware_Path
    menuws
  elif [[ ${REPO_Name} == "Tianling" ]]; then
    export zuozhe_1="18.06-lede"
    export zuozhe_2="21.02-mortal"
    export zuozhe_3="20.06-lienol"
    export tixinggg="lede、mortal或lienol"
    opapi
    Firmware_Path
    menuws
    clear
  else
    print_error "没检测到您现有的源码作者!"
    exit 1
  fi
}
menu "$@"
