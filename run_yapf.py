#!/usr/bin/env python
import subprocess
try:
    from os import scandir
except ImportError:
    from scandir import scandir

IGNORE_DIRS = [
    'migrations', 'node_modules', 'venv', '__pycache__', '.git', '.tox'
]


def yapf_file(f):
    print(f.path)
    subprocess.call("yapf -i {}".format(f.path), shell=True)


def yapf_or_recr(f):
    if f.is_dir():
        if f.name in IGNORE_DIRS:
            return
        for x in scandir(f.path):
            yapf_or_recr(x)
    else:
        if f.name.endswith('.py'):
            yapf_file(f)


if __name__ == "__main__":
    for f in scandir('.'):
        yapf_or_recr(f)
