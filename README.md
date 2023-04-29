A pure perl SSL encrypted port of https://github.com/solusipse/fiche termbin.com in perl.

I suggest adding an ssl group and spaste user, the systemd startup/respawn script if its a dedicated setup, and the crontab entry that removes expired pastes, for security purposes.

Install: `echo "alias sp='openssl s_client -quiet -connect spaste.online:8888 2>/dev/null'" >> ~/.bashrc && source ~/.bashrc`

Useage: `echo "yes hello" | sp`

Notes: This also works with ncat from the nmap package ( `ncat -ssl spaste.oxasploits.com 8888` ) if you have that installed but for some odd reason not openssl.
