# sys-auth/pam_rundir

# TODO: There exists no release for this project, and there is a pending
# trivially certain bug ( = instead of == ) so I plan to fork this, fix the
# bug, and pin a release for better package versioning.

EAPI=8

inherit git-r3

DESCRIPTION="Provide a user runtime directory per the XDG specification."
HOMEPAGE="https://github.com/jjk-jacky/pam_rundir"
LICENSE="GPL-2"

EGIT_REPO_URI="https://github.com/jjk-jacky/pam_rundir.git"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=sys-libs/pam-1.3.1"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

# Need to override this to set configure options (for now)
src_configure() {
	./configure \
		--securedir=/lib64/security \
		--with-parentdir=/run/user \
			|| die
}
