Script to perform automated backup of data to a network server using restricted public/private key pair authentication,
which ensures that the server is not exposed to general users of the client computers.

Instructions of use:
This script is used to perform passwordless data backups to a network server via the ssh-based rsync protocol 
rather than using a mounted network drive (e.g. a samba share). In order for the script to work properly and
only provide passwordless server access to the rsync program, and not passwordless general ssh access, some
setup is needed on both the client computer and the server.

If the client computer is a Windows machine, first install git-bash (gitforwindows.org) and the ZSTD compression
tool (https://github.com/facebook/zstd/releases). Download the rsync and libxxhash packages from the msys2 
repository (https://repo.msys2.org/msys/x86_64/). Decompress the packages with zstd ('zstd -d /path/to/package')
and merge the contents of the resultant .tar files with the usr folder of the git-bash installation folder.
git-bash should now have a working rsync implementation.
If the client machine runs Linux, rsync should already be preinstalled, so the above can be skipped.

Still on the client machine, run the bash command 'ssh-keygen' (for ed25519 encryption) or 'ssh-keygen -t rsa -b 4096'
(for rsa encryption) to generate a public/private key pair. Save the key pair as 'id_<algorithm>_rsync' and leave the
passphrase blank. Copy the public key to the authorized_keys file on the server (~/.ssh/authorized_keys) to enable 
passwordless access.

To restrict the key pair to only allow connections through the rsync program, edit the authorized_keys file on the 
server and add 'command="rsync --server -aviPCe.iLsfx --stats . </path/to/backup/folder>",restrict' in front of
the public key. This will run the specified rsync server command when requested, but restrict all other access 
using the specified key.

Set the source paths, etc. in the shell script file (note that the source and destination paths should be in arrays even if there's only 
one entry, and should NOT include trailing slashes) and execute the script through git-bash/terminal on
the client machine (it may be necessary to enable execution permissions first).

To schedule automatic backups, set up a cron job (Linux) using 'crontab -e' or a task in Task Scheduler (Windows).
