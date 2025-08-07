#!/bin/bash
# Cloudflare Pages will fail if the repository has submodules it can't access. Therefore
# we need this wrapper to construct the appropriate directory structure so the same files
# can be used in all environments (WWW, DMZ, and LAN) with my desired dir structure.
#
# This would be a lot more straightforward without the need for this, but for now its easier to
# just symbolically link the 'st' sources to the site 'content' directory if they're
# present and then build the site.
#
# * Give "dev" as $1, to run hugo in server mode

link_content() {
	if [[ -z "$1" ]]; then
		echo "Missing target (\$1)!"
		return 1
	fi
	
	local SRC="$1"
	local DST="$2"
	local REL=$(realpath --relative-to="$DST" "$SRC")

	if [[ ! -d "$SRC" ]]; then
		echo "* SKIP: $SRC"
		return 2
	else
		ln -s -f "$SRC" "$DST"
		if (( $? )); then
			echo "* $SRC !! $DST"
			return 1
		else
			echo "* $SRC -> $DST"
			return 0
		fi
	fi
}

main() {
	if [[ ! "$(basename "$PWD")" == "domain" ]]; then
		echo "Please run the script from the 'domain' repository root!"
	else
		local P_WWW="$PWD/src/www"

		# Dev
		if [[ "$1" == "dev" ]]; then
			local H_OPT="server --disableFastRender"
		fi

		if [[ ! -d "$P_WWW" ]]; then
			echo "Directory not present: $P_WWW, quitting!"
		else
			# Content submodules
			echo "> linking available content"
			link_content "$PWD/src/st-restricted" "$PWD/src/www/content"
			link_content "$PWD/src/st-private" "$PWD/src/www/content"

			# Hugo build command
			hugo $H_OPT --source "$P_WWW" --destination "$P_WWW/public"
		fi
	fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$1"
fi
