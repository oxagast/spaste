A pure perl SSL encrypted port of https://github.com/solusipse/fiche termbin.com in perl.

I suggest adding an ssl group and spaste user, the systemd startup/respawn script if its a dedicated setup, and the crontab entry that removes expired pastes, for security purposes.

Install: `echo "alias sp='openssl s_client -verify_return_error -servername spaste.oxasploits.com -quiet -connect spaste.oxasploits.com:8888 2>/dev/null'" >> ~/.bashrc && source ~/.bashrc`

Useage: `echo "yes hello" | sp`

Thanks for a bugfix, brianx!
