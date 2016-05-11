import subprocess

import click


@click.command('build')
def build():
    '''(re)Build docker images'''
    click.echo('Building images')
    subprocess.call('docker-compose build'.split())
    subprocess.call('docker-compose start django'.split())
    click.echo('Preparing static files...')
    subprocess.call(
        'docker-compose exec django ./manage.py collectstatic --noinput'.split(
        )
    )
    click.echo('You can start apostello by running "apostello start"')
