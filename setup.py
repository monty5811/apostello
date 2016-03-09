#!/usr/bin/env python

import os
import sys

from pip.req import parse_requirements

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

version = "1.0.0"

if sys.argv[-1] == 'tag':
    os.system("git tag -a %s -m 'version %s'" % (version, version))
    os.system("git push --tags")
    sys.exit()

install_reqs = parse_requirements('requirements_test.txt')
reqs = [str(ir.req) for ir in install_reqs]

description = 'sms communication for churches, built with django'

setup(
    name='apostello',
    version=version,
    description=description,
    long_description=description,
    author='Dean Montgomery',
    author_email='montgomery.dean97@gmail.com',
    url='https://github.com/monty5811/apostello',
    packages=[],
    install_requires=install_reqs,
    license='BSD',
    zip_safe=False,
    classifiers=[
        'Framework :: Django :: 1.9',
        'Natural Language :: English',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
    keywords=(
        'Python, twilio, sms, church, django, '
    ),
)
