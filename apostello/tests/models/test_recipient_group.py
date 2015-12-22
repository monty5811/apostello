# -*- coding: utf-8 -*-
import pytest


@pytest.mark.django_db
class TestRecipientGroup:
    def test_display(self, groups):
        assert str(groups['test_group']) == "Test Group"

    def test_sending(self, groups):
        groups['test_group'].send_message(content='test content',
                                          sent_by="user"
                                          )
        groups['empty_group'].send_message(content='test content',
                                           sent_by="user"
                                           )

    def test_all_recipients_names(self, groups):
        assert ['John Calvin', 'Johannes Oecolampadius'] == groups['test_group'].all_recipients_names
        assert [] == groups['empty_group'].all_recipients_names

    def test_get_abs_url(self, groups):
        assert '/group/edit/1/' == groups['test_group'].get_absolute_url

    def test_calculate_cost(self, groups):
        assert 0.08 == groups['test_group'].calculate_cost()
        assert 0 == groups['empty_group'].calculate_cost()

    def test_archiving(self, groups):
        groups['test_group'].archive()
        assert groups['test_group'].is_archived
