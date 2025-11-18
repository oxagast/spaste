#!/bin/bash
echo "Preparing to install SPaste client..."
if ! command -v "openssl" 2>&1 >/dev/null; then
  echo "Please first install the openssl package for your distro, this will not work without it!"
  echo "   Redhat based:    $ sudo dnf install openssl"
  echo "   Debian based:    $ sudo apt install openssl"
  echo "   Arch based:      $ sudo pacman -S openssl"
  exit 1
fi
SPSTR=YWxpYXMgc3A9InRpbWVvdXQgMXMgb3BlbnNzbCBzX2NsaWVudCAtcXVpZXQgLXNlcnZlcm5hbWUgc3Bhc3RlLm94YXNwbG9pdHMuY29tIC12ZXJpZnlfcmV0dXJuX2Vycm9yIC1jb25uZWN0IHNwYXN0ZS5veGFzcGxvaXRzLmNvbTo4ODY2IDI+L2Rldi9udWxsIHwgZ3JlcCAtdiBFTkQgfCB0ciAtZCAnXG4nOyBlY2hvIgo=
SHF=""

isinst() {
  if [[ $(cat $SHF | grep -c "alias sp=") -gt 0 ]]; then
   echo "SPaste seems to be already installed!"
   exit 1
  fi
}

installit() {
  echo $SPSTR | base64 -d >> $SHF
  echo "Sucessfully installed!"
}


if [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "bash" ]]; then
  SHF="$HOME/.bashrc"
  isinst
  if [[ -v BASH_ALIASES[sp] ]]; then
   echo defined
  fi
  installit
elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "zsh" ]]; then
  SHF="$HOME/.zshrc"
  isinst
  installit
elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "sh" ]]; then
  SHF="$HOME/.profile"
  isinst
  instalit
else
  echo "Couldn't detect shell, either manually add an alias, or use the spaste-client.pl script!"
  exit 1
fi
echo "To complete the install, please run:  source ${SHF}"
exit 0
