import os
import subprocess

import click


@click.command('start')
def start():
    '''Start apostello production environment'''
    if not os.path.isfile('.env'):
        click.echo('You have not configured apostello yet')
        click.echo('Please run the config command:')
        click.echo('\t apostello config')
        return
    click.echo('Starting apostello ...')
    try:
        subprocess.check_call('docker-compose up -d'.split())
    except subprocess.CalledProcessError:
        click.echo('apostello was unable to fully start')
        click.echo('Run apostello logs for more info')
        return
    except Exception:
        return
    click.echo('\tApostello is now running')
    click.echo('\t View logs with apostello logs')


@click.command('stop')
def stop():
    '''Stop apostello production environment'''
    click.echo('Stopping apostello ...')
    subprocess.call('docker-compose stop'.split())


@click.command('logs')
def logs():
    '''Show apostello logs'''
    subprocess.call('docker-compose logs'.split())
