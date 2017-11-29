from rest_framework import status
from rest_framework.response import Response


def handle_form(view, request, user=None):
    """
    Handle post requests in API by using django forms framework.

    The form is populated with the posted data and any errors are returned as
    JSON for the front end to display.
    """
    try:
        # try and get an existing object, if it exists:
        form_kwargs = {
            'instance': view.model_class.objects.get(pk=request.data['pk']),
        }
    except KeyError:
        # object, does not exist, we must be creating one:
        form_kwargs = {}

    if user is not None:
        form_kwargs['user'] = user

    form = view.form_class(request.data, **form_kwargs)
    if form.is_valid():
        form.full_clean()
        form.save()
        msg = {
            'type_': 'info',
            'text': 'Your change has been saved!',
        }
        return Response(
            {
                'messages': [msg],
                'errors': {},
            }, status=status.HTTP_200_OK
        )
    else:
        return Response(
            {
                'messages': [],
                'errors': form.errors,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )
