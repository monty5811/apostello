import subprocess

import click


@click.command('start-dev')
def start_dev():
    '''Start a development environment'''
    click.echo('Starting apostello dev environment ...')
    subprocess.call('docker-compose up -f docker-compose-dev.yml'.split())


@click.command('build-assets')
def build_assets():
    '''Rebuild the frontend assets'''
    click.echo('Building ...')
    subprocess.call(
        'docker-compose build -f docker-compose-assets.yml'.split(
        )
    )
    click.echo('')
    click.echo('Running')
    subprocess.call(
        'docker-compose -f docker-compose-assets.yml run assets'.split()
    )
