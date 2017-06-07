#original 4.8
export PATH=~/android/j700p/J700PVPS1AQD1/kernelbuild/arm-eabi-4.8/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=~/android/j700p/J700PVPS1AQD1/kernelbuild/arm-eabi-4.8/bin/arm-eabi-

BUILD_KERNEL_DIR=$(pwd)
BUILD_KERNEL_OUT=$(pwd)/out

#use ccache
#export USE_CCACHE=1
#export CCACHE_DIR=~/.ccache
#/usr/bin/ccache -M 50G

#UberTC 4.9
#export PATH=~/android/toolchains/arm-eabi-4.9/bin:$PATH
#export ARCH=arm
#export CROSS_COMPILE=~/android/toolchains/arm-eabi-4.9/bin/arm-eabi-

KERNEL_ZIMG=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/zImage
DTC=$BUILD_KERNEL_DIR/scripts/dtc/dtc
INSTALLED_DTIMAGE_TARGET=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/dt.img
DTBTOOL=$BUILD_KERNEL_DIR/tools/dtbTool
BOARD_KERNEL_PAGESIZE=2048

FUNC_BUILD_DTIMAGE_TARGET()
{
	echo ""
	echo "================================="
	echo "START : FUNC_BUILD_DTIMAGE_TARGET"
	echo "================================="
	echo ""
	echo "DT image target : $INSTALLED_DTIMAGE_TARGET"
	
	#if ! [ -e $DTBTOOL ] ; then
	#	if ! [ -d $BUILD_ROOT_DIR/android/out/host/linux-x86/bin ] ; then
	#		mkdir -p $BUILD_ROOT_DIR/android/out/host/linux-x86/bin
	#	fi
	#	cp $BUILD_ROOT_DIR/kernel/tools/dtbTool $DTBTOOL
	#fi

	echo "$DTBTOOL -o $INSTALLED_DTIMAGE_TARGET -s $BOARD_KERNEL_PAGESIZE \
		-p $BUILD_KERNEL_OUT/scripts/dtc/ $BUILD_KERNEL_OUT/arch/arm/boot/dts/"
		$DTBTOOL -o $INSTALLED_DTIMAGE_TARGET -s $BOARD_KERNEL_PAGESIZE \
		-p $BUILD_KERNEL_OUT/scripts/dtc/ $BUILD_KERNEL_OUT/arch/arm/boot/dts/

	chmod a+r $INSTALLED_DTIMAGE_TARGET

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_DTIMAGE_TARGET"
	echo "================================="
	echo ""
}

FUNC_BUILD_KERNEL()
(
#Compile the kernel and dtimage
echo "Build kernel"
mkdir $(pwd)/out
make -C $(pwd) O=$(pwd)/out msm8929_sec_defconfig VARIANT_DEFCONFIG=msm8929_sec_j7_spr_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -C $(pwd) O=$(pwd)/out -j2 -o2
cp $(pwd)/out/arch/arm/boot/zImage $(pwd)/arch/arm/boot/zImage

tools/dtbTool -o out/arch/arm/boot/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/
#FUNC_BUILD_DTIMAGE_TARGET
echo "kernel and dtimage compilation completed successfully"
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