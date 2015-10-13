import os, time, argparse, shutil, logging
from os.path import exists
from os.path import expanduser
from logging.handlers import TimedRotatingFileHandler

home = expanduser("~")
logs_directory = home + '/logs/clean_old_apps/'
log_file = 'clean_old_apps.log'

if not os.path.exists(logs_directory):
    os.makedirs(logs_directory)

logger = logging.getLogger('clean_old_apps')
formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
fileHandler = TimedRotatingFileHandler(logs_directory + log_file,
                                       when='midnight',
                                       interval=1,
                                       backupCount=30)
fileHandler.setFormatter(formatter)
logger.setLevel(logging.DEBUG)
logger.addHandler(fileHandler)

parser = argparse.ArgumentParser()
# Required parameters
parser.add_argument('-p', '--path', help='The path where the orcid apps are', required=False, default = '/home/orcid_tomcat/webapps/')
parser.add_argument('-k', '--releases_to_keep', help='How many releases do you want to keep, default will be 3', required=False, default = 3)
parser.add_argument('-c', '--clear_older_than', help='Remove the folders older than -c days, default will be 90 and a number lower than that might be risky',required=False, default = 90)
args = parser.parse_args()

# -------------------------
# Validate arguments
# -------------------------
if(not exists(args.path)):
	logger.error('Folder not found: %s', args.path)
	raise Exception('Folder not found: ' + args.path)
try:  
	int(args.clear_older_than)
	int(args.releases_to_keep)	
except ValueError, e:
	logger.error('One of the parameters is not an integger:  %s %s ', args.clear_older_than, args.releases_to_keep)
	raise Exception('One of the parameters is not an integger: ' + args.clear_older_than + ' ' + args.releases_to_keep)

if int(args.releases_to_keep) < 2:
	raise Exception('You should keep at least two releases on the server, in case you need a rollback: -k=' + args.releases_to_keep)

# -------------------------
# Init data
# -------------------------	
RELEASES_TO_KEEP = args.releases_to_keep
CLEAR_OLDER_THAN = time.time() - (int(args.clear_older_than) * 24 * 60 * 60)

path = args.path
dirs = os.listdir( path )

orcid_api_web = {}
orcid_pub_web = {}
orcid_scheduler_web = {}
orcid_solr_web = {}
orcid_web = {}

# -------------------------
# Look for the apps we will clear and order them by app type
# -------------------------	
# Order the apps by type and modification time
for dir in dirs:
	dir_path = path + dir
	dir_mtime = str(os.stat(dir_path).st_mtime)	
	if dir.startswith( 'orcid-api-web' ):
		orcid_api_web[dir_mtime] = dir_path
	elif dir.startswith( 'orcid-pub-web' ):
		orcid_pub_web[dir_mtime] = dir_path
	elif dir.startswith( 'orcid-scheduler-web' ):
		orcid_scheduler_web[dir_mtime] = dir_path
	elif dir.startswith( 'orcid-solr-web' ):
		orcid_solr_web[dir_mtime] = dir_path
	elif dir.startswith( 'orcid-web' ):
		orcid_web[dir_mtime] = dir_path

# -------------------------
# Lets clean apps one type at a time		
# -------------------------	
# Lets clean orcid_api_web
logger.info('Cleaning releases of orcid_api_web')
if len(orcid_api_web) > RELEASES_TO_KEEP:
	# Get the list of keys	
	orcid_api_web_keys = list(reversed(sorted(orcid_api_web.keys())))
	for i in range(0, RELEASES_TO_KEEP):
		dir_mtime = float(orcid_api_web_keys[i])
		logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_api_web[orcid_api_web_keys[i]], time.ctime(dir_mtime)) 
	# Keep RELEASES_TO_KEEP and delete the rest
	for i in range(RELEASES_TO_KEEP, len(orcid_api_web_keys) - 1):
		dir_mtime = float(orcid_api_web_keys[i])		
		if(dir_mtime < CLEAR_OLDER_THAN):
			logger.info('Release will be deleted: %s dir: %s modified on: %s', str(i), orcid_api_web[orcid_api_web_keys[i]], time.ctime(dir_mtime))
			shutil.rmtree(orcid_api_web[orcid_api_web_keys[i]])
		else:
			logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_api_web[orcid_api_web_keys[i]], time.ctime(dir_mtime))

