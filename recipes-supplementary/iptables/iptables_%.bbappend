SYSTEMD_AUTO_ENABLE = "enable"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://iptables.rules \
            file://iptables.service \
            file://flush-iptables.sh \
           "

do_install_append () {
    install -d ${D}${sysconfdir} ${D}${sysconfdir}/${PN}
    install -d ${D}${sbindir}
    install -c -m 0644 ${WORKDIR}/iptables.rules ${D}${sysconfdir}/${PN}
    install -m 0755 ${WORKDIR}/flush-iptables.sh ${D}${sbindir}
    
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -c -m 0644 ${WORKDIR}/iptables.service ${D}${systemd_system_unitdir}
    fi
}
