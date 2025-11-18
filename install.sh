#!/bin/bash
if [[ $(whoami) == "root" ]]; then
  echo "Warning: This will install spaste locally as root, you probaby want to run this as your own user!"
  sleep 10
fi
echo "Preparing to install SPaste client..."
if ! command -v "perl" 2>&1 >/dev/null && ! command -v "openssl" 2>&1 >/dev/null; then
  echo "Please first install the openssl package for your distro, this will not work without it!"
  echo "   Redhat based:    $ sudo dnf install openssl"
  echo "   Debian based:    $ sudo apt install openssl"
  echo "   Arch based:      $ sudo pacman -S openssl"
  exit 1
fi

SPSTR=YWxpYXMgc3A9InRpbWVvdXQgMXMgb3BlbnNzbCBzX2NsaWVudCAtcXVpZXQgLXNlcnZlcm5hbWUgc3Bhc3RlLm94YXNwbG9pdHMuY29tIC12ZXJpZnlfcmV0dXJuX2Vycm9yIC1jb25uZWN0IHNwYXN0ZS5veGFzcGxvaXRzLmNvbTo4ODY2IDI+L2Rldi9udWxsIHwgZ3JlcCAtdiBFTkQgfCB0ciAtZCAnXG4nOyBlY2hvIgo=
SHF=""

isinst()
{
  if [[ $(cat $SHF | grep -c "alias sp=") -gt 0 ]]; then
    echo "SPaste seems to be already installed!"
    exit 1
  fi
}

installo()
{
  echo $SPSTR | base64 -d >>$SHF
  echo "Sucessfully installed!"
}

installp()
{
  mkdir -p $HOME/.local/bin
  cp bin/spaste-client.pl $HOME/.local/bin && echo "Installed perl script locally!"
  exit 0
}

if command -v "openssl" 2>&1 >/dev/null; then
  if [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "bash" ]]; then
    SHF="$HOME/.bashrc"
    isinst
    installo
  elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "zsh" ]]; then
    SHF="$HOME/.zshrc"
    isinst
    installo
  elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "sh" ]]; then
    SHF="$HOME/.profile"
    isinst
    installo
  else
    echo "Couldn't detect shell, falling back to installing perl client in $HOME/.local/bin/!"
    installp
    echo "Unable to install!" && exit 1
  fi
else
  echo "Didn't find openssl, falling back to installing perl client in $HOME/.local/bin/!"
  installp
  echo "Unable to install!" && exit 1
  echo "To complete the install, please run:  source ${SHF}"
  exit 0
fi
