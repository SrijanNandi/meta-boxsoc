FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://motd \
            file://profile \
           "

do_install_append () {
    install -d ${D}${sysconfdir}
    install -c -m 0644 ${WORKDIR}/motd ${D}${sysconfdir}/motd
    install -c -m 0644 ${WORKDIR}/profile ${D}${sysconfdir}/profile
}
