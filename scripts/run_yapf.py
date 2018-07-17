#!/usr/bin/env python
from os import path, scandir

from yapf.yapflib.yapf_api import FormatFile

IGNORE_DIRS = ['migrations', 'node_modules', 'venv', '__pycache__', '.git', '.tox']
ROOT_DIR = path.dirname(path.dirname(path.abspath(__file__)))


def yapf_file(f):
    """Run yapf on file."""
    print(f.path)
    FormatFile(f.path, in_place=True, style_config=f'{ROOT_DIR}/.style.yapf')


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
