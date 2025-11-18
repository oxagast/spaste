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

SPSTR="alias sp='timeout 1s openssl s_client -quiet -servername spaste.oxasploits.com \
  -verify_return_error -connect spaste.oxasploits.com:8866 2>/dev/null | grep -v END |\
  tr -d \"\n\"; echo'"
SHF=""

isinst()
{
  if [[ "$1" != "upgrade" ]]; then
    if [[ $(cat $SHF | grep -c "alias sp=") -gt 0 ]]; then
      echo "SPaste seems to be already installed!"
      exit 1
    fi
    if [[ -x "$HOME/.local/bin/sp" ]]; then
      echo "Spaste seems to be already installed!"
      exit 1
    fi
  fi
}

installo()
{
  if [[ -w "${SHF}" ]]; then
    echo $SPSTR >>$SHF
    echo "Sucessfully installed!"
    echo "To complete the install, please run:  source ${SHF}"
    exit 0
  else
    return 1
  fi
}

installp()
{
  echo "Installing perl client..."
  if mkdir -p $HOME/.local/bin; then
    if cp bin/paste-client.pl $HOME/.local/bin/sp; then
      chmod +x $HOME/.local/bin/sp
      echo "Installed perl script locally!"
      echo "Please make sure ~/.local/bin is in your \$PATH."
    else
      echo "Could not install script in local bin dir!"
    fi
  else
    echo "Could not create dir for script!"
  fi

  exit 0
}

if command -v "openssl" 2>&1 >/dev/null; then
  if [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "bash" ]]; then
    SHF="$HOME/.bashrc"
    isinst $1
    installo || installp
  elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "zsh" ]]; then
    SHF="$HOME/.zshrc"
    isinst $1
    installo || installp
  elif [[ $(ps -p $PPID | grep -v CMD | awk '{print $NF}') == "sh" ]]; then
    SHF="$HOME/.profile"
    isinst $1
    installo || installp
  else
    echo "Couldn't detect shell, falling back to perl client!" && installp
  fi
else
  echo "Didn't find openssl, falling back to perl client!" && installp
fi
