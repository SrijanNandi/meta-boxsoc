SUMMARY = "Miscellaneous files for BoxSoc initial subsystem"
DESCRIPTION = "The rc.initial files package creates the initial menu option for BoxSoc"
SECTION = "base"
LICENSE = "CLOSED"
PV = "1.0.0"
PR = "r.4"

SRC_URI = "file://rc.initial \
           file://rc.initial.toggle_ips \
           file://rc.initial.ping \
           file://rc.initial.showports \
           file://rc.initial.toggle_sshd \
           file://rc.initial.setinterfaceip \
           file://rc.initial.config \
           file://initial_run.sh \
          "

do_compile() {
}

do_install() {
    install -d ${D}${sysconfdir}
    install -c -m 0755 ${WORKDIR}/rc.initial ${D}${sysconfdir}/rc.initial
    install -c -m 0755 ${WORKDIR}/rc.initial.toggle_ips ${D}${sysconfdir}/rc.initial.toggle_ips
    install -c -m 0755 ${WORKDIR}/rc.initial.ping ${D}${sysconfdir}/rc.initial.ping
    install -c -m 0755 ${WORKDIR}/rc.initial.showports ${D}${sysconfdir}/rc.initial.showports
    install -c -m 0755 ${WORKDIR}/rc.initial.setinterfaceip ${D}${sysconfdir}/rc.initial.setinterfaceip
    install -c -m 0755 ${WORKDIR}/rc.initial.toggle_sshd ${D}${sysconfdir}/rc.initial.toggle_sshd
    install -c -m 0755 ${WORKDIR}/rc.initial.config ${D}${sysconfdir}/rc.initial.config
    install -d ${D}${sysconfdir}/profile.d
    install -c -m 0755 ${WORKDIR}/initial_run.sh ${D}${sysconfdir}/profile.d/initial_run.sh
}

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} += "already-stripped ldflags host-user-contaminated libdir arch"
