#!/usr/bin/env python
import os
import sys

from apostello.loaddotenv import loaddotenv

if os.environ.get('DYNO_RAM') is None:
    loaddotenv()

if __name__ == "__main__":
    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)
