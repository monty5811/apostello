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
    """Run yapf on file."""
    print(f.path)
    subprocess.call(
        "yapf -i {} --style scripts/.style.yapf".format(f.path), shell=True
    )


def yapf_or_recr(f):
    """Run yapf or descend into folder."""
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
