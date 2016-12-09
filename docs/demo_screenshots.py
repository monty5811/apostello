#!/usr/bin/env python
import os
from time import sleep

from selenium import webdriver

DEMO_URL = "https://apostello-demo.herokuapp.com"
PAGES = [
    (
        '/accounts/signup',
        'Signup',
    ),
    (
        '/accounts/login',
        'Login',
    ),
    (
        '/accounts/logout',
        'Logout',
    ),
    (
        '/send/adhoc/',
        'SendtoIndividuals',
    ),
    (
        '/send/group/',
        'SendtoGroup',
    ),
    (
        '/recipient/all/',
        'Recipients',
    ),
    (
        '/recipient/edit/1/',
        'RecipientEdit',
    ),
    (
        '/keyword/all/',
        'Keywords',
    ),
    (
        '/keyword/edit/1/',
        'KeywordEdit',
    ),
    (
        '/keyword/responses/1/',
        'KeywordResponses',
    ),
    (
        '/incoming/',
        'IncomingLog',
    ),
    (
        '/incoming/wall/',
        'IncomingWall',
    ),
    (
        '/outgoing/',
        'OutgoingLog',
    ),
    (
        '/elvanto/import',
        'ElvantoSync',
    ),
    (
        '/',
        'Home',
    ),
]


def setup_driver():
    d = webdriver.Firefox()
    d.set_window_size(1200, 800)

    # wake up demo site:
    print('Waking up demo dyno...')
    d.get(DEMO_URL)
    sleep(5)
    return d


def login(d):
    email_box = d.find_elements_by_name('login')[0]
    email_box.send_keys('test@example.com')
    password_box = d.find_elements_by_name('password')[0]
    password_box.send_keys('apostello')
    login_button = d.find_elements_by_xpath('/html/body/div/div/form/button')[0
                                                                              ]
    login_button.click()


def grab_page(d, uri, desc):
    print('Opening {0}'.format(uri))
    d.get(DEMO_URL + uri)
    sleep(5)

    with open('screenshots/{0}.png'.format(desc), 'wb') as f:
        f.write(d.get_screenshot_as_png())

    if uri == '/accounts/login':
        login(d)


if __name__ == '__main__':
    try:
        os.mkdir('screenshots')
    except OSError:
        pass

    d = setup_driver()  # rewrite as context manager
    for page in PAGES:
        grab_page(d, page[0], page[1])

    d.quit()
