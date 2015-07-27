import logging
import os
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
    
def start_tomcat():
	os.chdir(orcid_home)
	subprocess.Popen(['nohup', os.path.join(tomcat_home, 'bin', 'startup.sh')])
	logging.info('Remember to check the logs!')
