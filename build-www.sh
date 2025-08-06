#!/bin/bash
# Cloudflare Pages will fail if the repository has submodules it can't access. Therefore
# we need this wrapper to construct the appropriate directory structure so the same files
# can be used in all environments (WWW, DMZ, and LAN) with my desired dir structure.
#
# This would be a lot more straightforward without the need for this, but for now its easier to
# just symbolically link the 'st' sources to the site 'content' directory if they're
# present and then build the site.
#

link_content() {
	if [[ -z "$1" ]]; then
		echo "Missing target (\$1)!"
		return 1
	fi
	
	local SRC_T="$PWD/src/$1"
	local DST_T="$PWD/src/www/content/$1"

	if [[ ! -d "$T" ]]; then
		echo "Skipping: $T"
		return 0
	else
		echo "Linking: $T"

		if [[ -d "$1" ]]; then
			unlink "$DST_T" > /dev/null 2>&1
			rm -rf "$DST_T" > /dev/null 2>&1
		fi

		ln -s "$SRC_T" "$DST_T"
		if (( $? )); then
			echo "link: fail"
		fi

		echo "link: ok"
		return 0
	fi
}

main() {
	if [[ ! "$(basename "$PWD")" == "domain" ]]; then
		echo "Please run the script from the 'domain' repository root!"
	else
		local P_WWW="$PWD/src/www"

		if [[ ! -d "$P_WWW" ]]; then
			echo "Directory not present: $P_WWW, quitting!"
		else
			# Content submodules
			link_content "st-restricted"
			link_content "st-private"

			# Hugo build command
			hugo --source "$P_WWW" --destination "$P_WWW/public"
		fi
	fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main
fi
