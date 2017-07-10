# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit bash-completion-r1 eutils

DESCRIPTION="A fast unix command line interface to WWW"
HOMEPAGE="http://surfraw.alioth.debian.org/"
SRC_URI="http://${PN}.alioth.debian.org/dist/${P}.tar.gz"

SLOT="0"
LICENSE="public-domain"
KEYWORDS="amd64 hppa ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
RESTRICT="test"
RDEPEND="dev-lang/perl"

DOCS=(AUTHORS ChangeLog HACKING NEWS README TODO)

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-2.2.6-gentoo_pkg_tools.patch \
		"${FILESDIR}"/${PN}-2.2.9-completion.patch
}

src_configure() {
	econf --with-elvidir='$(datadir)'/surfraw
}

src_install() {
	default

	newbashcomp surfraw-bash-completion ${PN}
	bashcomp_alias ${PN} sr

	docinto examples
	dodoc examples/README
	insinto /usr/share/doc/${PF}/examples
	doins examples/uzbl_load_url_from_surfraw
}

pkg_preinst() {
	has_version "=${CATEGORY}/${PN}-1.0.7"
	upgrade_from_1_0_7=$?
}

pkg_postinst() {
	local moves f

	einfo
	einfo "You can get a list of installed elvi by just typing 'surfraw' or"
	einfo "the abbreviated 'sr'."
	einfo
	einfo "You can try some searches, for example:"
	einfo "$ sr ask why is jeeves gay? "
	einfo "$ sr google -results=100 RMS, GNU, which is sinner, which is sin?"
	einfo "$ sr rhyme -method=perfect Julian"
	einfo
	einfo "The system configuration file is /etc/surfraw.conf"
	einfo
	einfo "Users can specify preferences in '~/.surfraw.conf'  e.g."
	einfo "SURFRAW_graphical_browser=mozilla"
	einfo "SURFRAW_text_browser=w3m"
	einfo "SURFRAW_graphical=no"
	einfo
	einfo "surfraw works with any graphical and/or text WWW browser"
	einfo
	if [[ $upgrade_from_1_0_7 = 0 ]] ; then
		ewarn "surfraw usage has changed slightly since version 1.0.7, elvi are now called"
		ewarn "using the 'sr' wrapper script as described above.  If you wish to return to"
		ewarn "the old behaviour you can add /usr/share/surfraw to your \$PATH"
	fi
	# This file was always autogenerated, and is no longer needed.
	if [ -f "${EROOT}"/etc/surfraw_elvi.list ]; then
		rm -f "${EROOT}"/etc/surfraw_elvi.list
	fi

	# Config file location changes in v2.2.6
	for f in /etc/surfraw.{bookmarks,conf}; do
		if [ -f "${EROOT}"${f} ]; then
			ewarn "${f} has moved to /etc/xdg/config/surfraw/${f##*.} in v2.2.6."
			moves=1
		fi
	done
	if [ "${moves}" == 1 ]; then
		ewarn "You must manually move, and update, the config files listed"
		ewarn "above for surfraw v2.2.6 and above to use them."
	fi
}
