# [spaste](https://spaste.oxasploits.com)
## A pure perl SSL encrypted port of fiche/termbin.com.

### Notes
For the server I suggest adding an ssl group and spaste user, the systemd startup/respawn script if its a dedicated setup, and the crontab entry that removes expired pastes, for security purposes.

### Deps
openssl or perl

### Install
To install, run `install.sh`

### Use
Useage: `echo "yes hello" | sp`

### Thanks
Thanks for a bugfix, brianx!
Thanks to the creators of [termbin.com](https://github.com/solusipse/fiche) for the general idea!
