#Samsung Included 4.8 toolchain
#export PATH=~/android/j700p/J700PVPS1AQD1/kernelbuild/arm-eabi-4.8/bin:$PATH
#export ARCH=arm
#export CROSS_COMPILE=~/android/j700p/J700PVPS1AQD1/kernelbuild/arm-eabi-4.8/bin/arm-eabi-

BUILD_KERNEL_DIR=$(pwd)
BUILD_KERNEL_OUT=$(pwd)/out

#use ccache
#export USE_CCACHE=1
#export CCACHE_DIR=~/.ccache
#/usr/bin/ccache -M 50G

#UberTC 5.3
export PATH=~/android/toolchains/arm-eabi-5.3/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=~/android/toolchains/arm-eabi-5.3/bin/arm-eabi-

#UberTC 4.9
#export PATH=~/android/toolchains/arm-eabi-4.9/bin:$PATH
#export ARCH=arm
#export CROSS_COMPILE=~/android/toolchains/arm-eabi-4.9/bin/arm-eabi-

#KERNEL_ZIMG=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/zImage
#DTC=$BUILD_KERNEL_DIR/out/scripts/dtc/dtc
#INSTALLED_DTIMAGE_TARGET=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/dt.img
#DTBTOOL=$BUILD_KERNEL_DIR/tools/dtbTool
#BOARD_KERNEL_PAGESIZE=2048

FUNC_BUILD_KERNEL()
(
#clean up
#make -C $(pwd) O=$(pwd)/out clean
#make -C $(pwd) O=$(pwd)/out mrproper
#make -C $(pwd) O=$(pwd)/out distclean

#Compile the kernel and dtimage
echo "Build kernel"
mkdir $(pwd)/out
make -C $(pwd) O=$(pwd)/out msm8929_sec_defconfig VARIANT_DEFCONFIG=msm8929_sec_j7_spr_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -C $(pwd) O=$(pwd)/out -j2
cp $(pwd)/out/arch/arm/boot/zImage $(pwd)/arch/arm/boot/zImage

echo "Create dt.img"
tools/dtbTool -o out/arch/arm/boot/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/

echo "kernel and dtimage compilation completed successfully"
echo "......."
echo "make modules_install"
make -C $(pwd) O=$(pwd)/out -j2 modules_install INSTALL_MOD_PATH=sohren_install INSTALL_MOD_STRIP=1
)

# MAIN FUNCTION
cp ./build.log ./build.log-bak
(
	START_TIME=`date +%s`

	FUNC_BUILD_KERNEL
	#FUNC_RAMDISK_EXTRACT_N_COPY
	#FUNC_MKBOOTIMG

	END_TIME=`date +%s`

	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log