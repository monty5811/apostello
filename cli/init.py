import os
import subprocess

import click

from cli.upgrade import get_max_ver


@click.command('init')
def init():
    '''Initialise apostello folder'''
    if os.path.isdir('apostello'):
        click.echo('apostello folder already exists!')
        return
    subprocess.call(
        'git clone https://github.com/monty5811/apostello.git'.split()
    )
    os.chdir('apostello')
    cur_ver = get_max_ver()
    subprocess.call('git checkout {0}'.format(cur_ver).split())
    click.echo('apostello is ready for configuration')
    click.echo('Run cd apostello/ && apostello config')
