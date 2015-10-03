from rest_framework import permissions


class CanSeeGroups(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.profile.can_see_groups


class CanSeeContactNames(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.profile.can_see_contact_names


class CanSeeKeywords(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.profile.can_see_keywords


class CanSeeOutgoing(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.profile.can_see_outgoing


class CanSeeIncoming(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.profile.can_see_incoming


class CanSeeContactNums(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.profile.can_see_contact_nums


class CanSeeKeyword(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if not obj.is_locked:
            return True

        return obj.can_user_access(request.user)
