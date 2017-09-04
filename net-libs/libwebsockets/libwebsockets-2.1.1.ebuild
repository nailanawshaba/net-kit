# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="canonical libwebsockets.org websocket library"
HOMEPAGE="https://libwebsockets.org/"
SRC_URI="https://github.com/warmcat/libwebsockets/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/${PV}"
KEYWORDS="amd64 arm x86"
IUSE="+http2 +ssl access-log cgi client generic-sessions http-proxy ipv6 lejp libev libressl libuv server-status smtp sqlite3 static-libs"

REQUIRED_USE="
	libressl? ( ssl )
	http-proxy? ( client )
	generic-sessions? ( sqlite3 )
	generic-sessions? ( smtp )
	smtp? ( libuv )
"

RDEPEND="
	sys-libs/zlib
	http-proxy? ( net-libs/libhubbub )
	libev?      ( dev-libs/libev )
	libuv?      ( dev-libs/libuv )
	sqlite3?    ( dev-db/sqlite )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl?  ( dev-libs/libressl:0= )
		)
"
DEPEND="${RDEPEND}
	dev-lang/perl
"
src_prepare() {
	epatch "${FILESDIR}/${P}-x86-build.patch"
	default
}

src_configure() {
	local mycmakeargs=(
		-DLWS_IPV6=$(usex ipv6 ON OFF)
		-DLWS_LINK_TESTAPPS_DYNAMIC=$(usex !static-libs ON OFF)
		-DLWS_WITH_HTTP2=$(usex http2 ON OFF)
		-DLWS_WITH_STATIC=$(usex static-libs ON OFF)
		-DLWS_WITH_LIBEV=$(usex libev ON OFF)
		-DLWS_WITH_LIBUV=$(usex libuv ON OFF)
		-DLWS_WITH_SSL=$(usex ssl ON OFF)
		-DLWS_WITHOUT_CLIENT=$(usex !client ON OFF)
		-DLWS_WITHOUT_TEST_CLIENT=$(usex !client ON OFF)
		-DLWS_WITH_CGI=$(usex cgi ON OFF)
		-DLWS_WITH_HTTP_PROXY=$(usex http-proxy ON OFF)
		-DLWS_WITH_ACCESS_LOG=$(usex access-log ON OFF)
		-DLWS_WITH_SERVER_STATUS=$(usex server-status ON OFF)
		-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
		-DLWS_WITH_LEJP=$(usex lejp ON OFF)
		-DLWS_WITH_GENERIC_SESSIONS=$(usex generic-sessions ON OFF)
		-DLWS_WITH_SQLITE3=$(usex sqlite3 ON OFF)
		-DLWS_WITH_SMTP=$(usex smtp ON OFF)
	)

	cmake-utils_src_configure
}
