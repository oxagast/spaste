A pure perl SSL encrypted port of [termbin.com](https://github.com/solusipse/fiche).

For the server I suggest adding an ssl group and spaste user, the systemd startup/respawn script if its a dedicated setup, and the crontab entry that removes expired pastes, for security purposes.

The client is more simple:

Install (perl client): `sudo cp paste-client.pl /usr/local/bin/sp`

Install (openssl client with zsh): `echo "spaste() {timeout 1s openssl s_client -quiet -servername spaste.oxasploits.com -verify_return_error -connect spaste.oxasploits.com:8866 2>/dev/null | grep -v "END" | tr -d '\\\\n'; echo}" >> ~/.zshrc && source ~/.zshrc`

Useage: `echo "yes hello" | sp`

Thanks for a bugfix, brianx!
