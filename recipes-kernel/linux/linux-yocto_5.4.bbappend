KBRANCH_genericx86  = "v5.4/standard/base"
KBRANCH_genericx86-64  = "v5.4/standard/base"

KMACHINE_genericx86 ?= "common-pc"
KMACHINE_genericx86-64 ?= "common-pc-64"

SRCREV_machine_genericx86 ?= "706efec4c1e270ec5dda92275898cd465dfdc7dd"
SRCREV_machine_genericx86-64 ?= "706efec4c1e270ec5dda92275898cd465dfdc7dd"

COMPATIBLE_MACHINE_genericx86 = "genericx86"
COMPATIBLE_MACHINE_genericx86-64 = "genericx86-64"

LINUX_VERSION_genericx86 = "5.4.58"
LINUX_VERSION_genericx86-64 = "5.4.58"

LINUX_VERSION_EXTENSION = "-boxsoc-${LINUX_KERNEL_TYPE}"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://defconfig"
