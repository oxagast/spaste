A pure perl SSL encrypted port of https://github.com/solusipse/fiche termbin.com.

I suggest adding an ssl group and pastebot user for security purposes.

Useage:
Pastes easier by adding: `alias sp='ncat --ssl spaste.online 8888'`
or the more portable but less pretty: `alias sp='openssl s_client -quiet -connect spaste.online:8888 2>/dev/null'`

`echo "is this thing working?" | ncat --ssl spaste.online 8888`

`echo "yes hello" | sp
