A perl SSL encrypted port of https://github.com/solusipse termbin.com.

I suggest adding an ssl group and pastebot user for security purposes.

Useage:
`echo "is this thing working?" | ncat --ssl spaste.online 8888`

You can make later pastes easier by adding: `alias spaste='ncat --ssl spaste.online 8888'`
`echo "yes hello" | spaste`
