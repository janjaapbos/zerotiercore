import sys

try:
    from _zerotiercore import ffi, lib as zt
except ImportError:
    print 'Missing _zerotiercore lib error: Please run ./compile.py first'
    sys.exit()

import logging
import binascii
import os
import thread
import threading
import time
import socket
import ctypes
import pyuv
import socket
#from __future__ import print_function
from socket_util import sockaddr_storage_to_addrtuple, addrtuple_to_sockaddr


port_base = next_port = 10000
default_state_dir_prefix = './state'
zt_nodes_ptr = ffi.new("ZT_Node **")
node_counter = 0
nodes_by_uint_node_ptr = {}
nodes_by_uint_tptr = {}
node_threads = []
main_loop = None
stopping = False

max_received = 20
max_sent = 20
max_traced = 20
max_vframes = 20


def get_node_by_tptr(tptr):
    global nodes_by_uint_tptr
    node = nodes_by_uint_tptr.get(ffi.cast("uintptr_t", tptr))
    return node

def add_node_by_tptr(node):
    global nodes_by_uint_tptr
    uint_ptr = ffi.cast("uintptr_t", node.tptr)
    assert(uint_ptr not in nodes_by_uint_tptr)
    nodes_by_uint_tptr[uint_ptr]= node

def get_node_by_zt_node_ptr(zt_node_ptr):
    global nodes_by_uint_node_ptr
    node = nodes_by_uint_node_ptr.get(ffi.cast("uintptr_t", zt_node_ptr))
    return node

def add_node_by_zt_node_ptr(node):
    global nodes_by_uint_node_ptr
    uint_ptr = ffi.cast("uintptr_t", node.zt_node_ptr)
    assert(uint_ptr not in nodes_by_uint_tptr)
    nodes_by_uint_node_ptr[uint_ptr]= node


