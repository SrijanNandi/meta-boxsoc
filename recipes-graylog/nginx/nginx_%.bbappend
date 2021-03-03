SYSTEMD_AUTO_ENABLE_${PN} = "disable"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://boxsoc_server"

do_install_append () {
    install -d ${D}${sysconfdir} ${D}${sysconfdir}/${PN} ${D}${sysconfdir}/${PN}/sites-available
    install -m 0644 ${WORKDIR}/boxsoc_server ${D}${sysconfdir}/${PN}/sites-available
    install -d ${D}${sysconfdir} ${D}${sysconfdir}/${PN} ${D}${sysconfdir}/${PN}/sites-enabled
    ln -s ../sites-available/boxsoc_server ${D}${sysconfdir}/nginx/sites-enabled/
} 
