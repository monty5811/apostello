import pytest

from apostello import models


@pytest.mark.slow
@pytest.mark.django_db
class TestContactForm:
    """Test the sending of SMS."""

    def test_number_permissions_staff_exception(self, recipients, users):
        """Test sending a message now."""
        calvin = recipients["calvin"]
        # check good post:
        prof = users["staff"].profile
        prof.can_see_contact_nums = False
        prof.save()
        r = users["c_staff"].post(
            f"/api/v2/recipients/{calvin.pk}/",
            {
                "pk": calvin.pk,
                "first_name": calvin.first_name,
                "last_name": calvin.last_name,
                "number": "+447900000000",
                "do_not_reply": calvin.do_not_reply,
            },
        )
        assert r.status_code == 200
        calvin.refresh_from_db()
        assert calvin.number == "+447900000000"

    def test_number_permissions_no_perm(self, recipients, users):
        calvin = recipients["calvin"]
        r = users["c_in"].post(
            f"/api/v2/recipients/{calvin.pk}/",
            {
                "pk": calvin.pk,
                "first_name": calvin.first_name,
                "last_name": calvin.last_name,
                "number": "+447900000000",
                "do_not_reply": calvin.do_not_reply,
            },
        )
        assert r.status_code == 400
        assert "You do not have permission to change the number field." in r.json()["errors"]["__all__"]

    def test_number_permissions_with_perm(self, recipients, users):
        calvin = recipients["calvin"]
        # check good post:
        prof = users["notstaff2"].profile
        prof.can_see_contact_nums = True
        prof.save()
        r = users["c_in"].post(
            f"/api/v2/recipients/{calvin.pk}/",
            {
                "pk": calvin.pk,
                "first_name": calvin.first_name,
                "last_name": calvin.last_name,
                "number": "+447900000001",
                "do_not_reply": calvin.do_not_reply,
            },
        )
        assert r.status_code == 200
        calvin.refresh_from_db()
        assert calvin.number == "+447900000001"

    def test_notes_permissions_staff_exception(self, recipients, users):
        """Test sending a message now."""
        calvin = recipients["calvin"]
        # check good post:
        prof = users["staff"].profile
        prof.can_see_contact_notes = False
        prof.save()
        r = users["c_staff"].post(
            f"/api/v2/recipients/{calvin.pk}/",
            {
                "pk": calvin.pk,
                "first_name": calvin.first_name,
                "last_name": calvin.last_name,
                "number": calvin.number,
                "do_not_reply": calvin.do_not_reply,
                "notes": "hi there",
            },
        )
        assert r.status_code == 200
        calvin.refresh_from_db()
        assert calvin.notes == "hi there"

    def test_notes_permissions_no_perm(self, recipients, users):
        calvin = recipients["calvin"]
        r = users["c_in"].post(
            f"/api/v2/recipients/{calvin.pk}/",
            {
                "pk": calvin.pk,
                "first_name": calvin.first_name,
                "last_name": calvin.last_name,
                "do_not_reply": calvin.do_not_reply,
                "notes": "hi there",
            },
        )
        assert r.status_code == 400
        assert "You do not have permission to change the notes field." in r.json()["errors"]["__all__"]
        calvin.refresh_from_db()
        assert not (calvin.notes == "hi there")

    def test_notes_permissions_with_perm(self, recipients, users):
        calvin = recipients["calvin"]
        # check good post:
        prof = users["notstaff2"].profile
        prof.can_see_contact_notes = True
        prof.save()
        r = users["c_in"].post(
            f"/api/v2/recipients/{calvin.pk}/",
            {
                "pk": calvin.pk,
                "first_name": calvin.first_name,
                "last_name": calvin.last_name,
                "do_not_reply": calvin.do_not_reply,
                "notes": "something something",
            },
        )
        assert r.status_code == 200
        calvin.refresh_from_db()
        assert calvin.notes == "something something"
