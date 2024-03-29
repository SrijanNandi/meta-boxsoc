SUMMARY = "Initial boot script"
DESCRIPTION = "Script to do any first boot init, started as a systemd service which removes itself once finished"
LICENSE = "CLOSED"
PV = "1.0.0"
PR = "r4"

SRC_URI =  " \
    file://initscript.sh \
    file://initscript.service \
"

do_compile () {
}

do_install () {
    install -d ${D}/${sbindir}
    install -c -m 0755 ${WORKDIR}/initscript.sh ${D}/${sbindir}
    
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -c -m 0644 ${WORKDIR}/initscript.service ${D}${systemd_unitdir}/system
    fi
}

NATIVE_SYSTEMD_SUPPORT = "1"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE_${PN} = "initscript.service"

inherit allarch systemd
