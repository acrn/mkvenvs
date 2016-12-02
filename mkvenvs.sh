#!/bin/bash

target="$(readlink -f $1)"

if [ ! -d "$target" ]
then
    echo No such directory: $target
    exit 1
fi

IFS="\0"

py3venvs=(
  bpython
  ipython
  markdown2
  )
py2venvs=(
  bpython
  ipython
  )

functions=""

for venv in ${py3venvs[@]}
do
    envpath="$target/${venv}"
    pyvenv "$envpath"
    source "$envpath/bin/activate"
    [[ ! "$(which pip)" =~ ^$target.* ]] \
        && echo error error \
        && exit 1
    pip install $venv
    deactivate
    functions="$functions${venv} () {
  local ep="$envpath/bin"
  source \$ep/activate
  \$ep/$venv \$@
  deactivate
}
"
done

for venv in ${py2venvs[@]}
do
    envpath="$target/${venv}2"
    virtualenv2 "$envpath"
    source "$envpath/bin/activate"
    [[ ! "$(which pip)" =~ ^$target.* ]] \
        && echo error error \
        && exit 1
    pip install $venv
    deactivate
    functions="$functions${venv}2 () {
  local ep="$envpath/bin"
  source \$ep/activate
  \$ep/$venv \$@
  deactivate
}
"
done

echo "# paste into .bashrc/.zshrc:"
echo -e "$functions"
