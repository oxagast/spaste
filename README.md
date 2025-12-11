# [spaste](https://spaste.oxasploits.com)
## A pure perl SSL encrypted port of fiche/termbin.com.

### Notes
For the server I suggest adding an ssl group and spaste user, the systemd startup/respawn script if its a dedicated setup, and the crontab entry that removes expired pastes, for security purposes.

### Deps
openssl or perl

### Install
To install (this is a local install, no sudo needed), run:<br>
`./install.sh`<br>
or add the following line to your shell's startup file:<br>
`alias sp='timeout 3s openssl s_client -quiet -servername spaste.oxasploits.com -verify_return_error -connect spaste.oxasploits.com:8866 2>/dev/null | grep -v END | tr -d "\n"; echo'`


### Use
Useage:<br> `echo "yes hello" | sp`

### Thanks
Thanks for a bugfix, brianx!
Thanks to the creators of [termbin.com](https://github.com/solusipse/fiche) for the general idea!