class Node(object):
    loop = None
    udp_server = None
    uptr = None
    tptr = None
    zt_node_ptr = None
    state = None
    thread = None
    ztid = None
    addres = None
    last_process_run = 0
    last_task_run = 0
    tasks_run_interval = 0
    tasks_run_interval_initialized = 1000
    tasks_run_interval_online = 10000
    stopping = False

    def __init__(self, name=None, state_dir=None, loop=None, nwids=None):
        global node_counter
        global max_received, max_sent, max_traced, max_vframes
        node_counter += 1
        if nwids is None:
            nwids = []
        self.nwids = []
        if name is None:
            name = "n%s" % (node_counter)
        self.name = name
        if loop is None:
            loop = main_loop
        self.loop = loop
        self.sent = []
        self.received = []
        self.traced = []
        self.vframes = []
        self.max_received = max_received
        self.max_sent = max_sent
        self.max_traced = max_traced
        self.max_vframes = max_vframes
        if state_dir is None:
            state_dir = os.path.join(default_state_dir_prefix, self.name)
        self.state_dir = state_dir
        self.create_dirs()

    def start(self):
        self.stopping = False
        global node_threads
        self.thread = threading.Thread(target=self.run_service, args=())
        self.thread.daemon = True
        self.thread.start()
        node_threads.append(self.thread)

    def configure_callbacks(self):
        cb = ffi.new("struct ZT_Node_Callbacks *")
        cb.version = 0
        cb.stateGetFunction = zt.PyNodeStateGetFunction
        cb.statePutFunction = zt.PyNodeStatePutFunction
        cb.wirePacketSendFunction = zt.PyNodeWirePacketSendFunction
        cb.virtualNetworkFrameFunction = zt.PyNodeVirtualNetworkFrameFunction
        cb.virtualNetworkConfigFunction = zt.PyNodeVirtualNetworkConfigFunction
        cb.eventCallback = zt.PyNodeEventCallback
        cb.pathCheckFunction = zt.PyNodePathCheckFunction
        cb.pathLookupFunction = zt.PyNodePathLookupFunction
        return cb

    def run_service(self, *args):
        global loop, zt_nodes_ptr, nodes
        self.udp_server = UdpServer(self, "")
        self.callbacks = self.configure_callbacks()

        thread_id = thread.get_ident()
        self.tptr = ffi.new("uint64_t *", thread_id)
        add_node_by_tptr(self)
        self.uptr = ffi.new("uint64_t *", 121313)
        self.nextBackgroundTaskDeadline = ffi.new("uint64_t *", 0)
        result = zt.ZT_Node_new(
                zt_nodes_ptr, self.uptr,  self.tptr, self.callbacks, get_now())
        self.udp_server.recvfrom_loop()

    def stop(self):
        self.stopping = True
        self.udp_server.udp_sock.close()

    def delete(self):
        zt.ZT_Node_delete(self.zt_node_ptr)

    def create_dirs(self):
        if not os.path.isdir(self.state_dir):
            os.makedirs(self.state_dir)
        for name in ['networks', 'iddb_dir']:
            if not os.path.isdir(os.path.join(self.state_dir, name)):
                 os.mkdir(os.path.join(self.state_dir, name))

    def getStateObjectTypePath(self, objectType, objectId):
        fn = None
        if objectType == zt.ZT_STATE_OBJECT_IDENTITY_SECRET:
            fn = os.path.join(self.state_dir, "identity.secret")
        elif objectType ==  zt.ZT_STATE_OBJECT_IDENTITY_PUBLIC:
            fn = os.path.join(self.state_dir, "identity.public")
        elif objectType ==  zt.ZT_STATE_OBJECT_PLANET:
            fn = os.path.join(self.state_dir, "planet")
        elif objectType ==  zt.ZT_STATE_OBJECT_NETWORK_CONFIG:
            fn = os.path.join(self.state_dir, "networks",  "%s.conf" % (
                    format(objectId[0], 'x')))
        else:
            print self.name, "getStateObjectTypePath unhandled:", objectType
        if fn:
            return fn

    def assert_node_started(self):
        if self.zt_node_ptr is None:
            raise RuntimeError("zt_node is not started? Use node.start() first")

    def status(self):
        self.assert_node_started()
        zt_node_status = ffi.new("ZT_NodeStatus *")
        zt.ZT_Node_status(self.zt_node_ptr, zt_node_status)
        # TODO parse query result into python object and free result
        # zt.ZT_Node_freeQueryResult(self.zt_node_ptr, zt_node_status
        return zt_node_status

    def list_peers(self):
        res = zt.ZT_Node_peers(self.zt_node_ptr)
        # TODO parse query result into python object and free result
        # zt.ZT_Node_freeQueryResult(self.zt_node_ptr, zt_node_status
        return res

    def list_networks(self):
        res = zt.ZT_Node_networks(self.zt_node_ptr)
        # TODO parse query result into python object and free result
        # zt.ZT_Node_freeQueryResult(self.zt_node_ptr, zt_node_status
        return res

    def join_network(self, nwid):
        if nwid not in self.nwids:
            self.nwids.append(nwid)
        nwid = int(nwid, 16)
        res = zt.ZT_Node_join(self.zt_node_ptr, nwid, self.uptr, self.tptr)
        # TODO parse query result into python object and free result
        # zt.ZT_Node_freeQueryResult(self.zt_node_ptr, zt_node_status

    def get_network_mac(self, nwid):
        if isinstance(nwid, basestring):
            nwid = int(nwid, 16)
        i = 0
        netw = self.list_networks()
        while i < netw.networkCount:
            if netw[i].networks.nwid == nwid:
                return netw[i].networks.mac
            i += 1

    def virtualNetworkFrameFunction(self, uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen):
        if etherType == 0 and vlanId == 0:
            if ffi.buffer(data, dataLen)[:].startswith("ping from ztid"):
                destMac = sourceMac
                localMac = self.get_network_mac(nwid)
                if not localMac:
                    print self.name, "Cannot find local mac address for: ", format(
                        nwid, 'x')
                else:
                    pong = "pong from ztid %s" % (self.ztid)
                    print self.name, 'sending', pong, 'to:', format(destMac, 'x')
                    self.send_eth(nwid=nwid, sourceMac=localMac, destMac=destMac, data=pong, etherType=0, vlanId=0)

    def send_eth(self, nwid, sourceMac, destMac, data, etherType=0, vlanId=0):
        if isinstance(nwid, basestring):
            nwid = int(nwid, 16)
        if isinstance(sourceMac, basestring):
            sourceMac = int(sourceMac, 16)
        if isinstance(destMac, basestring):
            destMac = int(destMac, 16)
        if isinstance(etherType, basestring):
            etherType = int(etherType, 16)
        if isinstance(vlanId, basestring):
            vlanId = int(vlanId, 16)

        ztres = zt.ZT_Node_processVirtualNetworkFrame(
            self.zt_node_ptr, self.tptr, get_now(),
            nwid, sourceMac, destMac,
            etherType, vlanId, data, len(data),
            self.nextBackgroundTaskDeadline
        )
        return ztres

    def broadcast_eth(self, nwid, sourceMac, data, etherType=0, vlanId=0):
        if isinstance(nwid, basestring):
            nwid = int(nwid, 16)
        ztres = zt.ZT_Node_processVirtualNetworkFrame(
            self.zt_node_ptr, self.tptr, get_now(),
            nwid, sourceMac, int("FFFFFFFFFFFF", 16),
            etherType, vlanId, data, len(data),
            self.nextBackgroundTaskDeadline
        )
        return ztres

    def send_message(self, dest, msg, typeId=99):
        data = ffi.new("char[]", msg)
        dataLen = len(msg)
        zt.ZT_Node_sendUserMessage(self.zt_node_ptr, self.tptr, dest, typeId, data, dataLen);

    def handle_message(self, user_message):
        print(self.name, "got VERB_USER_MESSAGE from:", format(user_message.origin, 'x'))
        msg = ffi.buffer(user_message.data, user_message.length)
        print msg
        if msg == "ping":
            self.send_message(user_message.origin, "pong")

    def on_initialized(self):
        self.tasks_run_interval = self.tasks_run_interval_initialized

    def on_online(self):
        # Public network Earth
        #self.join_network(nwid="8056c2e21c000001")
        self.tasks_run_interval = self.tasks_run_interval_online
        for nwid in self.nwids:
            self.join_network(nwid=nwid)

    def run_tasks(self):
        if self.stopping:
            return
        if get_now() - self.last_task_run > self.tasks_run_interval:
            zt.ZT_Node_processBackgroundTasks(
                    self.zt_node_ptr, self.tptr, get_now(),
                    self.nextBackgroundTaskDeadline)

    
