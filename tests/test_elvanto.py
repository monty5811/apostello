# -*- coding: utf-8 -*-
import pytest

from apostello.models import RecipientGroup
from elvanto.elvanto import fix_elvanto_numbers, try_both_num_fields
from elvanto.exceptions import NotValidPhoneNumber
from elvanto.models import ElvantoGroup


class TestElvantoNumbers:
    """Test normalising of Elvanto numbers"""

    def test_no_change(self):
        assert '+44790445806' == fix_elvanto_numbers('+44790445806')

    def test_no_c_code(self):
        assert '+44790445806' == fix_elvanto_numbers('0790445806')

    def test_non_mobile(self):
        with pytest.raises(NotValidPhoneNumber):
            fix_elvanto_numbers('01311555555')

    def test_brackets_space(self):
        assert '+44790445806' == fix_elvanto_numbers('(0790) 445806')


class TestTryBothFields:
    """Test falling back to "phone" field"""

    def test_mobile_good(self):
        assert try_both_num_fields('+447902537905', '') == '+447902537905'

    def test_phone_good(self):
        assert try_both_num_fields('+457902537905',
                                   '07902537905') == '+447902537905'

    def test_both_good(self):
        assert try_both_num_fields('+447902537905',
                                   '+447666666666') == '+447902537905'

    def test_neither_good(self):
        with pytest.raises(NotValidPhoneNumber):
            try_both_num_fields('+448902537905', '+457902537905')


@pytest.mark.slow
@pytest.mark.django_db
class TestApi:
    """
    Test api methods.

    Note - this calls the Elvanto api and will hit their site.
    """

    def test_fetch_elvanto_groups(self):
        ElvantoGroup.fetch_all_groups()
        assert ElvantoGroup.objects.get(
            e_id='41dd51d9-d3c5-11e4-95ba-068b656294b7').name == 'Geneva'
        assert ElvantoGroup.objects.get(
            e_id='4ad1c22b-d3c5-11e4-95ba-068b656294b7').name == 'England'
        assert ElvantoGroup.objects.get(
            e_id='50343ad0-d3c5-11e4-95ba-068b656294b7').name == 'Scotland'
        assert ElvantoGroup.objects.get(
            e_id='549f2473-d3c5-11e4-95ba-068b656294b7').name == 'Empty'
        assert ElvantoGroup.objects.get(
            e_id='7ebd2605-d3c7-11e4-95ba-068b656294b7').name == 'All'

    def test_pull_elvanto_group(self):
        ElvantoGroup.fetch_all_groups()
        e_group = ElvantoGroup.objects.get(name='England')
        e_group.pull()
        a_group = RecipientGroup.objects.get(name='[E] England')
        assert 'John Owen' in a_group.all_recipients_names
        assert str(a_group.recipient_set.all()[0]) == 'John Owen'
        assert str(a_group.recipient_set.all()[0].number) == '+447902546589'

    def test_pull_all_groups(self):
        ElvantoGroup.fetch_all_groups()
        england = ElvantoGroup.objects.get(name='England')
        england.sync = True
        england.save()
        geneva = ElvantoGroup.objects.get(name='Geneva')
        geneva.sync = True
        geneva.save()
        ElvantoGroup.pull_all_groups()
        e_group = ElvantoGroup.objects.get(name='England')
        e_group.pull()
        a_group = RecipientGroup.objects.get(name='[E] England')
        assert 'John Owen' in a_group.all_recipients_names
        assert str(a_group.recipient_set.all()[0]) == 'John Owen'
        assert str(a_group.recipient_set.all()[0].number) == '+447902546589'
