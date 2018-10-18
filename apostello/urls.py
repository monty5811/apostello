from allauth.account.views import PasswordChangeView
from django.conf import settings
from django.conf.urls import include, url
from django.urls import path
from django.contrib import admin
from django.views.generic.base import TemplateView
from rest_framework.documentation import include_docs_urls

from apostello import views as v

admin.autodiscover()

urlpatterns = [
    url(r"^sw(.*.js)$", v.sw_js, name="sw_js"),
    url(r"^manifest.json", TemplateView.as_view(template_name="apostello/manifest.json")),
    url(r"not_approved/$", v.NotApprovedView.as_view(), name="not_approved"),
    url(r"^keyword/responses/csv/(?P<keyword>[\d|\w]+)/$", v.keyword_csv, name="keyword_csv"),
]

# twilio api url
urlpatterns += [url(r"^sms/$", v.sms)]

# auth and admin
urlpatterns += [
    path(r"admin/", admin.site.urls),
    # over ride success url:
    url(r"^accounts/password/change/$", PasswordChangeView.as_view(success_url="/"), name="account_change_password"),
    url(r"^accounts/", include("allauth.urls")),
]

# debug toolbar
if settings.DEBUG:
    import debug_toolbar

    urlpatterns += [url(r"^__debug__/", include(debug_toolbar.urls))]

# apps etc
urlpatterns += [
    url(r"^config/", include("site_config.urls", namespace="site_config")),
    url(r"^graphs/", include("graphs.urls", namespace="graphs")),
    url(r"^api/", include("api.urls", namespace="api")),
    url(r"^api-docs/", include_docs_urls(title="apostello API", description="apostello API docs")),
    url(r"^offline/$", TemplateView.as_view(template_name="apostello/offline.html"), name="offline"),
    url(r"^.*/$", v.SimpleView.as_view(template_name="apostello/spa.html", required_perms=[]), name="spa"),
    url(r"^$", v.SimpleView.as_view(template_name="apostello/spa.html", required_perms=[]), name="spa_"),
]
