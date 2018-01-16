alias clang="~/Programs/llvm38/build/bin/clang"
alias clang++="~/Programs/llvm38/build/bin/clang++"
alias opt="~/Programs/llvm38/build/bin/opt"
alias llvm-config="~/Programs/llvm38/build/bin/llvm-config"

source ${HOME}/.zgen/zgen.zsh
if ! zgen saved; then
  zgen oh-my-zsh
  zgen oh-my-zsh themes/steeef
  zgen load zsh-users/zsh-syntax-highlighting
  zgen save
  
  zgen save
fi

# execute immediately
unsetopt HIST_VERIFY

alias vim="nvim"
alias ack='ag'
alias rpython="~/Documents/pypy/rpython/bin/rpython"

#
# Defines transfer alias and provides easy command line file and folder sharing.
#
# Authors:
#   Remco Verhoef <remco@dutchcoders.io>
#

curl --version 2>&1 > /dev/null
if [ $? -ne 0 ]; then
  echo "Could not find curl."
  return 1
fi

transfer() {
  # check arguments
  if [ $# -eq 0 ];
  then
    echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
    return 1
  fi

  # get temporarily filename, output is written to this file show progress can be showed
  tmpfile=$( mktemp -t transferXXX )

  # upload stdin or file
  file=$1

  if tty -s;
  then
    basefile=$(basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g')

    if [ ! -e $file ];
    then
      echo "File $file doesn't exists."
      return 1
    fi

    if [ -d $file ];
    then
      # zip directory and transfer
      zipfile=$( mktemp -t transferXXX.zip )
      cd $(dirname $file) && zip -r -q - $(basename $file) >> $zipfile
      curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> $tmpfile
      rm -f $zipfile
    else
      # transfer file
      curl --progress-bar --upload-file "$file" "https://transfer.sh/$basefile" >> $tmpfile
    fi
  else
    # transfer pipe
    curl --progress-bar --upload-file "-" "https://transfer.sh/$file" >> $tmpfile
  fi

  # cat output link
  cat $tmpfile

  # cleanup
  rm -f $tmpfile
}


# export PYTHONDONTWRITEBYTECODE=1
export PATH=$PATH:/opt/local/bin
# export PATH="$PATH:/usr/local/opt/ruby/bin:~/twelf/sml/bin/:`yarn global bin`"
