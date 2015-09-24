#!/usr/bin/env python

import argparse
import re
import sys
import os
import shutil
import subprocess
import glob
import shared

# Init
logging = shared.logging
info = logging.info

# Config

git_dir = os.path.join(shared.orcid_home, 'git')
orcid_source_dir = os.path.join(git_dir, 'ORCID-Source')
webapps_dir = os.path.join(shared.orcid_home, 'webapps')
fonts_src_dir = os.path.join(shared.orcid_home, 'git', 'ORCID-Fonts-Dot-Com')
fonts_deploy_dir = os.path.join(shared.tomcat_home, 'webapps', 'orcid-web', 'static', 'ORCID-Fonts-Dot-Com')

deployment_types = {
'orcid-web': { 'apps': ['orcid-web'], 'deploy_fonts': True },
'orcid-pub-web': { 'apps': ['orcid-pub-web'], 'deploy_fonts': False },
'orcid-api-web': { 'apps': ['orcid-api-web'], 'deploy_fonts': False },
'orcid-internal-api' : {'apps': ['orcid-internal-api'], 'deploy_fonts': False},
'web': { 'apps': ['orcid-web', 'orcid-pub-web', 'orcid-api-web', 'orcid-internal-api'], 'deploy_fonts': True },
'web-and-solr': { 'apps': ['orcid-web', 'orcid-pub-web', 'orcid-api-web', 'orcid-solr-web', 'orcid-internal-api'], 'deploy_fonts': True },
'scheduler': { 'apps': ['orcid-scheduler-web'], 'deploy_fonts': False },
'solr': { 'apps': ['orcid-solr-web'], 'deploy_fonts': False },
'all': { 'apps': ['orcid-web', 'orcid-pub-web', 'orcid-api-web', 'orcid-internal-api', 'orcid-solr-web', 'orcid-scheduler-web'], 'deploy_fonts': True }
}

# Function definitions

def release_number():
    branch = args.release
    if(args.current):
        os.chdir(orcid_source_dir)
        branch = subprocess.check_output('git symbolic-ref -q --short HEAD || git describe --tags --exact-match', shell=True).strip()
    release_number = re.sub(r'^release-', '', branch)
    if not(release_number):
        logging.error('Unable to determine release number from branch: %s', branch)
        exit(1)
    return release_number

def app_version_needed(app):
    app_version = app + '-' + release_number
    return not(os.path.exists(os.path.join(webapps_dir, app_version)))
    
def app_cache_dir(app):
    return os.path.join(webapps_dir, app + '-' + release_number)

def build_and_install_apps():
    clean_previous_builds()
    apps_to_build = filter(app_version_needed, deployment_types[args.type]['apps'])
    if apps_to_build:
        info('Need to build %s', apps_to_build)
        build()
        for app in apps_to_build:
            dir_listing = sorted(glob.glob(os.path.join(orcid_source_dir, app, 'target', app) + '*'))
            app_dir = dir_listing[0]
            shutil.copytree(app_dir, app_cache_dir(app))
    else:
        info('No new apps to install')
        
def clean_previous_builds():
    if(args.build):
        for app in deployment_types[args.type]['apps']:
            dir = app_cache_dir(app)
            if(os.path.isdir(dir)):
                shutil.rmtree(dir)

def build():
    os.chdir(orcid_source_dir)
    if(args.current):
	    logging.info('About to build ORCID from version currently checked out in %s', orcid_source_dir)
	    subprocess.call('git status'.split())
    else:
        logging.info('About to build ORCID from tag %s', args.release)
        subprocess.check_call('git fetch --tags'.split())
        subprocess.check_call(['git', 'checkout', args.release])
        
    if(args.current):
        subprocess.check_call('mvn install -Dmaven.test.skip=true'.split())
    else:
        subprocess.check_call('mvn clean install -Dmaven.test.skip=true'.split())
    
def deploy_fonts():
    if deployment_types[args.type]['deploy_fonts']:
        if not(os.path.exists(fonts_deploy_dir)):
            info('Copying fonts to webapp dir...')
            shutil.copytree(os.path.join(fonts_src_dir), fonts_deploy_dir)
        
def link_apps():
    # Unlink all apps first
    for app in deployment_types['all']['apps']:
        app_path = os.path.join(shared.tomcat_home, 'webapps', app)
        if os.path.islink(app_path): os.remove(app_path)
        elif os.path.isdir(app_path): os.rmdir(app_path)
    # Link apps for the given deployment type
    for app in deployment_types[args.type]['apps']:
        info('Linking %s to tomcat webapps dir...', app)
        app_path = os.path.join(shared.tomcat_home, 'webapps', app)
        os.symlink(os.path.join(webapps_dir, app + '-' + release_number), app_path)
    # Make empty dir for non-deployed apps, to stop tomcat complaining
    for app in deployment_types['all']['apps']:
    	app_path =  os.path.join(shared.tomcat_home, 'webapps', app)
    	if not(os.path.lexists(app_path)): os.mkdir(app_path)


# Start of script

parser = argparse.ArgumentParser()
parser.add_argument('type', help='the deployment type', choices=sorted(deployment_types.keys()))
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--current', help='deploy the version currently checked out in ~orcid_tomcat/git', action='store_true')
group.add_argument('--release', help='the tag of the ORCID release in git')
parser.add_argument('--no-tomcat', help='do not start and stop tomcat', dest='tomcat', action='store_false', default=True)
parser.add_argument('--no-build', help='use already built version in ~orcid_tomcat/webapps', dest='build', action='store_false', default=True)
args = parser.parse_args()

info('Starting ORCID deployment')
info('Deployment type = %s', args.type)
release_number = release_number()
logging.info('Release number = %s', release_number)
logging.info('Git directory = %s', git_dir)

build_and_install_apps()
if args.tomcat:
    shared.stop_tomcat()
    shared.clean_tomcat()
link_apps()
deploy_fonts()
if args.tomcat:
    shared.start_tomcat()

