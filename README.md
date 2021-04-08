A pure perl SSL encrypted port of https://github.com/solusipse/fiche termbin.com in perl.

I suggest adding an ssl group and pastebot user for security purposes.

Useage: `echo "is this thing working?" | ncat --ssl spaste.online 8888`

Pastes easier by adding: `alias sp='ncat --ssl spaste.online 8888'`

or the more portable but less pretty: `alias sp='openssl s_client -quiet -connect spaste.online:8888 2>/dev/null'`

then running: `source ~/bashrc` so it works in your current session then: `echo "yes hello" | sp
