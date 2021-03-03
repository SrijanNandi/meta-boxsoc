SUMMARY = "Elasticsearch"
DESCRIPTION = "Elasticsearch"
HOMEPAGE = "https://www.elastic.co"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=d25a1b054a0b0fbeb3def5a0ff50d01e"

REQUIRED_DISTRO_FEATURES = "systemd"
DEPENDS = "openjdk-8"
RDEPENDS_${PN} += "bash"

SRC_URI = "https://artifacts.elastic.co/downloads/${BPN}/${BPN}-${PV}-linux-x86_64.tar.gz \
           file://elasticsearch \
           file://elasticsearch.yml \
           file://jvm.options \
           file://log4j2.properties \
           file://role_mapping.yml \
           file://roles.yml \
           file://users \
           file://users_roles \
           file://elasticsearch.service \
           "

SRC_URI[md5sum] = "e7b6fc9ab48e7de333f1916806924488"
SRC_URI[sha256sum] = "ee38a952219b5247e0670532d6de31707d42a4b58aca49b28bddf37aab53c2e4"

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
SYSTEMD_SERVICE_${PN} = "elasticsearch.service"

do_compile() {
}

do_install() {
        install -d ${D}${datadir} ${D}${datadir}/${PN}
        install -d ${D}${sysconfdir} ${D}${sysconfdir}/${PN}
        install -d ${D}${localstatedir} ${D}${localstatedir}/lib ${D}${localstatedir}/lib/${PN} ${D}${localstatedir}/lib/${PN}/tmp
        install -d ${D}${localstatedir} ${D}${localstatedir}/log ${D}${localstatedir}/log/${PN}
        install -d ${D}${sysconfdir}/default
        chown -R elasticsearch:elasticsearch ${D}${localstatedir}/lib/${PN}
        chown -R elasticsearch:elasticsearch ${D}${localstatedir}/log/${PN}
        rm -rf ${S}/modules/x-pack-ml
        cp -r ${S}/* ${D}${datadir}/${PN}
        chown -R elasticsearch:elasticsearch ${D}${datadir}/${PN}
        install -c -m 0644 ${WORKDIR}/elasticsearch ${D}${sysconfdir}/default
        chown elasticsearch:elasticsearch ${D}${sysconfdir}/default/${PN}
        install -m 0644 ${WORKDIR}/elasticsearch.yml ${D}${sysconfdir}/elasticsearch
        install -m 0644 ${WORKDIR}/jvm.options ${D}${sysconfdir}/elasticsearch
        install -m 0644 ${WORKDIR}/log4j2.properties ${D}${sysconfdir}/elasticsearch
        install -m 0644 ${WORKDIR}/role_mapping.yml ${D}${sysconfdir}/elasticsearch
        install -m 0644 ${WORKDIR}/roles.yml ${D}${sysconfdir}/elasticsearch
        install -m 0644 ${WORKDIR}/users ${D}${sysconfdir}/elasticsearch
        install -m 0644 ${WORKDIR}/users_roles ${D}${sysconfdir}/elasticsearch
        chown -R elasticsearch:elasticsearch ${D}${sysconfdir}/${PN}

        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
            install -d ${D}${systemd_system_unitdir}
            install -c -m 0644 ${WORKDIR}/elasticsearch.service ${D}${systemd_system_unitdir}
        fi
}


FILES_${PN} += "${systemd_system_unitdir}"
FILES_${PN} += "${datadir}"
FILES_${PN} += "${localstatedir}"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} += "already-stripped ldflags host-user-contaminated libdir"
