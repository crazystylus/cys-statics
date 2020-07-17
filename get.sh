#!/bin/sh

main() {
	need_cmd curl
	need_cmd wget
	need_cmd uname
	need_cmd tar
	need_cmd gzip
	need_cmd bzip2
	need_cmd xz

	rm -rf ~/.cys
	mkdir -p ~/.cys
	pushd ~/.cys

	info "Downloading Tar files"
	wget https://github.com/crazystylus/cys-statics/releases/download/v0.1-alpha/cys-zgen.tar.xz
	unxz cys-zgen.tar.xz
	wget https://github.com/crazystylus/cys-statics/releases/download/v0.1-alpha/cys.tar.xz
	unxz cys.tar.xz

	info "Creating Demo Config file"
cat <<EOF >>PackageConfig.toml
ThemeFiles = [ "${HOME}/.cys/cys-zgen.tar"  ]
CompressionFactor = 9
ZipTypes = [ "gzip", "bzip2", "xz" ]
EOF

	info "Getting Binaries"
	_ostype="$(uname -s)"
	_cputype="$(uname -m)"
	_binname="null"

	case $_cputype in
	x86_64 | x86-64 | amd64)
		_cputype="x86_64"
		;;
	*)
		error "No binaries are available for your CPU architecture ($_cputype)"
		;;
	esac

	case $_ostype in
	Linux)
		_binname="cys-linux.xz"
		;;
	Darwin)
		_binname="cys-osx.xz"
		;;
	*)
		error "No binaries are available for your operating system ($_ostype)"
		;;
	esac
	wget -O "cys.xz" "https://github.com/crazystylus/cys-statics/releases/download/v0.1-alpha/${_binname}"
	unxz "cys.xz"
	chmod +x cys
	popd
	info "You may copy ~/.cys/cys binary to /usr/bin/cys or /usr/local/bin/cys"
	info "Examples
	To create an patched theme run
	~/.cys/cys package -pv --theme-name patched

	To create an un-patched default theme run
	~/.cys/cys package -v

	To SSH to an host with a theme run
	~/.cys/cys ssh -c \".tar.xz\" --theme-name patched admin@ubuntu

	**NOTE** compression format needs to be supported on remote system
	"
}
success() {
	printf "\033[32m%s\033[0m\n" "$1" >&1
}

info() {
	printf "%s\n" "$1" >&1
}

warning() {
	printf "\033[33m%s\033[0m\n" "$1" >&2
}

error() {
	printf "\033[31;1m%s\033[0m\n" "$1" >&2
	exit 1
}

cmd_chk() {
	command -v "$1" >/dev/null 2>&1
}

## Ensures that the command executes without error
ensure() {
	if ! "$@"; then error "command failed: $*"; fi
}

need_cmd() {
	if ! cmd_chk "$1"; then
		error "need $1 (command not found)"
	fi
}
main "$@" || exit 1
