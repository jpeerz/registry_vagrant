#!/usr/bin/env python
# Script to search for out of memory errors in tomcat logs, and kill tomcat if found.

import logging
import os
import shared
import subprocess

# Init
logger = shared.create_file_logger('tomcat-oom-monitor')
catalina_out_path = os.path.join(shared.tomcat_home, 'logs', 'catalina.out')
search_command = 'tac %s 2>/dev/null | grep -n -m1 %s | cut -f1 -d:'

# Function definitions

def stop_tomcat():
    logger.info('Stopping tomcat...')
    shared.stop_tomcat()
    logger.info('Stopped tomcat')

# Start of script

logger.info('About to check for out of memory error')
oom_line_number = subprocess.check_output(search_command % (catalina_out_path, 'java.lang.OutOfMemoryError'), shell=True).strip()
if(oom_line_number):
    logger.info('Found out of memory error on line %s from end of file', oom_line_number)
    startup_line_number = subprocess.check_output(search_command % (catalina_out_path, '"org.apache.catalina.core.StandardService.startInternal Starting"'), shell=True).strip()
    if(startup_line_number):
        logging.info('Start up found on line %s from end of file', startup_line_number)
        # Line numbers are from end of file, so if oom error is after start up then oom line number will be less than start up line number.
        if(int(oom_line_number) < int(startup_line_number)):
            logger.info('Out of memory occurred after start up')
            stop_tomcat()
    else:
        logger.info('Start up was before start of log file')
        stop_tomcat()
else:
    logger.info('No out of memory error found')
logger.info('Finished checking for out of memory error')
