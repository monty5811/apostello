# -*- coding: utf-8 -*-
import pytest

from ..elvanto import (fix_elvanto_numbers, grab_elvanto_groups,
                       grab_elvanto_people, import_elvanto_groups,
                       try_both_num_fields)


class TestElvantoNumbers:
    def test_no_change(self):
        assert '+44790445806' == fix_elvanto_numbers('+44790445806')

    def test_no_c_code(self):
        assert '+44790445806' == fix_elvanto_numbers('0790445806')

    def test_non_mobile(self):
        assert fix_elvanto_numbers('01311555555') is None

    def test_brackets_space(self):
        assert '+44790445806' == fix_elvanto_numbers('(0790) 445806')


class TestTryBothFields:
    def test_mobile_good(self):
        assert try_both_num_fields('+447902537905', '') == '+447902537905'

    def test_phone_good(self):
        assert try_both_num_fields('+457902537905', '07902537905') == '+447902537905'

    def test_both_good(self):
        assert try_both_num_fields('+447902537905', '+447666666666') == '+447902537905'

    def test_neither_good(self):
        assert try_both_num_fields('+448902537905', '+457902537905') is None


class TestApi:
    def test_grab_elvanto_groups(self):
        groups = grab_elvanto_groups()
        assert groups[0] == (u'41dd51d9-d3c5-11e4-95ba-068b656294b7', u'Geneva')
        assert groups[1] == (u'4ad1c22b-d3c5-11e4-95ba-068b656294b7', u'England')
        assert groups[2] == (u'50343ad0-d3c5-11e4-95ba-068b656294b7', u'Scotland')
        assert groups[3] == (u'549f2473-d3c5-11e4-95ba-068b656294b7', u'Empty')
        assert groups[4] == (u'7ebd2605-d3c7-11e4-95ba-068b656294b7', u'All')

    def test_grab_elvanto_people(self):
        geneva = grab_elvanto_people('41dd51d9-d3c5-11e4-95ba-068b656294b7')
        assert geneva[0] == 'Geneva'
        assert geneva[1][0]['last_name'] == 'Calvin'

    def test_grab_elvanto_blank_group(self):
        empty = grab_elvanto_people('549f2473-d3c5-11e4-95ba-068b656294b7')
        assert empty[0] == 'Empty'
        assert len(empty[1]) == 0

    @pytest.mark.django_db
    def test_import_all_groups(self):
        group_ids = [u'41dd51d9-d3c5-11e4-95ba-068b656294b7',
                     u'4ad1c22b-d3c5-11e4-95ba-068b656294b7',
                     u'50343ad0-d3c5-11e4-95ba-068b656294b7',
                     u'549f2473-d3c5-11e4-95ba-068b656294b7',
                     u'7ebd2605-d3c7-11e4-95ba-068b656294b7']
        import_elvanto_groups(group_ids, 'test')
