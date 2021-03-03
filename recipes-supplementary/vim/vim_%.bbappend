FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://vimrc \
            file://vimrc.local"

do_install_append() {
    install -d ${D}{sysconfdir} ${D}${sysconfdir}/${PN}
    install -d ${D}${datadir} ${D}${datadir}/${PN}
    install -c -m 0644 ${WORKDIR}/vimrc.local ${D}${sysconfdir}/${PN}
    install -c -m 0644 ${WORKDIR}/vimrc ${D}${datadir}/${PN}
} 
