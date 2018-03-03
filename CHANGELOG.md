# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased]

## Changed

 - Opbeat removed in favour of rollbar. Opbeat is shutting down in May and moving to Elastic APM. This release replaces opbeat with rollbar instead, partly due to better django-q support

## Added

 - Add configuration to allow limiting number of items sent to client
 - Add Twilio Message Status to Outgoing log

## Removed

 - Inter-tab sync removed to simplify code, no real downsides

## [v2.7.1]

### Fixed

 - Update deadsnakes ppa to fix ansible deploys

## [v2.7.0]

### Added

 - Add a new custom response for keywords: option to have a different reply to contacts that we have not seen before
 - Add a `notes` field to contacts
 - Add ansible support for deploying to Ubuntu 16.04
 - Clear django cache on new ansible deploys

### Changed

 - Non-alphanumeric characters will be ignored at the start of a message when trying to match a keyword. E.g. `"keyword"` will now match `keyword`
 - The contact edit page can now be viewed by any user with the `can_see_contact_names` permission - number and notes fields are only visible if the user has permission
 - Allow "name reply" to be blank so that no `name` message is sent to unknown contacts

### Fixed

 - Prevent users without correct permissions from changing phone numbers with the API

## [v2.6.3]

### Fixed

 - Fix formatting bug in email digest subject field

## [v2.6.2]

**Before you upgrade**: if you want your Twilio and email settings to be copied into the database when you upgrade, you must upgrade to `2.6.0`, check the deploy and then upgrade to `2.6.2`.

### Changed

 - Remove email and Twilio credentials from ansible deploy

## [v2.6.1]

### Fixed

 - Prevent `http://` from being added to email host field

## [v2.6.0]

**Note** - this release moves the Twilio and email sending configuration into the database to make management and intial setup easier.
Your existing settings will be imported when you run a migration `./manage.py migrate` after this upgrade.

*You must update to 2.6.0 and run the migrate command before attempting to update to the next release.*

### Changed

 - Move the Twilio and Email settings into databse - no longer use enviroment variables. Smoother and quicker setup process.
 - Nicer help messages on forms

### Added

 - Small animation to make the menu button more obvious
 - Don't refresh data needlessly in the background

### Fixed

 - Bug in User Profile form that saved wrong permissions under some circumstances
 - Styling issue where group members were not visible
 - Styling bug on live updating wall

## [v2.5.4]

 - Fix bug that prevented sending of cloud notifications
 - Misc other bug fixes
 - Misc usability tweaks

## [v2.5.3]

### Fixed

 - Fix csrftoken missing on first run setup

## [v2.5.2]

### Fixed

 - Fix bug in first run page

## [v2.5.1]

### Fixed

 - Fix broken service worker

## [v2.5.0]

### Changed

 - Visual refresh (and much smaller CSS assets now required)

### Fixed

 - Rolling SMS expiration setting is no longer "required"
 - Bug when checking if a user could access a keyword

## [v2.4.1]

### Added

 - Web Push support: get notified of new messages in your browser or on your phone

## [v2.3.0]

### Added

 - Add (optional) max number of days to keep messages
 - Add sections to forms to aid user

### Changed

 - Remove notifications on page change to stop them piling up

## [v2.2.0]

### Added

 - Optional expiration date for SMS
 - Expiremental onebody integration - see [b72101a](https://github.com/monty5811/apostello/commit/b72101a13dc4004fa644cefa8de73a31fc1b7278) for details

## [v2.1.0]

### Added

 - Title to tell you what page you are on
 - Loading status indicator in top menu

### Changed

 - Edit forms eagerly load current item instead of paging through all results

### Fixed

 - Edit forms show a 404 if an item does not exist
 - Don't redirect a user to the scheduled queue if they can't view it
 - Don't try to link to "No Match" keyword


## [v2.0.0]

**Upgrade to python 3.6 - ansible and Heroku deploys now use python 3.6**

### Changed

 - Improve nightly email - table of responses and relevant links back to apostello
 - Remove modal from send forms in favour of cleaner interface

### Added

 - Pagination on tables
 - A few performance optimisations
 - Logout button added to not approved page

## [v1.18.0]

### Changed

 - Hide messages if a user cannot access the matched keyword
 - Disable archive button if user cannot use it
 - Simplify API

### Fixed

 - Keyword permissions
 - Misc fixes on front end

## [v1.17.0]

### Added

 - Offline page

### Changed

 - Make most of site a "Single Page Application" - faster page switches, smarter data caching, inter-tab communication

### Fixed

 - Error when fetching logs from Twilio

## [v1.16.3]

### Fixed

 - Fix incorrect sorting by timestamp

## [v1.16.2]

### Fixed

 - Fix fetching logs from Twilio

## [v1.16.1]

### Fixed

- Sort tables properly

## [v1.16.0]

### Added
- Support for brackets in group composer e.g. `(1|2) - (3|4)` now works

### Changed
- Move wrench menu out of top menu and into a "floating action button"
- Replace react with elm on frontend


*Note* v1.15.0 failed to deploy and has been removed.

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
