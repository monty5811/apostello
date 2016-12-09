# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Support for brackets in group composer e.g. `(1|2) - (3|4)` now works

### Changed
- Move wrench menu out of top menu and into a "floating action button"

## [v1.14.0]
### Added
- Default prefix for phone numbers (set at `/config/site/`) that prefills the new contact form
- New tool to compose an adhoc list of recipients from existing groups. See issue #53.

### Changed
- Improve handling of scheduled messages (**note**, already queued messages will be sent after upgrading, but their status can only be view in the admin panel, you may want have an empty message queue before upgrading just in case)
- Update dependencies

### Fixed
- Fix rounding error on sending pages
- Redirect to correct page after login

## [v1.13.1]
### Fixed
- Better handle messages beginning with `name`
- Pin ansible version so install does not fail

## [v1.13.0]
### Added
- Can now automatically add new contacts to a group or groups (choose groups on Site Config page)

### Changed
- Nicer interface for managing groups (especially large ones)
- Remove frontend data caching
- Improve error messages when ajax call fails

## Fixed
- Do not use [E] in Elvanto imported groups - use (E)
- Fix Twilio complaining when we have no reply to send back

## [v1.12.1]
- Pin Django version

## [v1.12.0]
### Added
- Allow prefilling of sending forms using URL params

### Changed
- Move to Django 1.10
- Serialize phone numbers in api if user should see them
- Accept multiple recipients as url params in send SMS form

### Fixed
- Fix bug in js path middleware
- Other misc tweaks and clean ups

## [v1.11.0]
### Added
- View archived contacts, groups and keywords (only staff can view)

### Changed
- Better performance when loading tables by using browser caching
- Other misc refactorings and internal clean ups

## [v1.10.0]

**Release requires database migration to be run**

### Added
- Reply to button in incoming logs so you can easily reply to a contact
- API documented and Key access enabled to facilitate read only access

### Changed
- Dropdowns now do full-text search (searching by surname will now work)
- Content box size now a function of SMS character limit
- SMS character limit now more forgiving when `%name%` not used in a message

## [1.9.0]
### Added
- Can now link groups to a keyword. When a contact send a message to a keyword, they will be added to the selected groups.
- Allow disabling of "no keyword matched" warning

### Changed
- When a contact is saved, their name is now backdated to any SMS they have sent us
- Better logging output
- Pull forms app from pypi instead of github

### Fixed
- Create scheduled tasks on Heroku
- Create scheduled tasks on Docker
- Typo in default responses and help text

## [1.8.1] - 2016-05-28
### Fixed
- CSRF bug in first run page

## [1.8.0] - 2016-05-27
### Added
- Disable replies for a keyword
- New first run page

### Fixed
- Issues with Docker set up

## [1.7.3] - 2016-05-18
### Fixed
- Error in Heroku deploy
- Typo in email env var

## [1.7.2] - 2016-05-16
### Added
- Docker deploy option

### Changed
- Nicer JS alerts

### Fixed
- Account emails now respect settings in database
- Bug in wall curation page

## [1.7.1] - 2016-05-01
### Fixed
- Scheduled SMS not displaying correctly

## [1.7.0] - 2016-05-01
### Added
- Customise "not approved" page
- View and cancel scheduled messages
- Block replies to individual contacts

### Changed
- Change email settings on Site Configuration page

## [1.6.0] - 2016-04-16
### Changed
- New logo
- Show email addresses in dropdowns instead of user names

### Fixed
- Remove button showing on new item pages
- Google button showing with no SocialApp set up

## [1.5.0] - 2016-04-03
## Changed
- Replace celery with django-q

## [1.4.3] - 2016-03-31
### Added
- Add all contacts to group form

### Changed
- Add titles to pages
- Move links around on Keywords table

## [1.4.2] - 2016-03-27
### Fixed
- Emails not sending

## [1.4.1] - 2016-03-27
### Fixed
- Email not being sent on sign up

## [1.4.0] - 2016-03-25
### Added
- Edit user profile form
- Per SMS cost limit for each user

### Changed
- Ansible: add gzip, far future headers and improve SSL
- Slim down frontend assets

### Fixed
- Login errors not displaying

## [1.3.1] - 2016-03-17
### Fixed
- Elvanto import

## [1.3.0] - 2016-03-16
### Added
- Add new "can archive" permission

### Changed
- Ansible deploy: redirect to https

### Fixed
- Elvanto import permissions

## [1.2.0] - 2016-03-12
### Changed
- Handle Twilio pricing being different in different countries

## [1.1.0] - 2016-03-11
### Changed
- Keywords table now reflects active response

## [1.0.0] - 2016-03-03
Initial release.
