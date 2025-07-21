A pure perl SSL encrypted port of https://github.com/solusipse/fiche (termbin.com).

I suggest adding an ssl group and spaste user, the systemd startup/respawn script if its a dedicated setup, and the crontab entry that removes expired pastes, for security purposes.

Install: `sudo cp paste-client.pl /usr/local/bin/spaste`
(Still works with openssl for historical purposes!)

Useage: `echo "yes hello" | spaste`

Thanks for a bugfix, brianx!
