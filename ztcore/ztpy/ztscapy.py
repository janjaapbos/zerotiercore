#!/usr/bin/env python

"""ZTScapy, embedding the ZeroTier Networking node in python with Scapy

Usage:
  ztscapy.py --nwids NETWORK_IDS [-n <number>]
  ztscapy.py -h show help

Options:
  --nwids NETWORK_IDS  comma seperated ZeroTier network IDs to join
  -n <number>          number of nodes to start [default: 3]
  -h --help            show this screen


"""

from docopt import docopt
import logging
from ztnode import Node, start_process_thread, stop
import sys


if __name__ == "__main__":
    arguments = docopt(__doc__, version="ZTScapy 0.1")
    number_of_nodes = int(arguments['-n'])
    arg_nwids = arguments['--nwids'].split(',')
    nwids = []
    for nwid in arg_nwids:
        nwids.append(nwid.strip())
    logging.getLogger("ztscapy").setLevel(1)
    # remove arguments, scapy raises an error
    sys.argv = sys.argv[:1]
    from scapy.all import *
    start_process_thread()

    myglobals = globals()
    count = 0
    while count < number_of_nodes:
        count += 1
        myglobals['n%s' % (count)] = Node(nwids=nwids)
        myglobals['n%s' % (count)].start()

    interact(mydict=myglobals, mybanner="ZT")
    stop()
