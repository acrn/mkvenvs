#!/usr/bin/env python

import argparse
import os
import subprocess
import sys
import yaml

# the pre-std-lib virtualenv binaries have different names on all distros.
# call it from python instead.
if sys.version_info.major == 3:
    from venv import create as venv_create
    create_args = dict(
            system_site_packages=True,
            symlinks=True,
            with_pip=True)
elif sys.version_info.major == 2:
    from virtualenv import create_environment as venv_create
    create_args = dict(site_packages=True, symlink=True)

with open('envs.yaml') as f:
    envs = yaml.load(f)

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--setup", help="setup empty venvs",
                    action="store_true")
parser.add_argument("-u", "--upgrade", help="upgrade packages",
                    action="store_true")
parser.add_argument("-p", "--printrc", action="store_true",
                    help="print stuff to paste into .bashrc/.zshrc")
args = parser.parse_args()

if args.setup:
    for env in envs:
        dest = os.path.expanduser(env['dest'])
        if env['py_version'] != sys.version_info.major:
            print("WARNING: setup of {} requires re-running with python {}"
                    "".format(dest, env['py_version']))
            continue
        venv_create(dest, **create_args)

if args.upgrade:
    for env in envs:
        dest = os.path.expanduser(env['dest'])
        if env['py_version'] != sys.version_info.major:
            print("WARNING: upgrade of {} requires re-running with python {}"
                    "".format(dest, env['py_version']))
            continue
        subprocess.call([
            os.path.join(dest, 'bin/pip'),
            'install', '--upgrade', 'pip'])
        subprocess.call([
            os.path.join(dest, 'bin/pip'),
            'install', '--upgrade'] + env['install'])

if args.printrc:
    print("### The following goes into .bashrc/.zshrc: ###")
    for env in envs:
        dest = os.path.expanduser(env['dest'])
        for export in env['exports']:
            print("""\
{} () {{local ep="{}";source "$ep/activate";"$ep/{}" $@;deactivate}} \
""".format(
        export['cmd'],
        os.path.join(dest, 'bin'),
        export['bin']
        )
    )
