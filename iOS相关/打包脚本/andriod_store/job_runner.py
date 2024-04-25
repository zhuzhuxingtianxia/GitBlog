
import os
import sys
import logging
import subprocess
import traceback
import threading

logger = logging.getLogger("JobRunner")
class JobRunner():
    def __init__(self):
        self.__process = None
        self.__lock = threading.Lock()
        self.__isKill = False
    #

    def run(self, cmd, _stdout, _stderr, _env=None):

        with self.__lock:
            print(cmd)
            self.__process = subprocess.Popen(cmd, env=_env, stdout=_stdout, stderr=_stderr,shell=True)
        #
        result = self.__process.wait()
        if (self.__isKill):
            result = -9999
        #
        return result
        
    #

    def kill(self):
        with self.__lock:
            if (self.__process != None):
                logger.info("killing process %r"%self.__process)
                try:
                    self.__isKill = True
                    self.__process.kill()
                except:
                    logging.exception("exception in kill pass")
                #
            #
        #
    #
#
