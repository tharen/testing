import os
import sys
import shutil
import re
import subprocess

from setuptools import setup, Extension, Command
from Cython.Build import cythonize
from Cython.Distutils import build_ext
import numpy

# NOTE: Python 2.7 C compiler for Windows
#       https://www.microsoft.com/en-us/download/details.aspx?id=44266
#       Python 3.4 requires VS 2010
#       Python 3.5 requires VS 2015

description = open('./pyfvs/README.txt').readline().strip()
long_desc = open('./pyfvs/README.txt').read().strip()

# Version integration with Git tags
# Ref: https://github.com/warner/python-ecdsa/blob/9e21c3388cc98ba90877a1e4dbc2aaf66c67d365/setup.py#L33
version_tmp = """\
# This file is automatically generated during packaging.
# The version is extracted from the current Git tag using setup.py version.

__version__ = '{version:}'
__status__ = '{status:}'
__git_tag__ = '{desc:}'
"""

version_path = 'pyfvs/_version.py'

def update_version():
    try:
        desc = subprocess.check_output(
                ['git', 'branch']
                ).decode('utf-8').split()
        branch = desc[1].strip()
        
    except:
        print('Error: git must be available in the PATH environment.')
        raise
    
    if branch=='master':
        try:
            desc = subprocess.check_output(
                    ['git', 'describe', '--tags', '--dirty']
                    ).decode('utf-8').strip()

        except:
            print('Error: git must be available in the PATH environment.')
            raise

        if desc.startswith('fatal'):
            print('Current folder is not a Git repo, skipping version update.')
            return

        m = re.match('pyfvs-v(\d+\.\d+\.\d+)-(alpha|beta)?-(.*)', desc)
        if not m:
            print('The current tag is not a version tag (pyfvs-v#.#.#): {}'.format(desc))
            return

        g = m.groups()
        version = g[0]
        if g[1] in ('alpha', 'beta'):
            status = g[1]
        else:
            status = ''
    
    else:
        fn = os.path.join(os.path.dirname(__file__), version_path)
        with open(fn, 'r') as fp:
            content = fp.read()
        
        s = re.search('__version__\s*=\s*\'([\d\.]+)\+*\'', content)
        version = s.groups()[0]
        s = re.search('__status__\s*=\s*\'(.*)\'', content)
        status = s.groups()[0]
        desc = ''
        
    version_str = version_tmp.format(**locals())

    fn = os.path.join(os.path.dirname(__file__), version_path)
    with open(fn, 'w') as fp:
        fp.write(version_str)

    print('Updated {}: {}'.format(version_path, desc))

def get_version():
    try:
        f = open(version_path)
    except EnvironmentError:
        return None
    for line in f.readlines():
        mo = re.match("__version__ = '([^']+)'", line)
        if mo:
            ver = mo.group(1)
            return ver
    return None

class Version(Command):
    description = "update {} from Git repo".format(version_path)
    user_options = []
    boolean_options = []
    def initialize_options(self):
        pass
    def finalize_options(self):
        pass
    def run(self):
        update_version()
        print('Version is now {}'.format(get_version()))

if ((os.name == 'nt') and (sys.version_info[:2] >= (3, 5))
        and (numpy.version.version <= '1.13')):
    # Monkey patch numpy for MinGW until version 1.13 is mainstream
    # This fixes building extensions with Python 3.5+ resulting in
    #       the error message `ValueError: Unknown MS Compiler version 1900
    # numpy_fix uses the patch referenced here:
    #       https://github.com/numpy/numpy/pull/8355
    root = os.path.split(__file__)[0]
    sys.path.insert(0, os.path.join(root, 'numpy_fix'))
    import misc_util, mingw32ccompiler
    sys.modules['numpy.distutils.mingw32ccompiler'] = mingw32ccompiler
    sys.modules['numpy.distutils.misc_util'] = misc_util

_is_64bit = (getattr(sys, 'maxsize', None) or getattr(sys, 'maxint')) > 2 ** 32
_is_windows = sys.platform == 'win32'

if _is_windows and _is_64bit:
    args = ['-static-libgcc', '-static-libstdc++', '-Wl,--allow-multiple-definition']
    defs = [('MS_WIN64', None), ]
else:
    args = []
    defs = []

# Collect all Cython source files as a list of extensions
extensions = cythonize([
        Extension("pyfvs.*"
            , sources=["pyfvs/*.pyx"]
            , include_dirs=[numpy.get_include()]
            , extra_compile_args=args
            , extra_link_args=args
            , define_macros=defs
            )])

setup(
    name='pyfvs'
    , version=get_version()
    , description=description
    , long_description=long_desc
    , url='https://github.com/tharen/PyFVS'
    , author="Tod Haren"
    , author_email="tod.haren@gmail.com"
    , setup_requires=['cython', 'numpy>=1.11', 'pytest-runner']
    , tests_require=['pytest']
    , install_requires=['numpy>=1.11', 'pandas']
    , ext_modules=extensions
    , packages=['pyfvs', 'pyfvs.keywords']
    , package_data={
            '':['*.pyd', '*.cfg', '*.so', 'README.*', 'version']
            , 'pyfvs':['docs/*', 'examples/*', 'test/*.py', 'test/rmrs/*']
            }
    # , include_package_data=True # package the files listed in MANIFEST.in
    , entry_points={
            'console_scripts': ['pyfvs=pyfvs.__main__:main']
        }
    , classifiers=[
            'Development Status :: 3 - Alpha'
            , 'Environment :: Console'
            , 'Intended Audience :: Developers'
            , 'Intended Audience :: End Users/Desktop'
            , 'Intended Audience :: Science/Research'
            , 'Natural Language :: English'
            , 'Programming Language :: Python'
            , 'Programming Language :: Fortran'
            ]
    , keywords=''
    , cmdclass={"version": Version, }
    )
