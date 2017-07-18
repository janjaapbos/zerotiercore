#!/usr/bin/env python

"""ZTScapy, embedding the ZeroTier Networking node in python with Scapy

Usage:
  ztscapy.py
  ztscapy.py -n <number>
  ztscapy.py -h show help

Options:
  -h --help    show this screen
  -n <number>  number of nodes to start [default: 3]


"""

from docopt import docopt
import logging
from ztnode import Node, start_process_thread, stop


if __name__ == "__main__":
    arguments = docopt(__doc__, version="ZTScapy 0.1")
    number_of_nodes = int(arguments['-n'])
    logging.getLogger("ztscapy").setLevel(1)
    from scapy.all import *
    start_process_thread()

    myglobals = globals()
    count = 0
    while count < number_of_nodes:
        count += 1
        myglobals['n%s' % (count)] = Node()
        myglobals['n%s' % (count)].start()

    interact(mydict=myglobals, mybanner="ZT")
    stop()
