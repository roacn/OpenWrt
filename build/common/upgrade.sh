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
	
	export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${Home}/.config)"
	export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' ${Home}/.config)"
	if [[ `grep -c "CONFIG_TARGET_x86_64=y" ${Home}/.config` -eq '1' ]]; then
		export TARGET_PROFILE="x86-64"
	elif [[ `grep -c "CONFIG_TARGET_x86=y" ${Home}/.config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" ${Home}/.config` == '0' ]]; then
		export TARGET_PROFILE="x86_32"
	elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" ${Home}/.config` -eq '1' ]]; then
		export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" ${Home}/.config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
	else
		export TARGET_PROFILE="${TARGET_BOARD}"
	fi
	
	if [[ "${TARGET_PROFILE}" =~ (phicomm_k3|phicomm-k3) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="phicomm_k3"
	elif [[ "${TARGET_PROFILE}" =~ (k2p|phicomm_k2p|phicomm-k2p) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="phicomm_k2p"
	elif [[ "${TARGET_PROFILE}" =~ (xiaomi_mi-router-3g-v2|xiaomi_mir3g_v2) ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3g-v2"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3g" ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3g"
	elif [[ "${TARGET_PROFILE}" == "xiaomi_mi-router-3-pro" ]]; then
		export Rename="${TARGET_PROFILE}"
		export TARGET_PROFILE="xiaomi_mir3p"
	else
		export TARGET_PROFILE="${TARGET_PROFILE}"
	fi
	
	case "${TARGET_BOARD}" in
	ramips | reltek | ath* | ipq* | bcm47xx | bmips | kirkwood | mediatek)
		export Firmware_sfx="bin"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.${Firmware_sfx}"
	;;
	x86 | rockchip | bcm27xx | mxs | sunxi | zynq)
		export Firmware_sfx="img.gz"
		export Legacy_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined.${Firmware_sfx}"
		export UEFI_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined-efi.${Firmware_sfx}"
		export ROOTFS_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-rootfs.${Firmware_sfxo}"
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			export Firmware_sfx="img.gz"
			export Legacy_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined.${Firmware_sfx}"
			export UEFI_Firmware="openwrt-${TARGET_PROFILE}-generic-squashfs-combined-efi.${Firmware_sfx}"
		;;
		esac
	;;
	bcm53xx)
		export Firmware_sfx="trx"
		export Up_Firmware="openwrt-bcm53xx-generic-${TARGET_PROFILE}-squashfs.${Firmware_sfx}"
	;;
	octeon | oxnas | pistachio)
		export Firmware_sfx="tar"
		export Up_Firmware="openwrt-${TARGET_BOARD}-generic-${TARGET_PROFILE}-squashfs.tar"
	;;
	*)
		export Firmware_sfx="bin"
		export Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.${Firmware_sfx}"
	;;
	esac
	
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
	Mkdir ${Home}/bin/Firmware
	export Zhuan_Yi="${Home}/bin/zhuanyi_Firmware"
	export Diuqu_gj="${Home}/bin/targets/diuqugj"
	rm -rf ${Zhuan_Yi} && Mkdir ${Zhuan_Yi}
	rm -rf "${Diuqu_gj}" && Mkdir "${Diuqu_gj}"
	echo "${TARGET_BOARD}" > ${Zhuan_Yi}/1234
	# move files from openwrt/upgrade/ to openwrt/bin/zhuanyi_Firmware/, after then make a reverse operation.
	cd ${Firmware_Path}
	if [[ `ls ${Firmware_Path} | grep -c ".img"` -ge '1' ]] && [[ `ls ${Firmware_Path} | grep -c ".img.gz"` == '0' ]]; then
		gzip *.img
	fi
	
	case "${TARGET_BOARD}" in
	x86)
		if [[ ${PVE_LXC} == "true" ]]; then
			if [[ `ls ${Firmware_Path} | grep -c "rootfs"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*rootfs* ${Zhuan_Yi} && mv -f ${Zhuan_Yi}/*rootfs* ${Firmware_Path}/${ROOTFS_Firmware}
				echo "move ${Firmware_Path}/*rootfs* to ${Zhuan_Yi}" && echo "move ${Zhuan_Yi}/*rootfs* to ${Firmware_Path}/${ROOTFS_Firmware}"
			fi			
		else
			if [[ `ls ${Firmware_Path} | grep -c "ext4"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*ext4* ${Diuqu_gj}
			fi
			if [[ `ls ${Firmware_Path} | grep -c "rootfs"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*rootfs* ${Diuqu_gj}
			fi
			if [[ `ls ${Firmware_Path} | grep -c "${Firmware_sfx}"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*${Firmware_sfx}* ${Zhuan_Yi}
				if [[ `ls ${Zhuan_Yi} | grep -c "efi"` -eq '1' ]]; then
					mv -f ${Zhuan_Yi}/*efi* ${Firmware_Path}/${UEFI_Firmware}
				fi
				if [[ `ls ${Zhuan_Yi} | grep -c "squashfs"` -eq '1' ]]; then
					mv -f ${Zhuan_Yi}/*squashfs* ${Firmware_Path}/${Legacy_Firmware}
				fi
			fi
		fi
	;;
	ramips | reltek | ath* | ipq* | bcm47xx | bmips | kirkwood | mediatek)
		echo "${TARGET_BOARD},${Rename},${TARGET_PROFILE}" > ${Home}/4444
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Zhuan_Yi}/*sysupgrade.bin ${Firmware_Path}/${Up_Firmware}
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Zhuan_Yi}/*sysupgrade.bin ${Firmware_Path}/${Up_Firmware}
		fi	
	;;
	rockchip | bcm27xx | mxs | sunxi | zynq)
		if [[ `ls ${Firmware_Path} | grep -c "ext4"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*ext4* ${Diuqu_gj}
		fi
		if [[ `ls ${Firmware_Path} | grep -c "rootfs"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*rootfs* ${Diuqu_gj}
		fi
		if [[ `ls ${Firmware_Path} | grep -c "${Firmware_sfx}"` -ge '1' ]]; then
			mv -f ${Firmware_Path}/*${Firmware_sfx}* ${Zhuan_Yi}
			if [[ `ls ${Zhuan_Yi} | grep -c "efi"` -eq '1' ]]; then
				mv -f ${Zhuan_Yi}/*efi* ${Firmware_Path}/${UEFI_Firmware}
			fi
			if [[ `ls ${Zhuan_Yi} | grep -c "squashfs"` -eq '1' ]]; then
				mv -f ${Zhuan_Yi}/*squashfs* ${Firmware_Path}/${Legacy_Firmware}
			fi
		fi
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			if [[ `ls ${Firmware_Path} | grep -c "ext4"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*ext4* ${Diuqu_gj}
			fi
			if [[ `ls ${Firmware_Path} | grep -c "rootfs"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*rootfs* ${Diuqu_gj}
			fi
			if [[ `ls ${Firmware_Path} | grep -c "${Firmware_sfx}"` -ge '1' ]]; then
				mv -f ${Firmware_Path}/*${Firmware_sfx}* ${Zhuan_Yi}
				if [[ `ls ${Zhuan_Yi} | grep -c "efi"` -eq '1' ]]; then
					mv -f ${Zhuan_Yi}/*efi* "${Firmware_Path}/${UEFI_Firmware}"
				fi
				if [[ `ls ${Zhuan_Yi} | grep -c "squashfs"` -eq '1' ]]; then
					mv -f ${Zhuan_Yi}/*squashfs* ${Firmware_Path}/${Legacy_Firmware}
				fi
			fi
		;;
		esac
	;;
	bcm53xx)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c ".trx"` == '1' ]] && mv -f ${Zhuan_Yi}/*.trx ${Firmware_Path}/${Up_Firmware}
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c ".trx"` == '1' ]] && mv -f ${Zhuan_Yi}/*.trx ${Firmware_Path}/${Up_Firmware}
		fi
	;;
	octeon | oxnas | pistachio)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c ".tar"` == '1' ]] && mv -f ${Zhuan_Yi}/*.tar ${Firmware_Path}/${Up_Firmware}
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c ".tar"` == '1' ]] && mv -f ${Zhuan_Yi}/*.tar ${Firmware_Path}/${Up_Firmware}
		fi
	;;
	*)
		if [[ -n ${Rename} ]]; then
			mv -f ${Firmware_Path}/*${Rename}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Zhuan_Yi}/*sysupgrade.bin ${Firmware_Path}/${Up_Firmware}
		else
			mv -f ${Firmware_Path}/*${TARGET_PROFILE}* ${Zhuan_Yi}
			rm -f ${Firmware_Path}/${Up_Firmware}
			[[ `ls ${Zhuan_Yi} | grep -c "sysupgrade.bin"` == '1' ]] && mv -f ${Zhuan_Yi}/*sysupgrade.bin ${Firmware_Path}/${Up_Firmware}
		fi
	;;
	esac
	# copy files from openwrt/upgrade/ to openwrt/bin/Firmware/
	cd ${Firmware_Path}
	case "${TARGET_BOARD}" in
	x86)
		if [[ ${PVE_LXC} == "true" ]]; then
			[[ -f ${ROOTFS_Firmware} ]] && {
				MD5=$(md5sum ${ROOTFS_Firmware} | cut -c1-3)
				SHA256=$(sha256sum ${ROOTFS_Firmware} | cut -c1-3)
				SHA5BIT="${MD5}${SHA256}"
				cp ${ROOTFS_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-rootfs-${SHA5BIT}.${Firmware_sfx}
				echo "copy ${ROOTFS_Firmware} to ${Home}/bin/Firmware/${AutoBuild_Firmware}-rootfs-${SHA5BIT}.${Firmware_sfx}"
			}		
		else
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
		fi
	;;
	rockchip | bcm27xx | mxs | sunxi | zynq)
		[[ -f ${Legacy_Firmware} ]] && {
			MD5=$(md5sum ${Legacy_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${Legacy_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${Legacy_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy-${SHA5BIT}.${Firmware_sfx}
		}
		[[ -f ${UEFI_Firmware} ]] && {
			MD5=$(md5sum ${UEFI_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${UEFI_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${UEFI_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI-${SHA5BIT}.${Firmware_sfx}
		}
	;;
	mvebu)
		case "${TARGET_SUBTARGET}" in
		cortexa53 | cortexa72)
			[[ -f ${Legacy_Firmware} ]] && {
				MD5=$(md5sum ${Legacy_Firmware} | cut -c1-3)
				SHA256=$(sha256sum ${Legacy_Firmware} | cut -c1-3)
				SHA5BIT="${MD5}${SHA256}"
				cp ${Legacy_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy-${SHA5BIT}.${Firmware_sfx}
			}
			[[ -f ${UEFI_Firmware} ]] && {
				MD5=$(md5sum ${UEFI_Firmware} | cut -c1-3)
				SHA256=$(sha256sum ${UEFI_Firmware} | cut -c1-3)
				SHA5BIT="${MD5}${SHA256}"
				cp ${UEFI_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI-${SHA5BIT}.${Firmware_sfx}
			}
		;;
		esac
	;;
	*)
		[[ -f ${Up_Firmware} ]] && {
			MD5=$(md5sum ${Up_Firmware} | cut -c1-3)
			SHA256=$(sha256sum ${Up_Firmware} | cut -c1-3)
			SHA5BIT="${MD5}${SHA256}"
			cp ${Up_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Sysupg-${SHA5BIT}.${Firmware_sfx}
		} || {
			echo "Firmware is not detected !"
		}
	;;
	esac
	cd ${Home}
	rm -rf ${Firmware_Path} 2>/dev/null
	rm -rf ${Zhuan_Yi} 2>/dev/null
	rm -rf "${Diuqu_gj}" 2>/dev/null
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