class UdpServer(object):
    node = None

    def __init__(self, node, bind_ip=''):
        global port_base, next_port
        self.node = node
        self.bind_ip = bind_ip
        self.thread_id = thread.get_ident()
        self.tptr = ffi.new("uint64_t *", self.thread_id)
        self.udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        port_pass = 0
        while True:
            port = next_port
            try:
                self.udp_sock.bind((self.bind_ip, port))
                self.bind_port = next_port
                break
            except Exception, e:
                print 'e', e
                if not 'address already in use' in str(e):
                    raise
                if next_port == 65535:
                    if port_pass == 1:
                        raise e
                    print "Out of ports, start at %s again" % (port_base)
                    next_port = port_base
                    port_pass = 1
            next_port += 1
        next_port += 1

    def recvfrom_loop(self):
        global stopping
        while not self.node.stopping:
            try:
                data, ip_port = self.udp_sock.recvfrom(4096*3)
                #print 'on_read', ip_port, handle.getsockname()
                if data is None:
                   return
                #print 'on_read data hex', binascii.hexlify(data)
            except socket.error:
                if self.node.stopping:
                    break
                else:
                    raise
            if self.node.stopping:
                break
            self.node.received.append((ip_port, binascii.hexlify(data)))
            if len(self.node.received) > self.node.max_received:
                del self.node.received[0]
            remoteAddress_in = addrtuple_to_sockaddr(ffi, socket.AF_INET, ip_port)
            remoteAddress = ffi.cast("struct sockaddr_storage*", remoteAddress_in)

            result = zt.ZT_Node_processWirePacket(
                self.node.zt_node_ptr, self.node.tptr, get_now(), 0, remoteAddress,
                data, len(data), self.node.nextBackgroundTaskDeadline
            )

        if stopping:
            self.node.delete()
            self.stopping = False
    
@ffi.def_extern()
def PyNodeVirtualNetworkConfigFunction(zt_node_ptr, uptr, tptr, nwid, nuptr, op, nwconf):
    #print("PyNodeVirtualNetworkConfigFunction:", format(nwid, 'x'),  "operation:", op,
    #      "nwconf:", format(nwconf[0].nwid, 'x'),
    #      "name:", ffi.string(nwconf[0].name)
    #     )
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    return 0

@ffi.def_extern()
def PyNodeEventCallback(zt_node_ptr, uptr, tptr, event, metaData):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    if node is None:
        node = get_node_by_tptr(tptr)
        assert node is not None
    if event == zt.ZT_EVENT_UP:
        print("Node %s has been initialized" % (node.name))
        node.zt_node_ptr = zt_node_ptr
        add_node_by_zt_node_ptr(node)
        node.state = 'initialized'
        node.on_initialized()
        node.address = node.status().address
        node.ztid = format(node.address, 'x')
    elif event == zt.ZT_EVENT_OFFLINE:
        print("Node %s is offline" % (node.name))
        node.state = 'offline'
    elif event == zt.ZT_EVENT_ONLINE:
        print("Node %s is online" % (node.name))
        node.state = 'online'
        node.on_online()
    elif event == zt.ZT_EVENT_DOWN:
        node.state = 'shutting_down'
        print("Node %s is shutting down" % (node.name))
    elif event == zt.ZT_EVENT_FATAL_ERROR_IDENTITY_COLLISION:
        node.state = 'identity_collision'
        print("Your identity has collided with another node's ZeroTier address")
    elif event == zt.ZT_EVENT_TRACE:
        s = ffi.cast("char *", metaData)
        #print("Trace message: ", ffi.string(s))
        node.traced.append(ffi.string(s))
        if len(node.traced) > node.max_traced:
            del node.traced[0]
    elif event == zt.ZT_EVENT_USER_MESSAGE:
        msg = ffi.cast("ZT_UserMessage *", metaData)
        node.handle_message(msg)
    else:
        print("Unknown event", event)

