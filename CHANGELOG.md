# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
### Changed
- When a contact is saved, their name is now backdated to any SMS they have sent us
- Allow disabling of "no keyword matched" warning
- Better logging output
### Deprecated
### Removed
### Fixed
- Create schduled tasks on Heroku
- Create schduled tasks on Docker
- Typo in default responses and help text
### Security

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
