import pytest

from graphs.sms_freq import sms_graph_data


@pytest.mark.django_db
class TestSmsFreq:
    def test_sms_freq_in(self, smsin):
        graph_data = sms_graph_data(direction="in")
        assert 3 in graph_data

    def test_sms_freq_out(self, smsout):
        graph_data = sms_graph_data(direction="out")
        assert 1 in graph_data
