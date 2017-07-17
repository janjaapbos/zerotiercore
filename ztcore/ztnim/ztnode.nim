import zerotiercore
import os, streams, times, strutils, ospaths
import net, nativesockets
import locks, sequtils, tables, hashes



# from https://www.bountysource.com/issues/36786621-an-universal-hexdump-routine-which-avoids-usage-of-pointers

proc dumpHex(p: pointer, nBytes: int, items = 1, ascii = true): string =
  result = ""
  let hexSize = items * 2
  var i = 0
  var slider = p
  var asciiText = ""
  while i < nBytes:
    if i %% 16 == 0:
      result = result & toHex(cast[BiggestInt](slider), sizeof(BiggestInt) * 2) & ":  "
    var k = 0
    while k < items:
      var ch = cast[ptr char](cast[uint](slider) + k.uint)[]
      if ord(ch) > 31 and ord(ch) < 127: asciiText &= ch else: asciiText &= "."
      inc(k)
    case items:
    of 1:
      result = result & toHex(cast[BiggestInt](cast[ptr uint8](slider)[]), hexSize)
    of 2:
      result = result & toHex(cast[BiggestInt](cast[ptr uint16](slider)[]), hexSize)
    of 4:
      result = result & toHex(cast[BiggestInt](cast[ptr uint32](slider)[]), hexSize)
    of 8:
      result = result & toHex(cast[BiggestInt](cast[ptr uint64](slider)[]), hexSize)
    else:
      raise newException(ValueError, "Wrong items size!")
    result = result & " "
    slider = cast[pointer](cast[uint](slider) + items.uint)
    i = i + items
    if i %% 16 == 0:
      result = result & " " & asciiText
      asciiText.setLen(0)
      result = result & "\n"

  if i %% 16 != 0:
    var spacesCount = ((16 - (i %% 16)) div items) * (hexSize + 1) + 1
    result = result & repeat(' ', spacesCount)
    result = result & asciiText
  result = result & "\n"

proc sockaddrStorageToIpaddr*(address: ptr sockaddr_storage): tuple[family: int, address: string, port: int] =
  var sockAddr = cast[ptr SockAddr](address)
  var ipaddr = getAddrString(sockAddr)
  var port: int
  var family = sockAddr.sa_family.int
  if sockAddr.sa_family == nativesockets.AF_INET.toInt():
     port = nativesockets.htons(cast[ptr sockaddr_in](sockAddr).sin_port).int
  elif sockAddr.sa_family == nativesockets.AF_INET6.toInt():
     port = nativesockets.htons(cast[ptr sockaddr_in6](sockAddr).sin6_port).int
  else:
    raise newException(ValueError, "unknown address family: " & $sockAddr.sa_family)
  return (family, ipaddr, port)

proc getNow(): uint64 =
  return uint64(epochTime() * 1000)

type
  ZerotierNode = ref object of RootObj
    name: string
    node_ptr: ptr ZT_Node
    thread_ptr: pointer
    udp_sock4: Socket
    state_dir: string
    status: ZT_NodeStatus
    lock: Lock

var zerotierNodes = initTable[string, ZerotierNode]()
var ztChannel: Channel[string]
open(ztChannel)

var
  port_base: int = 10000

  name {.threadvar.}: string
  #root_dir {.threadvar.}: string
  state_dir {.threadvar.}: string
  udp_sock4 {.threadvar.}: Socket
  #udp_sock6 {.threadvar.}: Socket
  udp_port {.threadvar.}: int
  node_ptr {.threadvar.}: ptr ZT_Node
  uptr {.threadvar.}: pointer
  threadId {.threadvar.}: int
  tptr {.threadvar.}: pointer
  deadline {.threadvar.}: uint64
  pdeadline {.threadvar.}: ptr uint64
  ztres {.threadvar.}: ZT_ResultCode
  ires {.threadvar.}: int
  zerotierNode {.threadvar.}: ZeroTierNode

  state_dir_root =  "./state"
  node: ptr ZT_Node
  nodes: ptr ptr ZT_Node = node.addr
  # max 4 nodes
  thr: array[0..4, Thread[tuple[
    name: string, state_dir: string, udp_sock4: Socket
  ]]]
  n1_node_ptr: ptr ZT_Node
  n1_thread_ptr: pointer
  n1_udp_sock4: Socket
  n1_status: ZT_NodeStatus


