#!/usr/bin/env python
import os
import sys

import pip
from pip.req import parse_requirements
from setuptools import find_packages, setup

with open('VERSION', 'r') as f:
    version = f.read().strip()

install_reqs = parse_requirements(
    'requirements.txt', session=pip.download.PipSession()
)
reqs = [str(ir.req) for ir in install_reqs]

description = 'sms for your church'

setup(
    name='apostello',
    version=version,
    description=description,
    long_description=description,
    author='Dean Montgomery',
    author_email='montgomery.dean97@gmail.com',
    url='https://github.com/monty5811/apostello',
    packages=find_packages(exclude=['tests*']),
    install_requires=reqs,
    license='MIT',
    zip_safe=False,
    include_package_data=True,
    classifiers=["Private :: Do Not Upload"],
    keywords=('Python, twilio, sms, church, django, '),
)
