import pytest
from tests.conftest import onebody_no_csv_vcr, onebody_vcr

from apostello import models
from onebody.importer import OnebodyException, import_onebody_csv


@pytest.mark.onebody_api
@pytest.mark.django_db
class TestImporting:
    @onebody_vcr
    def test_ok(self):
        """Test fetching people from onebody."""
        import_onebody_csv()
        assert models.RecipientGroup.objects.count() == 1
        assert models.Recipient.objects.count() == 7
        assert models.RecipientGroup.objects.get(name="[onebody]").recipient_set.count() == 7

    @onebody_no_csv_vcr
    def test_csv_fails(self):
        """Test fetching people from onebody."""
        with pytest.raises(OnebodyException):
            import_onebody_csv()
        assert models.RecipientGroup.objects.count() == 0
        assert models.Recipient.objects.count() == 0
