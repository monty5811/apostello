import pytest


@pytest.mark.slow
@pytest.mark.django_db
class TestCSVImport:
    def test_csv_import_blank(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': ''})

    def test_csv_import_bad_data(self, users):
        users['c_staff'].post('/recipient/import/', {'csv_data': ',,,\n,,,'})

    def test_csv_import_good_data(self, users):
        users['c_staff'].post(
            '/recipient/import/', {
                'csv_data':
                'test,person,+447902533904,\ntest,person,+447902537994'
            }
        )
