# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/base/openssh/stone_mod_sshd.sh
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---
#
# [MAIN] 50 sshd SSH Daemon configuration

ssh_privelege_seperation_ug(){
	gui_cmd "Creating ssh host keypair" \
		"groupadd -g 19 sshd ; \
		 useradd -d /var/empty -s /bin/false -g sshd -u 19 \
			-c 'sshd privsep' sshd"
	
}

ssh_create_hostpair(){
	gui_cmd "Creating ssh host keypair" \
                "/usr/bin/ssh-keygen -t rsa1 -f /etc/ssh/ssh_host_key -N '' ; \
		 /usr/bin/ssh-keygen -t dsa  -f /etc/ssh/ssh_host_dsa_key -N '' ; \
		 /usr/bin/ssh-keygen -t rsa  -f /etc/ssh/ssh_host_rsa_key -N '' "
}

main() {
    while
	gui_menu alsa 'SSH Daemon Configuration.' \
		'(Re-)Create a sshd user/group for privelege seperation' \
			'ssh_privelege_seperation_ug' \
		'Create a ssh host keypair' \
			'ssh_create_hostpair' \
		'Configure runlevels for sshd service' \
                        '$STONE runlevel edit_srv sshd' \
                '(Re-)Start sshd init script' \
			'$STONE runlevel restart sshd'
    do : ; done
}

