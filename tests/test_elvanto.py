# -*- coding: utf-8 -*-
import pytest
import vcr

from apostello import models as ap_models
from elvanto.elvanto import fix_elvanto_numbers, try_both_num_fields
from elvanto.exceptions import NotValidPhoneNumber
from elvanto import models as elv_models
from site_config import models as sc_models
from tests.conftest import post_json

my_vcr = vcr.VCR(record_mode='none', ignore_localhost=True)


class TestElvantoNumbers:
    """Test normalising of Elvanto numbers"""

    def test_no_change(self):
        """Test well formed number."""
        assert '+44790445806' == fix_elvanto_numbers('+44790445806')

    def test_no_c_code(self):
        """Test mobile number with no country code."""
        assert '+44790445806' == fix_elvanto_numbers('0790445806')

    def test_non_mobile(self):
        """Test a non-mobile number."""
        with pytest.raises(NotValidPhoneNumber):
            fix_elvanto_numbers('01311555555')

    def test_brackets_space(self):
        """Test a mobile number with brackets and spaces."""
        assert '+44790445806' == fix_elvanto_numbers('(0790) 445806')


class TestTryBothFields:
    """Test falling back to "phone" field"""

    def test_mobile_good(self):
        """Test a well formed mobile number."""
        assert try_both_num_fields('+447902537905', '') == '+447902537905'

    def test_phone_good(self):
        """Test a bad mobile number, but a good "phone" number."""
        assert try_both_num_fields(
            '+457902537905', '07902537905'
        ) == '+447902537905'

    def test_both_good(self):
        """Test both numbers well formed."""
        assert try_both_num_fields(
            '+447902537905', '+447666666666'
        ) == '+447902537905'

    def test_neither_good(self):
        """Test both numbers are invalid."""
        with pytest.raises(NotValidPhoneNumber):
            try_both_num_fields('+448902537905', '+457902537905')


@pytest.mark.elvanto_api
@pytest.mark.django_db
class TestApi:
    """
    Test api methods.

    Note - this calls the Elvanto api and will hit their site.
    """

    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_fetch_elvanto_groups(self):
        """Test fetching groups from elvanto."""
        elv_models.ElvantoGroup.fetch_all_groups()
        assert elv_models.ElvantoGroup.objects.get(
            e_id='41dd51d9-d3c5-11e4-95ba-068b656294b7'
        ).name == 'Geneva'
        assert elv_models.ElvantoGroup.objects.get(
            e_id='4ad1c22b-d3c5-11e4-95ba-068b656294b7'
        ).name == 'England'
        assert elv_models.ElvantoGroup.objects.get(
            e_id='50343ad0-d3c5-11e4-95ba-068b656294b7'
        ).name == 'Scotland'
        assert elv_models.ElvantoGroup.objects.get(
            e_id='549f2473-d3c5-11e4-95ba-068b656294b7'
        ).name == 'Empty'
        assert elv_models.ElvantoGroup.objects.get(
            e_id='7ebd2605-d3c7-11e4-95ba-068b656294b7'
        ).name == 'All'

    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_pull_elvanto_group(self):
        """Test pull individual group into apostello."""
        elv_models.ElvantoGroup.fetch_all_groups()
        e_group = elv_models.ElvantoGroup.objects.get(name='England')
        e_group.pull()
        a_group = ap_models.RecipientGroup.objects.get(name='(E) England')
        assert 'John Owen' in a_group.all_recipients_names
        assert str(a_group.recipient_set.all()[0]) == 'John Owen'
        assert str(a_group.recipient_set.all()[0].number) == '+447902546589'

    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_pull_all_groups(self):
        """Test pull all groups into apostello."""
        elv_models.ElvantoGroup.fetch_all_groups()
        england = elv_models.ElvantoGroup.objects.get(name='England')
        england.sync = True
        england.save()
        geneva = elv_models.ElvantoGroup.objects.get(name='Geneva')
        geneva.sync = True
        geneva.save()
        elv_models.ElvantoGroup.pull_all_groups()
        e_group = elv_models.ElvantoGroup.objects.get(name='England')
        e_group.pull()
        a_group = ap_models.RecipientGroup.objects.get(name='(E) England')
        assert 'John Owen' in a_group.all_recipients_names
        assert str(a_group.recipient_set.all()[0]) == 'John Owen'
        assert str(a_group.recipient_set.all()[0].number) == '+447902546589'


@pytest.mark.slow
@pytest.mark.django_db
class TestPostToUrls:
    """Test posting to elvanto api endpoints"""

    @my_vcr.use_cassette(
        'tests/fixtures/vcr_cass/elv.yaml', filter_headers=['authorization']
    )
    def test_api_elvanto_posts(self, users):
        """Test posting to end points behind elvanto buttons."""
        # turn on sync
        config = sc_models.SiteConfiguration.get_solo()
        config.sync_elvanto = True
        config.save()
        r = post_json(users['c_staff'], '/api/v1/elvanto/group_fetch/', {})
        post_json(users['c_staff'], '/api/v1/elvanto/group_pull/', {})
        r = users['c_staff'].get('/api/v1/elvanto/groups/')
        assert len(r.data) == 4
        r = users['c_staff'].get('/api/v1/elvanto/group/1')
        assert r.data['name'] == 'Geneva'
        assert r.data['pk'] == 1
        r = post_json(
            users['c_staff'], '/api/v1/elvanto/group/1', {'sync': False}
        )
        assert r.data['sync']
        assert elv_models.ElvantoGroup.objects.get(pk=1).sync
        r = post_json(
            users['c_staff'], '/api/v1/elvanto/group/1', {'sync': True}
        )
        assert r.data['sync'] is False
        assert elv_models.ElvantoGroup.objects.get(pk=1).sync is False
