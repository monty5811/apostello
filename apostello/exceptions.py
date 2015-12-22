

class ApostelloException(Exception):
    """apostello base exception class."""
    pass


class NoKeywordMatchException(ApostelloException):
    """SMS matches no keywords."""
    pass


class ArchivedItemException(ApostelloException):
    """Item already exists in the archive."""
    pass


class ElvantoException(ApostelloException):
    """Elvanto API issue."""
    pass


class NotValidPhoneNumber(ApostelloException):
    """Not a valid phone number."""
    pass
