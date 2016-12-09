#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import inspect
import sys
import os

from recommonmark.parser import CommonMarkParser

# -- General configuration ------------------------------------------------
# needs_sphinx = '1.0'
extensions = ['sphinx.ext.autodoc', ]
templates_path = ['_templates']
source_parsers = {'.md': CommonMarkParser}
source_suffix = ['.rst', '.md']
# source_encoding = 'utf-8-sig'
master_doc = 'index'

# General information about the project.
project = 'apostello'
copyright = '2015, Dean Montgomery'
author = 'Dean Montgomery'

with open('../VERSION', 'r') as f:
    version = f.read().strip()
# The full version, including alpha/beta/rc tags.
release = '0.1'
language = None
exclude_patterns = [
    '_build',
    'venv',
]
# default_role = None
# add_function_parentheses = True
# add_module_names = True
# show_authors = False
pygments_style = 'sphinx'
# modindex_common_prefix = []
# keep_warnings = False
todo_include_todos = False

# -- Options for HTML output ----------------------------------------------

html_theme = 'sphinx_rtd_theme'
# html_theme_options = {}
# html_theme_path = []
# html_title = None
# html_short_title = None
html_logo = '../apostello/static/images/favicons/android-chrome-48x48.png'
html_favicon = '../apostello/static/images/favicons/favicon.ico'
html_static_path = ['_static']
# html_extra_path = []
# html_last_updated_fmt = '%b %d, %Y'
# html_use_smartypants = True
# html_sidebars = {}
# html_additional_pages = {}
# html_domain_indices = True
# html_use_index = True
# html_split_index = False
# html_show_sourcelink = True
# html_show_sphinx = True
# html_show_copyright = True
# html_use_opensearch = ''
# html_file_suffix = None
# html_search_language = 'en'
# html_search_options = {'type': 'default'}
# html_search_scorer = 'scorer.js'
htmlhelp_basename = 'apostellodoc'

# -- Options for LaTeX output ---------------------------------------------

latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '10pt',
    'preamble': '',
    'figure_align': 'htbp',
}
latex_documents = [
    (
        master_doc, 'apostello.tex', 'apostello Documentation',
        'Dean Montgomery', 'manual'
    ),
]
# latex_logo = None
# latex_use_parts = False
# latex_show_pagerefs = False
# latex_show_urls = False
# latex_appendices = []
# latex_domain_indices = True

# -- Options for manual page output ---------------------------------------

man_pages = [(master_doc, 'apostello', 'apostello Documentation', [author], 1)]
# man_show_urls = False

# -- Options for Texinfo output -------------------------------------------

texinfo_documents = [
    (
        master_doc, 'apostello', 'apostello Documentation', author,
        'apostello', 'One line description of project.', 'Miscellaneous'
    ),
]

# texinfo_appendices = []
# texinfo_domain_indices = True
# texinfo_show_urls = 'footnote'
# texinfo_no_detailmenu = False