# Lets clean orcid_pub_web
logger.info('Cleaning releases of orcid_pub_web')
if len(orcid_pub_web) > RELEASES_TO_KEEP:			
	# Get the list of keys	
	orcid_pub_web_keys = list(reversed(sorted(orcid_pub_web.keys())))
	for i in range(0, RELEASES_TO_KEEP):
		dir_mtime = float(orcid_pub_web_keys[i])
		logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_pub_web[orcid_pub_web_keys[i]], time.ctime(dir_mtime)) 
	# Keep RELEASES_TO_KEEP and delete the rest
	for i in range(RELEASES_TO_KEEP, len(orcid_pub_web_keys) - 1):
		dir_mtime = float(orcid_pub_web_keys[i])		
		if(dir_mtime < CLEAR_OLDER_THAN):
			logger.info('Release will be deleted: %s dir: %s modified on: %s', str(i), orcid_pub_web[orcid_pub_web_keys[i]], time.ctime(dir_mtime)) 
			shutil.rmtree(orcid_pub_web[orcid_pub_web_keys[i]])
		else:
			logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_pub_web[orcid_pub_web_keys[i]], time.ctime(dir_mtime)) 

# Lets clean orcid_scheduler_web
logger.info('Cleaning releases of orcid_scheduler_web')
if len(orcid_scheduler_web) > RELEASES_TO_KEEP:	
	# Get the list of keys	
	orcid_scheduler_web_keys = list(reversed(sorted(orcid_scheduler_web.keys())))
	for i in range(0, RELEASES_TO_KEEP):
		dir_mtime = float(orcid_scheduler_web_keys[i])
		logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_scheduler_web[orcid_scheduler_web_keys[i]], time.ctime(dir_mtime)) 
	# Keep RELEASES_TO_KEEP and delete the rest
	for i in range(RELEASES_TO_KEEP, len(orcid_scheduler_web_keys) - 1):
		dir_mtime = float(orcid_scheduler_web_keys[i])		
		if(dir_mtime < CLEAR_OLDER_THAN):
			logger.info('Release will be deleted: %s dir: %s modified on: %s', str(i), orcid_scheduler_web[orcid_scheduler_web_keys[i]], time.ctime(dir_mtime)) 
			shutil.rmtree(orcid_scheduler_web[orcid_scheduler_web_keys[i]])
		else:
			logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_scheduler_web[orcid_scheduler_web_keys[i]], time.ctime(dir_mtime)) 
	
# Lets clean orcid_solr_web
logger.info('Cleaning releases of orcid_solr_web')
if len(orcid_solr_web) > RELEASES_TO_KEEP:	
	# Get the list of keys	
	orcid_solr_web_keys = list(reversed(sorted(orcid_solr_web.keys())))
	for i in range(0, RELEASES_TO_KEEP):
		dir_mtime = float(orcid_solr_web_keys[i])
		logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_solr_web[orcid_solr_web_keys[i]], time.ctime(dir_mtime)) 
	# Keep RELEASES_TO_KEEP and delete the rest
	for i in range(RELEASES_TO_KEEP, len(orcid_solr_web_keys) - 1):
		dir_mtime = float(orcid_solr_web_keys[i])		
		if(dir_mtime < CLEAR_OLDER_THAN):
			logger.info('Release will be deleted: %s dir: %s modified on: %s', str(i), orcid_solr_web[orcid_solr_web_keys[i]], time.ctime(dir_mtime)) 
			shutil.rmtree(orcid_solr_web[orcid_solr_web_keys[i]])
		else:
			logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_solr_web[orcid_solr_web_keys[i]], time.ctime(dir_mtime)) 
	
# Lets clean orcid_web
logger.info('Cleaning releases of orcid_web')
if len(orcid_web) > RELEASES_TO_KEEP:	
	# Get the list of keys	
	orcid_web_keys = list(reversed(sorted(orcid_web.keys())))
	for i in range(0, RELEASES_TO_KEEP):
		dir_mtime = float(orcid_web_keys[i])
		logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_web[orcid_web_keys[i]], time.ctime(dir_mtime)) 
	# Keep RELEASES_TO_KEEP and delete the rest
	for i in range(RELEASES_TO_KEEP, len(orcid_web_keys) - 1):
		dir_mtime = float(orcid_web_keys[i])		
		if(dir_mtime < CLEAR_OLDER_THAN):
			logger.info('Release will be deleted: %s dir: %s modified on: %s', str(i), orcid_web[orcid_web_keys[i]], time.ctime(dir_mtime)) 
			shutil.rmtree(orcid_web[orcid_web_keys[i]])
		else:
			logger.info('Release will be keept: %s dir: %s modified on: %s', str(i), orcid_web[orcid_web_keys[i]], time.ctime(dir_mtime)) 
	
logger.info('Cleaner done')	