#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import os
from setuptools import setup

setup(
    name = 'microblog',
    version='0.1.1',
    license='GNU General Public License v3',
    author='Dawei Zhang',
    author_email='dawei.zhang@weclouddata.com',
    description='Microblog application for Flask',
    packages=['app'],
    platforms='any',
    install_requires=[
        'flask',
    ],
)