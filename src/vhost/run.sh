#/bin/bash
# DEPLOY-VHOST, RUN.SH
# TBK

runp() {
# Run and print a given command
	echo "$@"
	"$@" || echo "[F]: $*"
}

source_env() {
# Source environment from '.env'
	echo "[LOADING ENV]"

	set -o allexport
	if ! source ./.env ; then
		echo "Failed sourcing env! Exiting..."
		exit 1
	fi
	set +o allexport
	echo -e "DONE\n\n"
}

configure_network() {
# Set system hostname, and configure interfaces
	echo "[CONFIGURING NETWORK]"

	hostname "$DP_HOSTNAME"
	envsubst < config/interfaces > /etc/network/interfaces
	echo -e "DONE\n\n"
}

bootstrap_time() {
# Bootstrap network time
	echo "[BOOTSTRAPPING TIME]"

	mkdir -p /etc/systemd/timesyncd.conf.d/
	envsubst < config/timesyncd.conf > /etc/systemd/timesyncd.conf.d/10-local
	systemctl restart systemd-timesyncd.service && systemctl disable systemd-timesyncd.service
	echo -e "DONE\n\n"
}

install_packages() {
# Update system and install packages
	echo "[UPDATING SYSTEM]"

	if ! (apt update && apt upgrade) ; then
		echo "Failed to APT update/upgrade! Exiting..."
		exit 1
	fi
	echo -e "DONE\n\n"

	echo "[INSTALLING PACKAGES]"
	DEBIAN_FRONTEND=noninteractive apt-get -yq install \
		vim git tar htop tree rsync net-tools curl iotop iperf3 fio jq chrony nftables nfs4-acl-tools \
		ca-certificates openssh-server nfs-common podman uidmap netavark aardvark-dns skopeo procps \
		slirp4netns docker.io docker-compose
	apt --yes autoremove
	echo -e "DONE\n\n"
}

configure_time() {
# Configure main network time
	echo "[SETTING NETWORKTIME]"

	systemctl enable --now chrony.service
	mkdir -p /etc/chrony/sources.d/
	echo "server $DP_NTP_SERVER iburst" > /etc/chrony/sources.d/10-local.sources
	chronyc reload sources
	echo -e "DONE\n\n"
}

configure_systemservices() {
# Configure system services
	echo "[CONFIGURING SYSTEMSERVICES]"

	systemctl enable --now ssh.service
	systemctl disable --now podman.service podman.socket
	systemctl disable --now docker.service docker.socket
	echo -e "DONE\n\n"
}

create_users() {
# Create system user(s)
	echo "[CREATING SYSTEM USERS]"

	groups $DP_USER1_NAME > /dev/null
	if (( $? != 0 )); then
		echo -e "CREATNG (G) - $DP_USER1_NAME:$DP_USER1_ID"
		groupadd -g "$DP_USER1_ID" "$DP_USER1_NAME"
	else
		set_groupid=$(getent group $DP_USER1_NAME | cut -d: -f3)
		echo -e "EXISTS (G) - $DP_USER1_NAME:$set_groupid"
	fi

	id $DP_USER1_NAME > /dev/null
	if (( $? != 0 )); then
		echo "CREATING (U) - $DP_USER1_NAME:$DP_USER1_ID"

		useradd -m -u "$DP_USER1_ID" -g "$DP_USER1_ID" -s /bin/bash \
			"$DP_USER1_NAME" && echo "$DP_USER1_NAME:$DP_USER1_PWD" | chpasswd
		chmod 700 "/home/$DP_USER1_NAME"
		loginctl enable-linger $DP_USER1_NAME

	else
		set_userid=$(getent passwd $DP_USER1_NAME | cut -d: -f3)
		echo -e "EXISTS (U) - $DP_USER1_NAME:$set_userid"
	fi

	echo "Setting subid mappings..."
	for file in /etc/subuid /etc/subgid; do
	# subid mappings
		mapping="${DP_USER1_NAME}:${DP_USER1_SUBID_START}:${DP_USER1_SUBID_END}"

		if grep -q "^${DP_USER1_NAME}:" "$file"; then
		# Update existing mapping
			sed -i "s|^${DP_USER1_NAME}:.*|$mapping|" "$file"
		else
		# Create new mapping
			echo "$mapping" >> "$file"
		fi
	done
	echo -e "DONE\n\n"
}

mount_iscsi() {
# Mount ISCSI datastore
	echo "[MOUNTING DATASTORE]"

	if [[ "$DP_DATASTORE_SET" == "1" ]]; then
		p="$DP_DATASTORE_PATH_INT"

		# root
		runp mkdir -p "$p"
		runp chown root:root "$p"
		runp chmod 755 "$p"

		# fstab
		grep -qxF "$DP_DATASTORE_FSTAB" /etc/fstab || echo "$DP_DATASTORE_FSTAB" >> /etc/fstab
		systemctl daemon-reload && mount "$p"
		echo -e "DONE\n\n"

		echo "[CREATING DATASTORE DIRS]"

		# subdirectories
		for u in root "$DP_USER1_NAME"; do
			pu="$p/$u"
			for d in "$pu/" "$pu/"{docker,podman} "$pu/"{docker,podman}/{rootful,rootless}; do
				runp mkdir "$d"
				runp chown "$u:$u" "$d"
				runp chmod 750 "$d"
			done
		done
		echo -e "DONE\n\n"
	else
		echo -e "Skipping... (flag unset)\n\n"
	fi
}

mount_nfs() {
# Mount NETWORK TARGET root
	echo "[MOUNTING NFS ROOT]"

	if [[ "$DP_NFS_SET" == "1" ]]; then
		runp umount "$DP_NFS_PATH_INT"

		# directory path
		runp mkdir -p "$DP_NFS_PATH_INT"
		runp chown root:root "$DP_NFS_PATH_INT"
		runp chmod 755 "$DP_NFS_PATH_INT"

		# fstab, mount
		grep -qxF "$DP_NFS_FSTAB" /etc/fstab || echo "$DP_NFS_FSTAB" >> /etc/fstab
		systemctl daemon-reload && mount $DP_NFS_PATH_INT
		echo -e "DONE\n\n"
	else
		echo -e "Skipping... (flag unset)\n\n"
	fi
}


# Run
if [[ $(whoami) != "root" ]]; then
	echo -e "Deployment script must run as root! Exiting...\n"
	exit 1
fi
if [[ ":$PATH:" != *":/sbin:"* ]]; then
	# add SBIN to path. needed if user didn't fully login as root...
	export PATH="$PATH:/sbin"
fi
exec 2> ./run_error.log

source_env
configure_network
bootstrap_time
install_packages
configure_time
configure_systemservices
create_users
mount_iscsi
mount_nfs

echo "Script finished. Exiting!"
exit 0
