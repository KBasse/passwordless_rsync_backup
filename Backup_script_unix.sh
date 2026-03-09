#!/bin/bash
# Instructions:
# This script is used to perform passwordless data backups to a network server via the ssh-based rsync protocol 
# rather than using a mounted network drive (e.g. a samba share). In order for the script to work properly and
# only provide passwordless server access to the rsync program, and not passwordless general ssh access, some
# setup is needed on both the client computer and the server.
# If the client computer is a Windows machine, first install git-bash (gitforwindows.org) and the ZSTD compression
# tool (https://github.com/facebook/zstd/releases). Download the rsync and libxxhash packages from the msys2 
# repository (https://repo.msys2.org/msys/x86_64/). Decompress the packages with zstd ('zstd -d /path/to/package')
# and merge the contents of the resultant .tar files with the usr folder of the git-bash installation folder.
# git-bash should now have a working rsync implementation.
# If the client machine runs Linux, rsync should already be preinstalled, so the above can be skipped.
# Still on the client machine, run the bash command 'ssh-keygen' (for ed25519 encryption) or 'ssh-keygen -t rsa -b 4096'
# (for rsa encryption) to generate a public/private key pair. Save the key pair as 'id_<algorithm>_rsync' and leave the
# passphrase blank. Copy the public key to the authorized_keys file on the server (~/.ssh/authorized_keys) to enable 
# passwordless access.
# To restrict the key pair to only allow connections through the rsync program, edit the authorized_keys file on the 
# server and add 'command="rsync --server -aviPCe.iLsfx --stats . </path/to/backup/folder>",restrict' in front of
# the public key. This will run the specified rsync server command when requested, but restrict all other access 
# using the specified key.
# Set the source paths, etc. below (note that the source and destination paths should be in arrays even if there's only 
# one entry, and should NOT include trailing slashes) and execute the script through git-bash/terminal on
# the client machine.
# To schedule automatic backups, set up a cron job (Linux) using 'crontab -e' or a task in Task Scheduler (Windows).

source_path=('/path/to/source1' '/path/to/source2' '/path/to/source3')
dest_prefix='uname@IP.of.file.server:'
dest_path=('/path/to/dest1' '/path/to/dest2' '/path/to/dest3')
log_path='/path/to/logfile'
ssh_key='~/.ssh/private_key_file'

############### DO NOT EDIT BELOW THIS LINE ###############

start_time=$(date +"%s") # Set the start time for the execution of the script.

printf "Start time: $(date -d @${start_time})\n" |& tee -a ${log_path}

max_index=${#source_path[@]}

for (( i=0; i<${max_index}; i++ )); do
    #echo $i
    rsync -e "ssh -i ${ssh_key}" -aviP --chmod=D2750,F640 ${source_path[$i]} ${dest_prefix}${dest_path[$i]} |& tee -a ${log_path}
done

end_time=$(date +"%s") # Set end time for the execution of the script.
runtime=$((end_time-start_time)) # Calculate the runtime by subtracting the start time from the end time.

printf "End time: $(date -d @${end_time})\n" |& tee -a ${log_path}

printf "Total runtime: %02d:%02d:%02d\n\n" $((runtime/3600)) $(((runtime/60)%60)) $((runtime%60)) |& tee -a ${log_path} # Print the runtime to terminal. This is useful to determine whether the runtime is shorter than the back-up interval.

rsync -e "ssh -i ${ssh_key}" -aviP ${log_path} ${dest_prefix}${dest_path[0]}
