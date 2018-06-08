#!/usr/bin/python2.7
__author__ = "https://zhukun.net"
#import getpass
import sys
import StringIO
from optparse import OptionParser
from multiprocessing import Process
from multiprocessing import Queue
import time
import traceback

try:
    import paramiko
except ImportError:
    sys.stderr.write('SYS: Import lib paramiko first.\n')
    sys.exit()

def run_cmd(local_user,ip_list,username_lst):

    rc = -1
    sout = ": user " + local_user + "\'s ssh permission grant failed."
    serr = ''

    for ip in ip_list:
        for username in username_lst:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect(hostname='keymaker.grindr.com', port=22, username=local_user)
            stdin, stdout, stderr = client.exec_command("cd /opt/keymaker && sudo -u keymaker -- fab -i /home/keymaker/.ssh/Grindr-Q2-2016.key -u " + username + " -H " + ip +  " ssh_grant")
            time.sleep(5)   
            if stdout.channel.exit_status_ready():
                #print(ip + " : Your ssh permission was granted by " + username)
	        sout = ": user " + local_user + "\'s ssh permission was granted by " + username
	        rc = 0
                break
	    else:
    	        continue
        print(ip + sout)

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option("-f", "--file", dest="ipfile",
                  help="IP list file", metavar="IPLIST")
    parser.add_option('-u', '--local_user', dest='local_user', default='kun_zhu',
                      help='Local user which you want to granted permission on keymaker', metavar='LOCAL_USER')
    parser.add_option('-n', '--num_worker', dest='num_worker', default=16,
                      help='Number of worker', metavar='NUM_WORKER')

    options, args = parser.parse_args()
    if not options.ipfile:
        parser.error('IPFILE must be present.')

    ipfile = options.ipfile
    local_user = options.local_user

    username_lst = []
    index = 1
    while True:
        username = raw_input('Username: ')
        index += 1
        if username != '':
            username_lst.append(username)
            continue
        else:
            break

    ip_list = []
    ip_list.extend([ x.strip() for x in open(ipfile).read().splitlines() ])

    run_cmd(local_user,ip_list,username_lst)
