from rest_framework import status
from rest_framework.response import Response


def handle_form(view, request):
    try:
        instance = view.model_class.objects.get(pk=request.data['pk'])
        form = view.form_class(request.data, instance=instance)
    except KeyError:
        form = view.form_class(request.data)
    if form.is_valid():
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