@ffi.def_extern()
def PyNodeStatePutFunction(zt_node_ptr, uptr, tptr, objectType, objectId, data, dataLen):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    if node is None:
        node = get_node_by_tptr(tptr)
    assert node is not None
    fn = node.getStateObjectTypePath(objectType, objectId)
    if not fn:
        return
    fdata = ffi.buffer(data, dataLen)
    dirname = os.path.dirname(fn)
    if dataLen == -1 and os.path.isfile(fn):
        os.remove(fn)
        return
    if not os.path.isdir(dirname):
        os.makedirs(dirname)
    with open(fn, 'wb') as fp:
        fp.write(fdata)

@ffi.def_extern()
def PyNodeStateGetFunction(zt_node_ptr, uptr, tptr, objectType, objectId, data, maxLen):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    if node is None:
        node = get_node_by_tptr(tptr)
    assert node is not None
    fn = node.getStateObjectTypePath(objectType, objectId)
    if not fn:
        return -2
    if not os.path.isfile(fn):
        # print("No file found:", fn)
        return -1
    with open(fn, 'rb') as fp:
        try:
            fb = ffi.buffer(data, maxLen)
            result = fp.readinto(fb)
            return result
        except IOError:
            return -1
    return -1

@ffi.def_extern()
def PyNodeWirePacketSendFunction(zt_node_ptr, uptr, tptr, localSocket, addr, data, dataLen, ttl):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    if node is None:
        node = get_node_by_tptr(tptr)
    assert node is not None
    if node.stopping:
        return -1
    #if localAddr.ss_family != 0:
    #    try:
    #        print 'localAddr tuple', sockaddr_storage_to_addrtuple(ffi, localAddr)
    #    except Exception, e:
    #        print e
    addr_in = ffi.cast("struct sockaddr_in*", addr)
    try:
        addr_tuple = sockaddr_storage_to_addrtuple(ffi, addr)
    except Exception, e:
        print e
    fdata = ffi.buffer(data, dataLen)
    if addr.ss_family == socket.AF_INET:
        node.udp_server.udp_sock.sendto(fdata[:], addr_tuple)
        node.sent.append((addr_tuple, binascii.hexlify(fdata)))
        if len(node.sent) > node.max_sent:
            del node.sent[0]
    else:
        #print "skipped sending to addr.ss_family:", addr.ss_family
        pass
    return 0

@ffi.def_extern()
def PyNodeVirtualNetworkFrameFunction(zt_node_ptr, uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    print(node.name, 'virtualNetworkFrameFunction', 'nwid:', format(nwid, 'x'), 'sourceMac:', format(sourceMac, 'x'), 'destMac:', format(destMac, 'x'), 'etherType:', format(etherType, 'x'), ' vlanId:', vlanId)
    node.vframes.append(dict(nwid=format(nwid, 'x'), sourceMac=format(sourceMac, 'x'), destMac=format(destMac, 'x'), etherType=format(etherType, 'x'), vlanId=format(vlanId, 'x'), data=ffi.buffer(data, dataLen)[:], dataLen=dataLen))
    if len(node.vframes) > node.max_vframes:
        del node.vframes[0]
    node.virtualNetworkFrameFunction(uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen)


@ffi.def_extern()
def PyNodePathCheckFunction(zt_node_ptr, uptr, tptr, ztaddr, localSocket, remoteAddr):
    #print("PyNodePathCheckFunction", ztaddr, localSocket, remoteAddr)
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    return 1  # Yes you can use this path to the peer

@ffi.def_extern()
def PyNodePathLookupFunction(zt_node_ptr, uptr, tptr, ztaddr, family, result):
    #print("PyNodePathLookupFunction", ztaddr, family)
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    return 1  # Yes you can use this path to the peer

def get_now():
    return int(time.time() * 1000)

def process():
    global nodes_by_uint_node_ptr, stopping
    if stopping:
        return
    while True:
        for node in nodes_by_uint_node_ptr.values():
            node.run_tasks()
            if stopping:
                break
        time.sleep(1)
        if stopping:
            return

def start_process_thread():
   global nodes_by_uint_node_ptr
   global process_thread
   process_thread = threading.Thread(target=process, args=())
   process_thread.daemon = False
   process_thread.start()

def stop():
    global stopping
    stopping = True
    for node in nodes_by_uint_node_ptr.values():
        node.stop()
