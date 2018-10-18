class ApostelloException(Exception):
    """apostello base exception class."""

    pass


class NoKeywordMatchException(ApostelloException):
    """SMS matches no keywords."""

    pass
