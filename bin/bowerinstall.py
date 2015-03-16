#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import sys
import os
import os.path
from subprocess import Popen, PIPE


#----------------------------------------------------------------------------//
def shellex(*args, **kw):
    """ Execute shell command and return its output """
    if 'quiet' in kw and kw['quiet'] is True:
        proc = Popen(args, stdout=PIPE, stderr=PIPE, stdin=PIPE)
    else:
        proc = Popen(
            args, stdout=sys.stdout, stderr=sys.stderr, stdin=sys.stdin
        )
    code = proc.wait()
    return code


#----------------------------------------------------------------------------//
def mkcmdline(cmdline = None):
    if cmdline is None:
        from argparse import ArgumentParser
        cmdline = ArgumentParser()

    cmdline.add_argument(
        '-v', '--verbose',
        dest='verbose', action='count',
        help="Be more verbose"
    )
    return cmdline


#----------------------------------------------------------------------------//
def install_bower_deps(verbose):
    import json
    with open('bower.json') as fp:
        pkg = json.loads(fp.read())

    deps = []
    if 'dependencies' in pkg:
        deps += sorted(pkg['dependencies'].items(), key=lambda x: x[0])
    if 'devDependencies' in pkg:
        deps += sorted(pkg['devDependencies'].items(), key=lambda x: x[0])

    for name, version in deps:
        ret = 1
        while ret != 0:
            print("-- \033[1mInstalling\033[0m \033[32m{}#{}\033[0m".format(
                name, version
            ))

            if '://' in version:
                apppkg = version
            else:
                apppkg = '{}#{}'.format(name, version)

            args = ['-p', '-F', apppkg]
            ret  = shellex(
                'bower', 'install', *args,
                quiet = not cmdln.verbose
            )
            if ret != 0:
                print('   \033[33mInstall failed, retrying..\033[0m')


###############################################################################
if __name__ == '__main__':
    cmdln = mkcmdline().parse_args()
    if cmdln.verbose >= 2:
        print("-- Working directory: \033[1m{}\033[0m".format(os.getcwd()))

    install_bower_deps(cmdln.verbose)
