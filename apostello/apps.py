from django.apps import AppConfig


class ApostelloConfig(AppConfig):
    name = 'apostello'
    verbose_name = 'apostello'

    def ready(self):
        import apostello.signals  # pragma: no flakes
