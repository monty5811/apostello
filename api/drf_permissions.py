from rest_framework import permissions


class CanSeeGroups(permissions.BasePermission):
    """Check if a user should see Groups."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.profile.can_see_groups


class CanSeeContactNames(permissions.BasePermission):
    """Check if a user should see names of Contacts."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.profile.can_see_contact_names


class CanSeeKeywords(permissions.BasePermission):
    """Check if a user should have access to keywords."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.profile.can_see_keywords


class CanSeeOutgoing(permissions.BasePermission):
    """Check if a user should have access to outgoing log."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.profile.can_see_outgoing


class CanSeeIncoming(permissions.BasePermission):
    """Check if a user should have access to incoming log."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.profile.can_see_incoming


class CanSeeKeyword(permissions.BasePermission):
    """Check if a user should have access to a single keyword."""

    def has_object_permission(self, request, view, obj):
        """Check permission."""
        if not obj.is_locked:
            return True

        return obj.can_user_access(request.user)


class CanImport(permissions.BasePermission):
    """Check if a user can import."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.is_staff or request.user.profile.can_import


class IsStaff(permissions.BasePermission):
    """Check if a user has staff privileges."""

    def has_permission(self, request, view):
        """Check permission."""
        return request.user.is_staff or request.user.is_superuser