proc node_address(node_ptr: ptr ZT_Node): uint64 =
  var status: ZT_NodeStatus
  ZT_Node_get_status(node_ptr, status.addr)
  return status.address

proc node_id(node_ptr: ptr ZT_Node): string =
  var address = node_address(node_ptr)
  return strip(toLowerAscii(toHex(address)), trailing=false, chars={'0'})

proc join_network(node_ptr: ptr ZT_Node, nwid: string) =
  ztres = ZT_Node_join(node_ptr, uint64(parseHexInt(nwid)), uptr, tptr)

proc on_online(node_ptr: ptr ZT_Node) = 
  join_network(node_ptr, "93afae5963d24817")

proc create_dirs() =
  if not existsDir(state_dir):
    createDir(state_dir)
  if not existsDir(joinPath(state_dir, "networks.d")):
    createDir(joinPath(state_dir, "networks.d"))
  if not existsDir(joinPath(state_dir, "iddb.d")):
    createDir(joinPath(state_dir, "iddb.d"))

proc loop_process_tasks() =
  ztres = ZT_Node_processBackgroundTasks(
      node_ptr, tptr, getNow(), pdeadline)

proc init_udp_server4(): Socket =
  var udp_sock4 = newSocket(
      Domain.AF_INET, SockType.SOCK_DGRAM,
      Protocol.IPPROTO_UDP)
  udp_sock4.setSockOpt(OptReuseAddr, true)
  udp_port = port_base + 1
  while true:
    try:
      udp_sock4.bindAddr(Port(udp_port))
      break
    except:
     if udp_port == 65535:
       echo "Reached max port: ", udp_port
       udp_port = 10000
     else:
       udp_port += 1
    port_base = udp_port + 1
  return udp_sock4

