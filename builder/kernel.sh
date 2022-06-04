#!/usr/bin/bash
# Written by: cyberknight777
# YAKB v1.0
# Copyright (c) 2022-2023 Cyber Knight <cyberknight755@gmail.com>
#
#			GNU GENERAL PUBLIC LICENSE
#			 Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

# Some Placeholders: [!] [*] [✓] [✗]

# A function to send message(s) via Telegram's BOT api.
tg() {
    curl -sX POST https://api.telegram.org/bot"${TG_TOKEN}"/sendMessage \
        -d chat_id="-1001754559150" \
        -d parse_mode=html \
        -d disable_web_page_preview=true \
        -d text="$1"
}

tgs() {
    SHA1=$(sha1sum "$1" | cut -d' ' -f1)
    curl -fsSL -X POST -F document=@"$1" https://api.telegram.org/bot"${TG_TOKEN}"/sendDocument \
        -F "chat_id=-1001754559150" \
        -F "parse_mode=Markdown" \
        -F "caption=$2 | *SHA1*: \`$SHA1\`"
}

# Default defconfig to use for builds.
CONFIG="sweet_defconfig"

# Default directory where kernel is located in.
KDIR=$(pwd)

# Device and codename.
DEVICE="Redmi Note 10 Pro"
CODENAME="sweet"
# User and Host name
export KBUILD_BUILD_USER=KuroSeinen
export KBUILD_BUILD_HOST=XZI-TEAM

# Number of jobs to run.
PROCS=$(nproc --all)

Ai1() {

    git clone --depth=1 https://gitlab.com/ElectroPerf/atom-x-clang -b atom-15 "${KDIR}"/clang
    git clone --depth=1 http://github.com/kenhv/gcc-arm64 -b master "${KDIR}"/gcc32
    git clone --depth=1 http://github.com/kenhv/gcc-arm64 -b master "${KDIR}"/gcc64


    LLD_VER=$("${KDIR}"/clang/ld.lld -v | head -n1 | sed 's/(compatible with [^)]*)//' |
            head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
    KBUILD_COMPILER_STRING=$("${KDIR}"/clang/bin/clang --version | head -n 1)
    export KBUILD_COMPILER_STRING
    export PATH="${KDIR}"/clang/bin:"${KDIR}"/gcc32/bin:"${KDIR}"/gcc64/bin:${PATH}
    MAKE+=(
        ARCH=arm64
        O=out
        CC=clang
        NM=llvm-nm
        CXX=clang++
        AR=llvm-ar
        LD=ld.lld
        STRIP=llvm-strip
        OBJCOPY=llvm-objcopy
        OBJDUMP=llvm-objdump
        OBJSIZE=llvm-size
        READELF=llvm-readelf
        CROSS_COMPILE=aarch64-linux-elf-
        CROSS_COMPILE_ARM32=arm-linux-eabi-
        CLANG_TRIPLE=aarch64-linux-gnu-
        HOSTAR=llvm-ar
        HOSTLD=ld.lld
        HOSTCC=clang
        HOSTCXX=clang++
    )

    git clone --depth=1 https://github.com/KuroSeinenbutV2/AnyKernel3 "${KDIR}"/anykernel3

    export KBUILD_BUILD_VERSION=$GITHUB_RUN_NUMBER
    export KBUILD_BUILD_HOST=$HOST
    export KBUILD_BUILD_USER=$BUILDER
    zipn=QuantumKyaru-TEST-${CODENAME}

    echo -e "\n\e[1;93m[*] Regenerating defconfig! \e[0m"
    make "${MAKE[@]}" $CONFIG
    cp -rf "${KDIR}"/out/.config "${KDIR}"/arch/arm64/configs/$CONFIG
    echo -e "\n\e[1;32m[✓] Defconfig regenerated! \e[0m"


tg "
<b>Build Number</b>: <code>$GITHUB_RUN_NUMBER</code>
<b>Device</b>: <code>${DEVICE}</code>
<b>Kernel Version</b>: <code>$(make kernelversion 2>/dev/null)</code>
<b>Date</b>: <code>$(date)</code>
<b>Zip Name</b>: <code>${zipn}</code>
<b>Compiler</b>: <code>${KBUILD_COMPILER_STRING}</code>
<b>Linker</b>: <code>${LLD_VER}</code>
"


    echo -e "\n\e[1;93m[*] Building Kernel! \e[0m"
    BUILD_START=$(date +"%s")
    time make -j"$PROCS" "${MAKE[@]}" Image.gz 2>&1 | tee log.txt
    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    if [ -f "${KDIR}/out/arch/arm64/boot/Image.gz" ]; then
            tg "<b>Kernel Built after $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)</b>"
        echo -e "\n\e[1;32m[✓] Kernel built after $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! \e[0m"
    else
            tgs "log.txt" "*Build failed*"
        echo -e "\n\e[1;31m[✗] Build Failed! \e[0m"
        exit 1
    fi

    echo -e "\n\e[1;93m[*] Building DTBS! \e[0m"
    time make -j"$PROCS" "${MAKE[@]}" dtbs dtbo.img
    echo -e "\n\e[1;32m[✓] Built DTBS! \e[0m"

        tg "<b>Building zip!</b>"
    echo -e "\n\e[1;93m[*] Building zip! \e[0m"
    mv "${KDIR}"/out/arch/arm64/boot/dtbo.img "${KDIR}"/anykernel3
    mv "${KDIR}"/out/arch/arm64/boot/Image.gz "${KDIR}"/anykernel3
    cd "${KDIR}"/anykernel3 || exit 1
    zip -r9 "$zipn".zip . -x ".git*" -x "README.md" -x "LICENSE" -x "*.zip"
    echo -e "\n\e[1;32m[✓] Built zip! \e[0m"
        tgs "${zipn}.zip"
}

Ai1
