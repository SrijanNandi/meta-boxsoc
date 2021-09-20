SUMMARY = "Forwarder"
DESCRIPTION = "Log Forwarder"
HOMEPAGE = "https://www.graylog.org"
LICENSE = "CLOSED"

REQUIRED_DISTRO_FEATURES = "systemd"
DEPENDS = "openjdk-8"
RDEPENDS_${PN} += "bash"

SRC_URI = "https://downloads.graylog.org/releases/cloud/forwarder/${PV}/${BPN}-${PV}-bin.tar.gz \
           file://graylog-forwarder.jar \
           file://jvm.options \
           file://log4j2.xml \
           file://graylog-forwarder \
           file://forwarder.conf \
           file://graylog-forwarder.service \
           "

SRC_URI[md5sum] = "77795b025f07f9dc9654dfa8d7a238f9"
SRC_URI[sha256sum] = "d63f3558fc692e68712e563cad55414d6532c285b2d72a627ff74e9e05bfec5e"

S = "${WORKDIR}/${BPN}-${PV}"

inherit autotools systemd pkgconfig useradd features_check

USERADD_PACKAGES = "${PN}"
GROUPADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "${PN}"
USERADD_PARAM_${PN} = " \
    --system --no-create-home \
    --shell /bin/false \
    -g ${PN} \
    ${PN}"


SYSTEMD_PACKAGES += "${BPN}"
SYSTEMD_SERVICE_${PN} = "graylog-forwarder.service"

do_compile() {
}

do_install() {
        install -d ${D}${sysconfdir} ${D}${sysconfdir}/graylog ${D}${sysconfdir}/graylog/${PN}
        install -d ${D}${datadir} ${D}${datadir}/${PN} ${D}${datadir}/${PN}/bin ${D}${datadir}/${PN}/plugin
        install -d ${D}${localstatedir} ${D}${localstatedir}/lib ${D}${localstatedir}/lib/${PN} ${D}${localstatedir}/lib/${PN}/data
        install -d ${D}${localstatedir} ${D}${localstatedir}/log ${D}${localstatedir}/log/${PN}
        install -c -m 0644 ${WORKDIR}/forwarder.conf ${D}${sysconfdir}/graylog/${PN}
        install -c -m 0644 ${WORKDIR}/jvm.options ${D}${sysconfdir}/graylog/${PN}
        install -c -m 0644 ${WORKDIR}/log4j2.xml ${D}${sysconfdir}/graylog/${PN}
        install -c -m 0644 ${WORKDIR}/graylog-forwarder.jar ${D}${datadir}/${PN}
        install -c -m 0755 ${WORKDIR}/graylog-forwarder ${D}${datadir}/${PN}/bin
        chown -R graylog-forwarder:graylog-forwarder ${D}${sysconfdir}/graylog/${PN}
        chown -R graylog-forwarder:graylog-forwarder ${D}${localstatedir}/log/${PN}
        chown -R graylog-forwarder:graylog-forwarder ${D}${datadir}/${PN}

         if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
            install -d ${D}${systemd_system_unitdir}
            install -c -m 0644 ${WORKDIR}/graylog-forwarder.service ${D}${systemd_system_unitdir}
        fi

}


FILES_${PN} += "${systemd_system_unitdir}"
FILES_${PN} += "${datadir}"
FILES_${PN} += "${localstatedir}"
FILES_${PN} += "${libdir}/*"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} += "already-stripped ldflags host-user-contaminated libdir"
