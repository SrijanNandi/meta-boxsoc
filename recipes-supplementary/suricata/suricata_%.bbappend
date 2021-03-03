require version.inc
PR = "${INC_PR}.1"

SYSTEMD_SERVICE_${PN} = "suricata.service"
SYSTEMD_AUTO_ENABLE_${PN} = "disable"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://suricata.service \
            file://suricata.yaml \
            file://update.yaml \
            file://modify.conf \
            file://enable.conf \
            file://drop.conf \
            file://disable.conf \
           "

do_install_append() {
    install -d ${D}${sysconfdir} ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/suricata.yaml ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/update.yaml ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/modify.conf ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/enable.conf ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/drop.conf ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/disable.conf ${D}${sysconfdir}/${PN}

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -c -m 0644 ${WORKDIR}/suricata.service ${D}${systemd_system_unitdir}
    fi
}
