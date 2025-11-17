#!/bin/bash
echo "Installing SPaste client..."
SPSTR=YWxpYXMgc3A9InRpbWVvdXQgMXMgb3BlbnNzbCBzX2NsaWVudCAtcXVpZXQgLXNlcnZlcm5hbWUgc3Bhc3RlLm94YXNwbG9pdHMuY29tIC12ZXJpZnlfcmV0dXJuX2Vycm9yIC1jb25uZWN0IHNwYXN0ZS5veGFzcGxvaXRzLmNvbTo4ODY2IDI+L2Rldi9udWxsIHwgZ3JlcCAtdiBFTkQgfCB0ciAtZCAnXG4nOyBlY2hvIgo=
SHF=""

isinst() {
  if [[ $(cat $SHF | grep -c "alias sp=") -gt 0 ]]; then
   echo "SPaste seems to be already installed!"
   exit 1
  fi
}

if [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "bash" ]]; then
  SHF="$HOME/.bashrc"
  isinst
  echo $SPSTR | base64 -d >> $SHF
  echo "Installed for bash!"
elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "zsh" ]]; then
  SHF="$HOME/.zshrc"
  isinst
  echo $SPSTR | base64 -d >> $SHF
  echo "Installed for zsh!"
elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "sh" ]]; then
  SHF="$HOME/.profile"
  isinst
  echo $SPSTR | base64 -d >> $SHF
  echo "Installed for sh!"
else
  echo "Couldn't detect shell, either manually add an alias, or use the spaste-client.pl script!"
  exit 1
fi
echo "To complete the install, please run:  source ${SHF}"
exit 0
