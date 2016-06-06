import logging

from django.db import models
from django.utils import timezone

from apostello.models import Recipient, RecipientGroup
from elvanto.elvanto import elvanto, try_both_num_fields
from elvanto.exceptions import ElvantoException, NotValidPhoneNumber

logger = logging.getLogger('apostello')


class ElvantoGroup(models.Model):
    """Stores details of Elvanto Groups."""
    sync = models.BooleanField("Automatic Sync", default=False)
    name = models.CharField("Group Name", max_length=255)
    e_id = models.CharField("Elvanto ID", max_length=36, unique=True)
    last_synced = models.DateTimeField(blank=True, null=True)

    def create_apostello_group(self):
        """
        Return the internal apostello group.

        Creates it if it does not already exist.
        """
        grp = RecipientGroup.objects.get_or_create(
            name=self.apostello_group_name
        )[0]
        grp.description = 'Imported from Elvanto'
        grp.save()
        return grp

    def pull(self):
        """Pull group from Elvanto into related apostello group."""
        apostello_group = self.create_apostello_group()
        data = elvanto("groups/getInfo", id=self.e_id, fields=['people'])
        if data['status'] != 'ok':
            raise ElvantoException

        if data['group'][0]['people']:
            for prsn in data['group'][0]['people']['person']:
                ElvantoGroup.add_person(apostello_group, prsn)

        apostello_group.save()
        self.last_synced = timezone.now()
        self.save()

    @staticmethod
    def add_person(grp, prsn):
        """Add person to group (and apostello if required)."""
        try:
            number = try_both_num_fields(prsn['mobile'], prsn['phone'])
        except NotValidPhoneNumber:
            print(
                'Adding {0} {1} failed ({2},{3})'.format(
                    prsn['firstname'], prsn['lastname'], prsn['mobile'],
                    prsn['phone']
                )
            )
            return
        # create person
        prsn_obj = Recipient.objects.get_or_create(number=number)[0]
        prsn_obj.first_name = prsn['firstname'] if not prsn[
            'preferred_name'
        ] else prsn['preferred_name']
        prsn_obj.last_name = prsn['lastname']
        prsn_obj.save()
        # add person to group
        grp.recipient_set.add(prsn_obj)

    @staticmethod
    def fetch_all_groups():
        """Pull all group names and ids from Elvanto."""
        data = elvanto("groups/getAll")
        if data['status'] != 'ok':
            raise ElvantoException

        for grp in data['groups']['group']:
            grp_obj = ElvantoGroup.objects.get_or_create(e_id=grp['id'])[0]
            grp_obj.name = grp['name']
            grp_obj.save()

    @staticmethod
    def pull_all_groups():
        """Pull people from groups and updates the related apostello group."""
        for grp in ElvantoGroup.objects.all():
            if grp.sync:
                try:
                    grp.pull()
                except ElvantoException:
                    # TODO add logging
                    pass
                except Exception:
                    logger.error('Elvanto group import failed.', exc_info=True)

    @property
    def apostello_group_name(self):
        """
        Name of internal group.

        Just preprend an [E] before the group name.
        """
        return '[E] {0}'.format(self.name)

    def __str__(self):
        """Pretty representation."""
        return self.apostello_group_name

    class Meta:
        ordering = ['name']
