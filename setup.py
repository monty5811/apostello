#!/usr/bin/env python

import os
import sys
import pip

from pip.req import parse_requirements

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

version = "1.9.0"

install_reqs = parse_requirements(
    'requirements_test.txt',
    session=pip.download.PipSession()
)
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
    install_requires=reqs,
    license='MIT',
    zip_safe=False,
    classifiers=[
        'Framework :: Django :: 1.9',
        'Natural Language :: English',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
    keywords=('Python, twilio, sms, church, django, '),
)
