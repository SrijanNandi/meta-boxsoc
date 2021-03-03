SUMMARY = "A suite of security-related network utilities based on \
the SSH protocol including the ssh client and sshd server"
DESCRIPTION = "Secure rlogin/rsh/rcp/telnet replacement (OpenSSH) \
Ssh (Secure Shell) is a program for logging into a remote machine \
and for executing commands on a remote machine."

SYSTEMD_AUTO_ENABLE_${PN}-sshd = "disable"
SYSTEMD_AUTO_ENABLE_${PN}-sshdgenkeys = "enable"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://sshd \
            file://sshd.socket \
           "
do_install_append () {
        sed -i 's/#Port 22/Port 2224/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#SyslogFacility AUTH/SyslogFacility AUTH/' ${D}${sysconfdir}/ssh/sshd_config  
        sed -i 's/#LogLevel INFO/LogLevel INFO/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#LoginGraceTime 2m/LoginGraceTime 2m/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#StrictModes yes/StrictModes yes/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#MaxAuthTries 6/MaxAuthTries 4/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#MaxSessions 10/MaxSessions 5/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' ${D}${sysconfdir}/ssh/sshd_config
        sed -i 's/UsePAM yes/UsePAM no/' ${D}${sysconfdir}/ssh/sshd_config
        
        install -d ${D}${sysconfdir} ${D}${sysconfdir}/default
        install -m 0644 ${WORKDIR}/sshd ${D}${sysconfdir}/default
        
         if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
            install -d ${D}${systemd_system_unitdir}
            install -c -m 0644 ${WORKDIR}/sshd.socket  ${D}${systemd_system_unitdir}
            sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
                -e 's,@SBINDIR@,${sbindir},g' \
                -e 's,@BINDIR@,${bindir},g' \
                -e 's,@SYSCONFDIR@,${sysconfdir},g' \
                -e 's,@localstatedir@,${localstatedir},g' \
                -e 's,@LIBEXECDIR@,${libexecdir}/${BPN},g' \
                ${D}${systemd_system_unitdir}/sshd.socket
        fi

}

