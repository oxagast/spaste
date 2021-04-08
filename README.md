A pure perl SSL encrypted port of https://github.com/solusipse/fiche termbin.com.

I suggest adding an ssl group and pastebot user for security purposes.

Useage:
`echo "is this thing working?" | ncat --ssl spaste.online 8888`
or:
`alias sp='openssl s_client -quiet -connect spaste.online:8888 2>/dev/null'`

You can make later pastes easier by adding: `alias spaste='ncat --ssl spaste.online 8888'`

`echo "yes hello" | spaste`
