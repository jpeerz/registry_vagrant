import os, time, sys, logging, argparse
from os.path import expanduser
from logging.handlers import TimedRotatingFileHandler

# Logger
home = expanduser("~")
app_logs_directory = home + '/logs/delete_old_logs/'
app_log_file = 'delete_old_logs.log'
logger = logging.getLogger('upload_old_logs_logger')
formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
fileHandler = TimedRotatingFileHandler(app_logs_directory + app_log_file,
                                       when='midnight',
                                       interval=1,
                                       backupCount=15)
fileHandler.setFormatter(formatter)
logger.setLevel(logging.DEBUG)
logger.addHandler(fileHandler)

parser = argparse.ArgumentParser()
# Required parameters
parser.add_argument('-logs', '--logs_path', help='Path where the logs files are', required=False, default = '/home/orcid_tomcat/bin/tomcat/logs/')
parser.add_argument('-delete', '--delete_older_than', help='Delete files older than X days, it must not be less than 30', required=False, default = 30)
args = parser.parse_args()

# Variables
logs_folder = args.logs_path
if not logs_folder.endswith('/'):
	logs_folder += '/'

# Delete files older than X days
delete_older_than = time.time() - (int(args.delete_older_than) * 24 * 60 * 60)

# Get the list of log files
log_files = os.listdir(logs_folder)
# Process each file
logger.info('Files to process: %s', str(len(log_files)))
counter = 0
for log_file in log_files:
	file_path = logs_folder + log_file
	m_time = os.path.getmtime(file_path)
	# If it have already been ziped
	if m_time < delete_older_than:
		logger.info('Deleting file %s', log_file)
		#os.remove(file_path)
	counter += 1
	print 'Files processed: ' + str(counter)




		