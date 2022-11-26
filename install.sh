#!/usr/bin/env bash

have() { type "$1" > /dev/null 2>&1; }

trash() {
  local TRASH_DIR=~/tmp file

  for file in "$@"; do
    if [ -k "$file" ]; then
      echo "ignoring sticky $file"
    elif [ -e "$file" ] || [ -h "$file" ]; then
      echo "backing up $file -> $TRASH_DIR"
      mkdir -p 0700 "$TRASH_DIR"
      mv "$file" "$TRASH_DIR/old_${file##*/}"
    fi
  done
}

link() {
  local target=$DOT_DIR/${1%/}
  local link=${2:-$HOME/.$1}

  if [ ! -e "$target" ]; then
    err "link target is missing: $link -> $target"
    return
  elif [ -e "$link" ]; then
    if [ -k "$link" ]; then
      echo "ignoring sticky $link"
      return
    elif [ -h "$link" ]; then
      rm -f "$link"
    else
      trash "$link"
    fi
  else
    local linkdir=${link%/*}
    if [ ! -d "$linkdir" ]; then
      mkdir -p "$linkdir"
    fi
  fi
  echo "linking $link -> $target"
  sym -f "$target" "$link"
}

check_owner() {
  local f
  for f in "$@"; do
    if [ -h "$f" ]; then
      continue
    elif [ -e "$f" ] && [ ! -O "$f" ]; then
      case $f in
      */.mysql_history)
        continue
        ;;
      */.lesshst)
        rm -f "$f"
        ;;
      *)
        notice "file '$f' not owned by me, replacing"
        trash "$f"
        ;;
      esac
      (
        umask 077
        touch "$f"
      )
    elif [ -d "$f" ] && [ ! -O "$f" ]; then
      notice "dir '$f' not owned by me, replacing"
      trash "$f"
      (
        umask 077
        mkdir "$f"
      )
    fi
  done
}

#. lib.bash || exit

DOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRASH_DIR=$HOME/tmp

cd "$DOT_DIR" || exit

# Remove undesired files

trash "$HOME"/.{login,logout}
trash "$HOME"/.bash_{login,profile,logout}
trash "$HOME"/.{sh,csh}rc
rm -f "$HOME"/.viminfo

# Install shell profiles

link bashrc
link profile
link xinitrc

# Install CLI program configs (unconditional)

link pythonrc

link git "$HOME"/.config/git

git config --global init.templatedir "$HOME"/.config/git/template

(
  umask 077
  touch "$HOME"/.config/git/credentials
  mkdir -p "$HOME"/.local/share/tig
  touch "$HOME"/.local/share/tig/history
)
#
#link hgrc ~/.config/hg/hgrc
#link lftprc ~/.config/lftp/rc

#chmod 600 msmtprc
#link msmtprc ~/.config/msmtp/config

link ssh/known_hosts
link ssh/config

if have ipython; then
  link ipython/profile_default/ipython_config.py
  link ipython/profile_default/startup
fi

#
#link tmux.conf
#
#link vim ~/.vim
#link vim ~/.config/nvim
#mkdir -p ~/.local/share/nvim/{backup,shada,swap,undo}

# Copy certain settings instead of symlinking
# (common base parameters, but remains host-specific)

if ! grep -qs "^#" "$HOME"/.config/htop/htoprc; then
	mkdir -p "$HOME"/.config/htop
	cp htoprc "$HOME"/.config/htop/htoprc
fi

# Install conditional configs

#if have makepkg; then
#	link pacman/makepkg.conf ~/.config/pacman/makepkg.conf
#fi
#
#if have mutt || have neomutt; then
#	if echo "39089071962b19a4786d5d8ba21dd1a66d1295e8  $HOME/.config/mutt/muttrc" | sha1sum --check --status 2>/dev/null; then
#		rm -f ~/.config/mutt/muttrc
#	fi
#	if [ ! -e ~/.config/mutt/muttrc ]; then
#		(umask 077;
#		 mkdir -p ~/.config/mutt;
#		 touch ~/.config/mutt/muttrc)
#		xdotdir="~/${dotdir#"$HOME/"}"
#		echo "source \"$xdotdir/muttrc\"" > ~/.config/mutt/muttrc
#		echo "source \"$xdotdir/muttrc.sh|\"" >> ~/.config/mutt/muttrc
#	fi
#	if [ ! -e ~/.config/neomutt ]; then
#		ln -nsf mutt ~/.config/neomutt
#	fi
#fi

# Install GUI configs
#
if [ "$DISPLAY" ]; then
  #	cp -n gui/user-dirs.dirs ~/.config/user-dirs.dirs
  #
  #	link gui/XCompose ~/.XCompose
  #
  if [ ! -d "$HOME"/.config/fontconfig ]; then
    link gui/fontconfig ~/.config/fontconfig
  fi

  #
  #	if have openbox; then
  #		link gui/openbox/autostart ~/.config/openbox/autostart
  #		link gui/openbox/rc.xml    ~/.config/openbox/rc.xml
  #	fi
  #
  # Compatibility symlinks
  [ -d ~/.thumbnails ] || sym -f ~/.cache/thumbnails ~/.thumbnails
  [ -d ~/.fonts ] || sym -f ~/.local/share/fonts ~/.fonts
  [ -d ~/.themes ] || sym -f ~/.local/share/themes ~/.themes
fi

link pycharmrc

# Check frequent root-ownership accidents

check_owner ~/.*_history ~/.lesshst ~/.rnd ~/.cache ~/.config ~/.gnupg ~/.local/share

exit 0
