# Finalize sudo accesses for Authorized users
#

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://001_first"

do_install_append () {
    install -d -m 0710 ${D}${sysconfdir}/sudoers.d
    install -m 0644 ${WORKDIR}/001_first ${D}${sysconfdir}/sudoers.d
}
