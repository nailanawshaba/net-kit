# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils pam

DESCRIPTION="Provides Access to Netware services using the NCP protocol"
HOMEPAGE="ftp://platan.vc.cvut.cz/pub/linux/ncpfs/"
SRC_URI="ftp://platan.vc.cvut.cz/pub/linux/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~mips ppc ppc64 x86"
IUSE="nls pam php"

DEPEND="nls? ( sys-devel/gettext )
	pam? ( virtual/pam )
	php? ( || ( dev-lang/php virtual/httpd-php ) )"

RDEPEND="${DEPEND}"

src_prepare() {
	# Add patch for PHP extension sandbox violation
	epatch "${FILESDIR}"/${PN}-2.2.5-php.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${P}-missing-includes.patch

	# Add a patch to fix multiple vulnerabilities.
	# CVE-2010-0788, CVE-2010-0790, & CVE-2010-0791.
	# http://seclists.org/fulldisclosure/2010/Mar/122
	epatch "${FILESDIR}"/${P}-multiple-vulns.patch

	# Add a patch that removes the __attribute__((packed)); directive
	# from several struct members in include/ncp/ncplib.h.  This will
	# cut down on a large number of compile warnings generated by modern
	# gcc releases.
	epatch "${FILESDIR}"/${P}-remove-packed-attrib.patch

	# Misc patches borrowed from Mageia.
	epatch "${FILESDIR}"/${P}-align-fix.patch
	epatch "${FILESDIR}"/${P}-getuid-fix.patch
	epatch "${FILESDIR}"/${P}-pam_ncp_auth-fix.patch
	epatch "${FILESDIR}"/${P}-servername-array-fix.patch

	# Misc patches borrowed from Debian.
	# Fixes Bug #497278
	epatch "${FILESDIR}"/${P}-drop-kernel-check.patch
	epatch "${FILESDIR}"/${P}-drop-mtab-support.patch
	epatch "${FILESDIR}"/${P}-no-suid-root.patch
	epatch "${FILESDIR}"/${P}-remove-libncp_atomic-header.patch

	# Bug #273484.
	sed -i '/ldconfig/d' lib/Makefile.in

	# Support LDFLAGS.
	epatch "${FILESDIR}"/${P}-ldflags-support.patch

	# Bug 446696.  This might need re-diffing if additional Makefile
	# fixes are added.
	epatch "${FILESDIR}"/${P}-makefile-fix-soname-link.patch

	# bug 522444
	epatch "${FILESDIR}"/${P}-zend_function_entry.patch
}

src_configure() {
	econf \
		$(use_enable nls) \
		$(use_enable pam pam "$(getpam_mod_dir)") \
		$(use_enable php)
}

src_install() {
	dodir $(getpam_mod_dir) /usr/sbin /sbin

	# Bug #446696.
	#ln -s "${D}"/usr/lib64/libncp.so.2.3 "${D}"/libncp.so.2.3.0

	# Install the main programs, then the headers.
	emake DESTDIR="${D}" install || die
	emake DESTDIR="${D}" install-dev || die

	# Install a startup script in /etc/init.d and a conf file in /etc/conf.d
	newconfd "${FILESDIR}"/ipx.confd ipx
	newinitd "${FILESDIR}"/ipx.init ipx

	# Docs
	dodoc FAQ README
}
