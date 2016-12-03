#!/bin/bash

target="$(readlink -f $1)"

if [ ! -d "$target" ]
then
    echo No such directory: $target
    exit 1
fi

functions=""

envs=(
  ipython  pyvenv      ipython  ipython  ipython
  ipython2 virtualenv2 ipython2 ipython  ipython
  bpython  pyvenv      bpython  bpython  bpython
  bpython2 virtualenv2 bpython2 bpython  bpython
  markdown pyvenv      markdown markdown markdown_py
)

for (( i=0; i<${#envs[@]}; i+=5 ))
do
    funname=${envs[$i]}
    venvbin=${envs[$i+1]}
    envname=${envs[$i+2]}
    pipname=${envs[$i+3]}
    binname=${envs[$i+4]}

    envpath="$target/$envname"
    $venvbin "$envpath"
    $envpath/bin/pip install --upgrade "$pipname"
    functions="$functions$funname () {
 local ep="$envpath/bin"
 source \$ep/activate
 \$ep/$binname \$@
 deactivate
}
"
done

echo "# paste into .bashrc/.zshrc:"
echo -e "$functions"
