import os
import subprocess
from datetime import datetime

import click
from cli import apostello


@click.command('migrate')
def migrate():
    '''Apply database migrations'''
    subprocess.call('docker-compose exec django ./manage.py migrate'.split())


@click.command('db_backup')
@click.pass_context
def backup(ctx):
    """Backup current state of database"""
    cmd = 'docker-compose exec postgres backup'
    try:
        ctx.invoke(apostello.stop)
        subprocess.check_call('docker-compose start postgres'.split())
        subprocess.check_call('docker-compose exec postgres backup'.split())
        subprocess.check_call('docker-compose stop postgres'.split())
        ctx.invoke(apostello.start)
    except subprocess.CalledProcessError:
        click.echo("Backup failed!")
        return
    click.echo('')
    click.echo('You should make a backup of the docker/backups folder')
    click.echo(
        'Be aware that the database dump may contain sensitive information, such as access tokens and phone numbers.'
    )


@click.command('db_restore')
@click.pass_context
def restore(ctx):
    """Rebuild db from a backup"""
    backups = [
        x for x in os.listdir('docker/backups/postgres')
        if not x.startswith('.')
    ]
    if not backups:
        click.echo('No backups found')
        return

    click.echo(
        'Be careful as this will restore the database to a previous state'
    )
    click.echo('Any changes made since the backup was created will be lost')

    if not click.confirm('Do you wish to continue?'):
        return

    backup_file = click.prompt(
        'Which backup to you wish to restore?\n{}\n'.format(
            '\n'.join(
                backups
            )
        )
    )
    backup_file = backup_file.strip()
    if not os.path.isfile('docker/backups/postgres/{}'.format(backup_file)):
        click.echo('That file does note exist, please try again.')
        return

    try:
        ctx.invoke(apostello.stop)
        subprocess.check_call('docker-compose start postgres'.split())
        subprocess.call(
            'docker-compose exec postgres restore {}'.format(
                backup_file).split(),
            stdout=subprocess.DEVNULL,
        )
        subprocess.check_call('docker-compose stop postgres'.split())
        ctx.invoke(apostello.start)
    except subprocess.CalledProcessError:
        click.echo('Restore failed!')

    click.echo('')
    click.echo('Restore complete')