proc read_udp_server4() =
  const MSG_LEN = 4096 * 4
  var 
    address: string = ""
    port: Port
    data: array[MSG_LEN, char]

  while true:
    var sockAddress: Sockaddr_in
    var addrLen = sizeof(sockAddress).SockLen

    ires = recvfrom(getFd(udp_sock4), data.addr, MSG_LEN, cint(0'i32),
                    cast[ptr SockAddr](addr(sockAddress)), addr(addrLen))

    if ires != -1:
      address = $inet_ntoa(sockAddress.sin_addr)
      port = ntohs(sockAddress.sin_port).Port
      echo address, " ", port

      ztres = ZT_Node_processWirePacket(
              node_ptr, tptr, getNow(), int64(0),
              cast[ptr sockaddr_storage](sockAddress.addr),
              data.addr, cuint(ires), pdeadline)
    else:
      #raiseOSError(osLastError())
      echo "read_udp_server4 OSError: ", osLastError()

proc getStateObjectTypePath(
                              objectType: ZT_StateObjectType;
                              objectId: array[2, uint64]): string =
  var fn = ""
  case objectType:
    of ZT_STATE_OBJECT_IDENTITY_SECRET:
      fn = "identity.secret"
    of ZT_STATE_OBJECT_IDENTITY_PUBLIC:
      fn = "identity.public"
    of ZT_STATE_OBJECT_PLANET:
      fn = "planet"
    of ZT_STATE_OBJECT_NETWORK_CONFIG:
      fn = joinPath(["networks.d", "$1.conf" % [
        toLowerAscii(toHex(objectId[0]))]])
    else:
      echo("getStateObjectTypePath unhandled: " & $objectType)
  if fn != "":
    return joinPath([state_dir, fn])
  return fn
  
proc stateGetFunction(
        xnode: ptr ZT_Node;
        xuptr: pointer; xtptr: pointer;
        objectType: ZT_StateObjectType; objectId: array[2, uint64];
        buf: pointer; bufLen: cuint): cint {.cdecl.} =
  echo("stateGetFunction " & $objectType)
  var fn = getStateObjectTypePath(objectType, objectId)
  if fn == "":
    return -1
  if not existsFile(fn):
    return -1
  let fs = newFileStream(fn, fmRead)
  if not isNil(fs):
    var size = fs.readData(buf, int(bufLen))
    fs.close()
    echo("size: " & $size)
    return cint(size)
  return -1

proc statePutFunction(
        xnode: ptr ZT_Node; xuptr: pointer; xtptr: pointer;
        objectType: ZT_StateObjectType; objectId: array[2, uint64];
        buf: pointer; bufLen: cint) {.cdecl.} =
  echo("statePutFunction " & $objectType)
  var fn = getStateObjectTypePath(objectType, objectId)
  if fn == "":
    return
  if bufLen == -1:
    removeFile(fn)
    return
  var fs = newFileStream(fn, fmWrite)
  if not isNil(fs):
    fs.writeData(buf, bufLen)
    fs.close()

proc wirePacketSendFunction(
        xnode: ptr ZT_Node; xuptr: pointer; xtptr: pointer;
        localSocket: int64; remote_address: ptr sockaddr_storage;
        data: pointer; dataLen: cuint; ttl: cuint): cint {.cdecl.} =
  # echo("wirePacketSendFunction")
  var address = sockaddrStorageToIpaddr(remote_address)
  if address[0] == nativesockets.AF_INET.toInt():
    #if xnode != node_ptr:
    #  echo "xnode: ", cast[int](xnode), " != node_ptr ", cast[int](node_ptr)
    #if xnode != n1_node_ptr:
    #  echo "xnode: ", cast[int](xnode), " != node_ptr ", cast[int](n1_node_ptr)
    #if xtptr != n1_thread_ptr:
    #  echo "xtptr != n1_thread_ptr"
    #  echo "xtptr: ", cast[int](xtptr), " != node_ptr ", cast[int](n1_thread_ptr)
    echo "sendTo dataLen: ", dataLen
    if isNil(udp_sock4):
      if xnode == n1_node_ptr:
        echo "using n1_udp_sock4"
        ires = sendTo(n1_udp_sock4, address[1], Port(address[2]),
                data, cast[int](dataLen))
      else:
        echo "unknown xnode: ",  cast[int](xnode)
    else:
      ires = sendTo(udp_sock4, address[1], Port(address[2]),
              data, cast[int](dataLen))
  return 0

proc virtualNetworkFrameFunction(
        xnode: ptr ZT_Node; xuptr: pointer; xtptr: pointer;
        nwid: uint64; xnuptr: ptr pointer; sourceMac: uint64;
        destMac: uint64; etherType: cuint; vlanId: cuint;
        data: pointer; dataLen: cuint) {.cdecl.} =
  echo dumpHex(data, int(dataLen))
  echo("virtualNetworkFrameFunction")

proc virtualNetworkConfigFunction(
        xnode: ptr ZT_Node; xuptr: pointer; xtptr: pointer;
        nwid: uint64; xnuptr: ptr pointer;
        op: ZT_VirtualNetworkConfigOperation;
        nwconf: ptr ZT_VirtualNetworkConfig): cint {.cdecl.} =
  echo "virtualNetworkConfigFunction ", toHex(nwid), " ", op
  echo nwconf[]
  return 0

proc eventCallback(
        xnode: ptr ZT_Node; xuptr: pointer; xtptr: pointer; event: ZT_Event;
        metaData: pointer) {.cdecl.} =
  case event:
    of ZT_EVENT_UP:
      echo("Node has been initialized")
      node_ptr = xnode
      if xtptr == n1_thread_ptr:
        n1_node_ptr = xnode
      loop_process_tasks()
    of ZT_EVENT_OFFLINE:
      echo("Node is offline")
    of ZT_EVENT_ONLINE:
      echo ""
      echo("Node is online")
      echo "node id: ", node_id(xnode)
      echo ""
      on_online(xnode)
    of ZT_EVENT_DOWN:
      echo("Node is shutting down")
    of ZT_EVENT_FATAL_ERROR_IDENTITY_COLLISION:
      echo("Your identity has collided with another node's ZeroTier address")
    of ZT_EVENT_TRACE:
      echo ""
      echo "*** Trace:"
      echo ""
      let mdata = cast[string](metaData)
      #let mdata = cast[ptr string](metaData)[]
      echo "Trace: ", mdata
    of ZT_EVENT_USER_MESSAGE:
      echo("VERB_USER_MESSAGE received")
    else:
      echo("Unhandled event: " & $event)

proc init_node() =
  var cb: ZT_Node_Callbacks
  var cb_ptr: ptr = addr cb
  cb.version = 0
  cb.stateGetFunction = stateGetFunction
  cb.statePutFunction = statePutFunction
  cb.wirePacketSendFunction = wirePacketSendFunction
  cb.virtualNetworkFrameFunction = virtualNetworkFrameFunction
  cb.virtualNetworkConfigFunction = virtualNetworkConfigFunction
  cb.eventCallback = eventCallback
  uptr = addr name
  threadId = getThreadId()
  tptr = addr threadId
  if name == "n1":
    n1_thread_ptr = tptr
  deadline = 0
  pdeadline = addr deadline
  create_dirs()

  ztres = ZT_Node_new(nodes, uptr, tptr, cb_ptr, getNow())
  echo("ztres: " & $ztres)
  read_udp_server4()

proc start_node_thread(tvars: tuple[
        name: string, state_dir: string, udp_sock4: Socket
        ]) {.thread.} =
  ztChannel.send("started_node " & tvars.name)
  name = tvars.name
  state_dir = tvars.state_dir
  udp_sock4 = tvars.udp_sock4
  init_node()

proc add_node(name: string) =
  zerotierNode = ZerotierNode(
    name: name, state_dir: joinPath(state_dir_root, name))
  zerotierNode.udp_sock4 = init_udp_server4()
  if isNil(zerotierNode.udp_sock4):
    echo "Cannot create udp4 server"
    return
  if name == "n1":
    n1_udp_sock4 = zerotierNode.udp_sock4
  echo zerotierNode.name
  zerotierNodes[zerotierNode.name] = zerotierNode

  createThread(thr[0], start_node_thread,
    (zerotierNode.name, zerotierNode.state_dir, zerotierNode.udp_sock4)
  )

proc process_msg(msg: string) =
  echo msg
  var args = msg.split()
  case $args[0]:
    of "started_node":
      echo "Node " & $args[1] & " is started"

proc stop_nodes() =
  if not isNil(n1_node_ptr):
    ZT_Node_delete(n1_node_ptr)

proc main() =
  add_node("n1")


when isMainModule:
  type EKeyboardInterrupt = object of Exception
  proc handler() {.noconv.} =
    raise newException(EKeyboardInterrupt, "Keyboard Interrupt")
  setControlCHook(handler)

  main()

  let total_time = epochTime()
  threadId = getThreadId()
  tptr = addr threadId
  deadline = 0
  pdeadline = addr deadline
  var last_run: uint64 = 0
  try:
    while true:
      while true:
        var req = ztChannel.tryRecv()
        if not isNil(req.msg):
          process_msg(req.msg)
        if not req.dataAvailable:
          break

      if not isNil(n1_node_ptr):
        ZT_Node_get_status(n1_node_ptr, n1_status.addr)
        if (getNow() - last_run > uint64(4000)) or (n1_status.online == 0):
          last_run = getNow()
          ztres = ZT_Node_processBackgroundTasks(
                 n1_node_ptr, n1_thread_ptr, getNow(), pdeadline)

      sleep(1000)
  except EKeyboardInterrupt:
    echo "Stopped by KeyboardInterrupt"
    stop_nodes()
    sleep(50)
