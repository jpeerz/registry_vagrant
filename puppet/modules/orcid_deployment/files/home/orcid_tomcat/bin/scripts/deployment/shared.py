import glob
import logging
from logging.handlers import TimedRotatingFileHandler
import os
import shutil
import signal
import subprocess
import time

# Init
logging.basicConfig(format='%(asctime)s:%(levelname)s:%(message)s', level=logging.INFO)
info = logging.info

# Config

orcid_home = os.path.expanduser('~orcid_tomcat')
tomcat_home = os.path.join(orcid_home, 'bin', 'tomcat')

def stop_tomcat():
	subprocess.check_call(os.path.join(tomcat_home, 'bin', 'shutdown.sh'), stderr=subprocess.STDOUT)
	logging.info('Waiting for Tomcat to shutdown normally...')
	tomcat_pid = wait_for_tomcat()
	if(tomcat_pid):
		logging.info('Tomcat did not shutdown normally, so about to kill...')
		os.kill(tomcat_pid, signal.SIGKILL)
		logging.info('Waiting after sending kill signal to Tomcat...')
		tomcat_pid = wait_for_tomcat()
		if(tomcat_pid):
			logging.error("Tomcat still running with pid %s", tomcat_pid)
			exit(1)

def wait_for_tomcat():
    pgrep_output = None
    for i in range(15):
        time.sleep(1)
        try:
            pgrep_output = subprocess.check_output(['pgrep',  '-f',  'org.apache.catalina.startup.Bootstrap start$'])
        except subprocess.CalledProcessError:
            return None
    return int(pgrep_output)
    
def clean_tomcat():
	# Clean directories
    dirs_to_clean = ['work']
    for dir_to_clean in dirs_to_clean:
        full_dir_path = os.path.join(tomcat_home, dir_to_clean, '*')
        info('About to clean directory %s' , full_dir_path)
        for item in glob.glob(full_dir_path):
            if os.path.isfile(item) or os.path.islink(item):
                os.remove(item)
            else:
                shutil.rmtree(item)
    # Remove catalina.out
    catalina_out = os.path.join(tomcat_home, 'logs', 'catalina.out')
    if os.path.exists(catalina_out): os.remove(catalina_out)

def start_tomcat():
	os.chdir(orcid_home)
	subprocess.Popen(['nohup', os.path.join(tomcat_home, 'bin', 'startup.sh')])
	logging.info('Remember to check the logs!')

def create_file_logger(logger_name):
    log_dir = os.path.join(os.path.expanduser("~"), 'logs', logger_name)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    log_file = os.path.join(log_dir, logger_name + '.log')
    logger = logging.getLogger(logger_name)
    formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
    fileHandler = TimedRotatingFileHandler(log_file, when='midnight', interval=1, backupCount=15)
    fileHandler.setFormatter(formatter)
    logger.setLevel(logging.DEBUG)
    logger.addHandler(fileHandler)
    return logger
