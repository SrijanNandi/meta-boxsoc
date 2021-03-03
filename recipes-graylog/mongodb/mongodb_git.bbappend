FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://mongod \
            file://mongod.service \
            file://mongod.conf \
           "

inherit systemd useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "${PN}"
USERADD_PARAM_${PN} = " \
    --system --no-create-home \
    --shell /bin/false \
    -g ${PN} \
    ${PN}"

SYSTEMD_SERVICE_${PN} = "mongod.service"
SYSTEMD_AUTO_ENABLE = "enable"
INSANE_SKIP_${PN} += "already-stripped ldflags installed-vs-shipped host-user-contaminated"

do_install_append() {
        install -d ${D}${sysconfdir}
        install -d ${D}${localstatedir} ${D}${localstatedir}/log ${D}${localstatedir}/log/mongodb
        chown -R mongodb:mongodb ${D}${localstatedir}/log/mongodb
        install -d ${D}${sysconfdir}/sysconfig
        install -c -m 0644 ${WORKDIR}/mongod.conf ${D}${sysconfdir}
        chown mongodb:mongodb ${D}${sysconfdir}/mongod.conf
        install -c -m 0644 ${WORKDIR}/mongod ${D}${sysconfdir}/sysconfig
        chown mongodb:mongodb ${D}${sysconfdir}/sysconfig/mongod
        install -d ${D}${localstatedir} ${D}${localstatedir}/lib ${D}${localstatedir}/lib/mongodb
        chown -R mongodb:mongodb ${D}${localstatedir}/lib/mongodb
        
        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
            install -d ${D}${systemd_system_unitdir}
            install -c -m 0644 ${WORKDIR}/mongod.service ${D}${systemd_system_unitdir}
        fi
}
