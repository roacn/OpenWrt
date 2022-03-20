#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Functions

GET_TARGET_INFO() {
	if [[ "${REPO_BRANCH}" == "master" ]]; then
		export LUCI_Name="18.06"
		export REPO_Name="lede"
		export ZUOZHE="Lean's"
	elif [[ "${REPO_BRANCH}" == "main" ]]; then
		export LUCI_Name="20.06"
		export REPO_Name="lienol"
		export ZUOZHE="Lienol's"
	elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
		export LUCI_Name="18.06_tl"
		export REPO_Name="Tianling"
		export ZUOZHE="ctcgfw"
	elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
		export LUCI_Name="21.02"
		export REPO_Name="mortal"
		export ZUOZHE="ctcgfw"
	else
		echo "没匹配到该源码的分支"
	fi
	
	if [[ "${TARGET_PROFILE}" == "x86-64" ]] || [[ "${TARGET_PROFILE}" == "x86-64-lxc" ]]; then
		[[ `grep -c "CONFIG_TARGET_IMAGES_GZIP=y" ${Home}/.config` -ge '1' ]] && export Firmware_sfxo="img.gz" || export Firmware_sfxo="img"
		export Legacy_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined.${Firmware_sfxo}"
		export UEFI_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined-efi.${Firmware_sfxo}"
		export ROOTFS_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-rootfs.${Firmware_sfxo}"
		export Firmware_sfx="${Firmware_sfxo}"
	elif [[ "${TARGET_PROFILE}" =~ (phicomm_k3|phicomm-k3) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="phicomm_k3"
		export Up_Firmware="openwrt-bcm53xx-generic-${TARGET_PROFILE}-squashfs.trx"
		export Firmware_sfx="trx"
	elif [[ "${TARGET_PROFILE}" =~ (k2p|phicomm_k2p|phicomm-k2p) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="phicomm_k2p"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
		export Firmware_sfx="bin"
	elif [[ "${TARGET_PROFILE}" =~ (xiaomi_mi-router-3g-v2|xiaomi_mir3g_v2) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3g-v2"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
		export Firmware_sfx="bin"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3g" ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3g"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
		export Firmware_sfx="bin"
	elif [[ "${TARGET_PROFILE}" =~ (xiaomi_mi-router-3-pro|xiaomi_mir3p) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3p"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
		export Firmware_sfx="bin"
	else
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
		export Firmware_sfx="bin"
	fi
	
	AutoUp_Ver="${Home}/package/base-files/files/bin/AutoUpdate.sh"
	[[ -f ${AutoUp_Ver} ]] && export AutoUpdate_Version=$(egrep -o "V[0-9].+" ${Home}/package/base-files/files/bin/AutoUpdate.sh | awk 'END{print}')
	export In_Firmware_Info="${Home}/package/base-files/files/bin/openwrt_info"
	export Github_Release="${Github}/releases/download/AutoUpdate"
	export Github_UP_RELEASE="${Github}/releases/AutoUpdate"
	export Openwrt_Version="${REPO_Name}-${TARGET_PROFILE}-${Compile_Date}"
	export Egrep_Firmware="${LUCI_Name}-${REPO_Name}-${TARGET_PROFILE}"
}

Diy_Part1() {
sed  -i  's/ luci-app-autoupdate luci-app-ttyd//g' target/linux/*/Makefile
sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += luci-app-autoupdate luci-app-ttyd/g' target/linux/*/Makefile
}

Diy_Part2() {
	GET_TARGET_INFO
	echo "--------------upgrade_Diy_Part2 start--------------"
	echo
	cat >${In_Firmware_Info} <<-EOF
	Github=${Github}
	Luci_Edition=${OpenWrt_name}
	CURRENT_Version=${Openwrt_Version}
	DEFAULT_Device=${TARGET_PROFILE}
	Firmware_Type=${Firmware_sfx}
	LUCI_Name=${LUCI_Name}
	REPO_Name=${REPO_Name}
	Github_Release=${Github_Release}
	Egrep_Firmware=${Egrep_Firmware}
	Download_Path=/tmp/Downloads
	Version=${AutoUpdate_Version}
	Download_Tags=/tmp/Downloads/Github_Tags
	EOF
	echo "${In_Firmware_Info}"
	cat ${In_Firmware_Info}
	echo
	echo "--------------upgrade_Diy_Part2 end--------------"
}

Diy_Part3() {
	GET_TARGET_INFO
	echo "--------------upgrade_Diy_Part3 start--------------"
	echo
	export AutoBuild_Firmware="${LUCI_Name}-${Openwrt_Version}"
	export Firmware_Path="${Home}/upgrade"
	echo "files under ${Home}/upgrade:"
	ls ${Firmware_Path}
	echo
	echo "files under ${Home}/bin/targets/*/*:"
	ls ${Home}/bin/targets/*/* 2>/dev/null
	echo
	echo "files operations:"
	Mkdir ${Home}/bin/Firmware
	Mkdir ${Home}/bin/zhuanyi_Firmware
	export Zhuan_Yi="${Home}/bin/zhuanyi_Firmware"
	# move files from openwrt/upgrade/ to openwrt/bin/zhuanyi_Firmware/, after then make a reverse operation.
	cd "${Firmware_Path}"
	if [[ `ls ${Firmware_Path} | grep -c "immortalwrt"` -ge '1' ]]; then
		rename -v "s/^immortalwrt/openwrt/" *
	fi
	if [[ "${TARGET_PROFILE}" == "x86-64" ]] || [[ "${TARGET_PROFILE}" == "x86-64-lxc" ]]; then
		if [[ `ls "${Firmware_Path}" | grep -c "ext4"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*ext4* ${Home}/bin/targets/ && echo "move ${Firmware_Path}/*ext4* to ${Home}/bin/targets/"
		fi
		if [[ `ls "${Firmware_Path}" | grep -c "${Firmware_sfx}"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*${Firmware_sfx}* "${Zhuan_Yi}" && echo "move ${Firmware_Path}/*${Firmware_sfx}* to ${Zhuan_Yi}"
			if [[ `ls "${Zhuan_Yi}" | grep -c "rootfs"` -eq '1' ]]; then
				mv -f "${Zhuan_Yi}"/*rootfs* "${Firmware_Path}/${ROOTFS_Firmware}" && echo "move ${Zhuan_Yi}/*rootfs* to ${Firmware_Path}/${ROOTFS_Firmware}"
			fi
			if [[ `ls "${Zhuan_Yi}" | grep -c "efi"` -eq '1' ]]; then
				mv -f "${Zhuan_Yi}"/*efi* "${Firmware_Path}/${UEFI_Firmware}" && echo "move ${Zhuan_Yi}/*efi* to ${Firmware_Path}/${UEFI_Firmware}"
			fi
			if [[ `ls "${Zhuan_Yi}" | grep -c "squashfs"` -eq '1' ]]; then
				mv -f "${Zhuan_Yi}"/*squashfs* "${Firmware_Path}/${Legacy_Firmware}" && echo "move ${Zhuan_Yi}/*squashfs* to ${Firmware_Path}/${Legacy_Firmware}"
			fi
		fi
	fi
	if [[ "${TARGET_PROFILE}" =~ (phicomm_k3|phicomm-k3) ]]; then
		rename -v "s/${Rename}/phicomm_k3/" * > /dev/null 2>&1
		cp -rf ${Firmware_Path}/*${TARGET_PROFILE}* ${Zhuan_Yi}
		rm -rf ${Firmware_Path}/${Up_Firmware}
		mv -f ${Zhuan_Yi}/*.trx ${Firmware_Path}/${Up_Firmware} && echo "move ${Zhuan_Yi}/*.trx to ${Firmware_Path}/${Up_Firmware}"
	fi
	if [[ `ls ${Firmware_Path} | grep -c "sysupgrade.bin"` -ge '1' ]]; then
		if [[ `ls | grep -c "xiaomi_mi-router-3g-v2"` -ge '1' ]]; then
			rename -v "s/${Rename}/xiaomi_mir3g_v2/" * > /dev/null 2>&1
		elif [[ `ls | grep -c "xiaomi_mi-router-3g"` -ge '1' ]]; then
			rename -v "s/${Rename}/xiaomi_mir3g/" * > /dev/null 2>&1
		elif [[ `ls | grep -c "xiaomi_mi-router-3-pro"` -ge '1' ]]; then
			rename -v "s/${Rename}/xiaomi_mir3p/" * > /dev/null 2>&1
		elif [[ `ls | grep -c "phicomm-k2p"` -ge '1' ]]; then
			rename -v "s/${Rename}/phicomm_k2p/" * > /dev/null 2>&1
		fi
		cp -rf ${Firmware_Path}/*${TARGET_PROFILE}* ${Zhuan_Yi}
		if [[ `ls ${Zhuan_Yi} | grep -c "sysupgrade.bin"` -eq '1' ]]; then
			rm -rf ${Firmware_Path}/${Up_Firmware}
			mv -f ${Zhuan_Yi}/*sysupgrade.bin ${Firmware_Path}/${Up_Firmware} && echo "move ${Zhuan_Yi}/*sysupgrade.bin to ${Firmware_Path}/${Up_Firmware}"
		else
			echo "没发现.bin后缀固件，或者是您编译的固件体积超出源码规定值，出不来.bin格式固件"
		fi
	fi
	# copy files from openwrt/upgrade/ to openwrt/bin/Firmware/
	cd "${Firmware_Path}"
	case "${TARGET_PROFILE}" in
	x86-64)
		[[ -f ${Legacy_Firmware} ]] && {
			MD5=$(md5sum ${Legacy_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${Legacy_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${Legacy_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy-${SHA5BIT}.${Firmware_sfx}
			echo "copy ${Legacy_Firmware} to ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy-${SHA5BIT}.${Firmware_sfx}"
		}
		[[ -f ${UEFI_Firmware} ]] && {
			MD5=$(md5sum ${UEFI_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${UEFI_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${UEFI_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI-${SHA5BIT}.${Firmware_sfx}
			echo "copy ${UEFI_Firmware} to ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI-${SHA5BIT}.${Firmware_sfx}"
		}
	;;
	x86-64-lxc)
		[[ -f ${ROOTFS_Firmware} ]] && {
			MD5=$(md5sum ${ROOTFS_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${ROOTFS_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${ROOTFS_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-rootfs-${SHA5BIT}.${Firmware_sfx}
			echo "copy ${Firmware_Path}/${ROOTFS_Firmware} to ${Home}/bin/Firmware/${AutoBuild_Firmware}-rootfs-${SHA5BIT}.${Firmware_sfx}"
		}
	;;
	*)
		[[ -f ${Up_Firmware} ]] && {
			MD5=$(md5sum ${Up_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${Up_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${Up_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Sysupg-${SHA5BIT}.${Firmware_sfx}
			echo "copy ${Up_Firmware} to ${Home}/bin/Firmware/${AutoBuild_Firmware}-Sysupg-${SHA5BIT}.${Firmware_sfx}"
		} || {
			echo "Firmware is not detected !"
		}
	;;
	esac
	cd ${Home}
	echo
	echo "--------------upgrade_Diy_Part3 end--------------"
}

Mkdir() {
	_DIR=${1}
	if [ ! -d "${_DIR}" ];then
		mkdir -p ${_DIR}
	fi
	unset _DIR
}
