import subprocess

import click

from cli import apostello
from cli import build
from cli import db


def get_max_ver():
    subprocess.call('git fetch'.split())
    import semantic_version
    tags = subprocess.check_output('git tag'.split())
    tags = tags.decode('utf-8').strip().split('\n')

    versions = [semantic_version.Version(tag.strip('v')) for tag in tags]
    max_version = max(versions)
    vtag = 'v{0}'.format(str(max_version))

    return vtag


@click.option(
    '--version',
    help='Version to update to, if blank, will default to latest version.',
    prompt=True,
    default=get_max_ver,
)
@click.command('upgrade')
@click.pass_context
def upgrade(ctx, version=None):
    """Upgrade apostello"""
    vtag = version
    if not vtag.startswith('v'):
        vtag = 'v' + vtag

    confirm_prompt = 'Are you sure you want to upgrade to {0}\n' \
        'This may result in a few minutes of downtime.\n' \
        'You should also have regular backups in place in case an' \
        ' upgrade fails.\n' \
        'Also note that if a database migration is required you may' \
        ' not be able to perform an automatic downgrade.'.format(vtag)

    if not click.confirm(confirm_prompt):
        return

    checkout_cmd = 'git checkout {}'.format(vtag)
    subprocess.call(checkout_cmd.split())

    ctx.invoke(apostello.stop)
    ctx.invoke(build.build)
    ctx.invoke(apostello.start)
    ctx.invoke(db.migrate)

    click.echo('Congratulations, you have upgraded to {0}'.format(vtag))
