FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://mosquitto.conf"

do_install_append() {
    install -d ${D}${sysconfdir} ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/mosquitto.conf ${D}${sysconfdir}/${PN}
}

SYSTEMD_AUTO_ENABLE_${PN} = "disable"
