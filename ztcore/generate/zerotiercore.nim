##  auto generated

{.deadCodeElim: on.}
when defined(windows):
  const
    libzerotiercore* = "zerotiercore.dll"
elif defined(macosx):
  const
    libzerotiercore* = "libzerotiercore.dylib"
else:
  const
    libzerotiercore* = "libzerotiercore.so"
##  For the struct sockaddr_storage structure
## #if defined(_WIN32) || defined(_WIN64)
## #include <WinSock2.h>
## #include <WS2tcpip.h>
## #include <Windows.h>
## #else /* not Windows */

## #endif /* Windows or not */

type
  INNER_C_UNION_2243274135* {.bycopy.} = object {.union.}
    xxu6_addr8*: array[16, uint8]
    xxu6_addr16*: array[8, uint16]
    xxu6_addr32*: array[4, uint32]

  in_port_t* = cushort
  socklen_t* = uint32
  sockaddr* {.bycopy.} = object
    sa_family*: cushort        ##  Common data: address family and length.
    sa_data*: array[14, char]   ##  Address data.
  
  sockaddr_storage* {.bycopy.} = object
    ss_family*: cushort        ##  Address family, etc.
    xxss_padding*: array[118, char]
    xxss_align*: culong        ##  Force desired alignment.
  
  in_addr_t* = uint32
  in_addr* {.bycopy.} = object
    s_addr*: in_addr_t

  in6_addr* {.bycopy.} = object
    xxin6_u*: INNER_C_UNION_2243274135

  sockaddr_in* {.bycopy.} = object
    sin_family*: cushort
    sin_port*: in_port_t       ##  Port number.
    sin_addr*: in_addr         ##  Internet address.
                     ##  Pad to size of `struct sockaddr'.
    sin_zero*: array[8, cuchar]


##  Ditto, for IPv6.

type
  sockaddr_in6* {.bycopy.} = object
    sin6_family*: cushort
    sin6_port*: in_port_t      ##  Transport layer port #
    sin6_flowinfo*: uint32     ##  IPv6 flow information
    sin6_addr*: in6_addr       ##  IPv6 address
    sin6_scope_id*: uint32     ##  IPv6 scope-id
  
  ZT_ResultCode* {.size: sizeof(cint).} = enum
    ZT_RESULT_OK = 0, ZT_RESULT_OK_IGNORED = 1,
    ZT_RESULT_FATAL_ERROR_OUT_OF_MEMORY = 100,
    ZT_RESULT_FATAL_ERROR_DATA_STORE_FAILED = 101,
    ZT_RESULT_FATAL_ERROR_INTERNAL = 102, ZT_RESULT_ERROR_NETWORK_NOT_FOUND = 1000,
    ZT_RESULT_ERROR_UNSUPPORTED_OPERATION = 1001,
    ZT_RESULT_ERROR_BAD_PARAMETER = 1002


type
  ZT_Event* {.size: sizeof(cint).} = enum
    ZT_EVENT_UP = 0, ZT_EVENT_OFFLINE = 1, ZT_EVENT_ONLINE = 2, ZT_EVENT_DOWN = 3,
    ZT_EVENT_FATAL_ERROR_IDENTITY_COLLISION = 4, ZT_EVENT_TRACE = 5,
    ZT_EVENT_USER_MESSAGE = 6, ZT_EVENT_REMOTE_TRACE = 7


type
  ZT_RemoteTrace* {.bycopy.} = object
    origin*: uint64
    data*: cstring
    len*: cuint

  ZT_UserMessage* {.bycopy.} = object
    origin*: uint64
    typeId*: uint64
    data*: pointer
    length*: cuint

  ZT_NodeStatus* {.bycopy.} = object
    address*: uint64
    publicIdentity*: cstring
    secretIdentity*: cstring
    online*: cint

  ZT_VirtualNetworkStatus* {.size: sizeof(cint).} = enum
    ZT_NETWORK_STATUS_REQUESTING_CONFIGURATION = 0, ZT_NETWORK_STATUS_OK = 1,
    ZT_NETWORK_STATUS_ACCESS_DENIED = 2, ZT_NETWORK_STATUS_NOT_FOUND = 3,
    ZT_NETWORK_STATUS_PORT_ERROR = 4, ZT_NETWORK_STATUS_CLIENT_TOO_OLD = 5


type
  ZT_VirtualNetworkType* {.size: sizeof(cint).} = enum
    ZT_NETWORK_TYPE_PRIVATE = 0, ZT_NETWORK_TYPE_PUBLIC = 1


type
  ZT_VirtualNetworkRuleType* {.size: sizeof(cint).} = enum
    ZT_NETWORK_RULE_ACTION_DROP = 0, ZT_NETWORK_RULE_ACTION_ACCEPT = 1,
    ZT_NETWORK_RULE_ACTION_TEE = 2, ZT_NETWORK_RULE_ACTION_WATCH = 3,
    ZT_NETWORK_RULE_ACTION_REDIRECT = 4, ZT_NETWORK_RULE_ACTION_BREAK = 5,
    ZT_NETWORK_RULE_ACTION_MAX_ID = 15,
    ZT_NETWORK_RULE_MATCH_SOURCE_ZEROTIER_ADDRESS = 24,
    ZT_NETWORK_RULE_MATCH_DEST_ZEROTIER_ADDRESS = 25,
    ZT_NETWORK_RULE_MATCH_VLAN_ID = 26, ZT_NETWORK_RULE_MATCH_VLAN_PCP = 27,
    ZT_NETWORK_RULE_MATCH_VLAN_DEI = 28, ZT_NETWORK_RULE_MATCH_MAC_SOURCE = 29,
    ZT_NETWORK_RULE_MATCH_MAC_DEST = 30, ZT_NETWORK_RULE_MATCH_IPV4_SOURCE = 31,
    ZT_NETWORK_RULE_MATCH_IPV4_DEST = 32, ZT_NETWORK_RULE_MATCH_IPV6_SOURCE = 33,
    ZT_NETWORK_RULE_MATCH_IPV6_DEST = 34, ZT_NETWORK_RULE_MATCH_IP_TOS = 35,
    ZT_NETWORK_RULE_MATCH_IP_PROTOCOL = 36, ZT_NETWORK_RULE_MATCH_ETHERTYPE = 37,
    ZT_NETWORK_RULE_MATCH_ICMP = 38,
    ZT_NETWORK_RULE_MATCH_IP_SOURCE_PORT_RANGE = 39,
    ZT_NETWORK_RULE_MATCH_IP_DEST_PORT_RANGE = 40,
    ZT_NETWORK_RULE_MATCH_CHARACTERISTICS = 41,
    ZT_NETWORK_RULE_MATCH_FRAME_SIZE_RANGE = 42, ZT_NETWORK_RULE_MATCH_RANDOM = 43,
    ZT_NETWORK_RULE_MATCH_TAGS_DIFFERENCE = 44,
    ZT_NETWORK_RULE_MATCH_TAGS_BITWISE_AND = 45,
    ZT_NETWORK_RULE_MATCH_TAGS_BITWISE_OR = 46,
    ZT_NETWORK_RULE_MATCH_TAGS_BITWISE_XOR = 47,
    ZT_NETWORK_RULE_MATCH_TAGS_EQUAL = 48, ZT_NETWORK_RULE_MATCH_TAG_SENDER = 49,
    ZT_NETWORK_RULE_MATCH_TAG_RECEIVER = 50, ZT_NETWORK_RULE_MATCH_MAX_ID = 63


type
  INNER_C_STRUCT_863635521* {.bycopy.} = object
    ip*: array[16, uint8]
    mask*: uint8

  INNER_C_STRUCT_896681542* {.bycopy.} = object
    ip*: uint32
    mask*: uint8

  INNER_C_STRUCT_2408286909* {.bycopy.} = object
    mask*: uint8
    value*: array[2, uint8]

  INNER_C_STRUCT_2449594434* {.bycopy.} = object
    `type`*: uint8
    code*: uint8
    flags*: uint8

  INNER_C_STRUCT_3188874109* {.bycopy.} = object
    id*: uint32
    value*: uint32

  INNER_C_STRUCT_3221920129* {.bycopy.} = object
    address*: uint64
    flags*: uint32
    length*: uint16

  INNER_C_UNION_855374015* {.bycopy.} = object {.union.}
    ipv6*: INNER_C_STRUCT_863635521
    ipv4*: INNER_C_STRUCT_896681542
    characteristics*: uint64
    port*: array[2, uint16]
    zt*: uint64
    randomProbability*: uint32
    mac*: array[6, uint8]
    vlanId*: uint16
    vlanPcp*: uint8
    vlanDei*: uint8
    etherType*: uint16
    ipProtocol*: uint8
    ipTos*: INNER_C_STRUCT_2408286909
    frameSize*: array[2, uint16]
    icmp*: INNER_C_STRUCT_2449594434
    tag*: INNER_C_STRUCT_3188874109
    fwd*: INNER_C_STRUCT_3221920129

  ZT_VirtualNetworkRule* {.bycopy.} = object
    t*: uint8
    v*: INNER_C_UNION_855374015

  ZT_VirtualNetworkRoute* {.bycopy.} = object
    target*: sockaddr_storage
    via*: sockaddr_storage
    flags*: uint16
    metric*: uint16

  ZT_MulticastGroup* {.bycopy.} = object
    mac*: uint64
    adi*: culong

  ZT_VirtualNetworkConfigOperation* {.size: sizeof(cint).} = enum
    ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_UP = 1,
    ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_CONFIG_UPDATE = 2,
    ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_DOWN = 3,
    ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_DESTROY = 4


type
  ZT_PeerRole* {.size: sizeof(cint).} = enum
    ZT_PEER_ROLE_LEAF = 0, ZT_PEER_ROLE_MOON = 1, ZT_PEER_ROLE_PLANET = 2


type
  ZT_Vendor* {.size: sizeof(cint).} = enum
    ZT_VENDOR_UNSPECIFIED = 0, ZT_VENDOR_ZEROTIER = 1


type
  ZT_Platform* {.size: sizeof(cint).} = enum
    ZT_PLATFORM_UNSPECIFIED = 0, ZT_PLATFORM_LINUX = 1, ZT_PLATFORM_WINDOWS = 2,
    ZT_PLATFORM_MACOS = 3, ZT_PLATFORM_ANDROID = 4, ZT_PLATFORM_IOS = 5,
    ZT_PLATFORM_SOLARIS_SMARTOS = 6, ZT_PLATFORM_FREEBSD = 7, ZT_PLATFORM_NETBSD = 8,
    ZT_PLATFORM_OPENBSD = 9, ZT_PLATFORM_RISCOS = 10, ZT_PLATFORM_VXWORKS = 11,
    ZT_PLATFORM_FREERTOS = 12, ZT_PLATFORM_SYSBIOS = 13, ZT_PLATFORM_HURD = 14,
    ZT_PLATFORM_WEB = 15


type
  ZT_Architecture* {.size: sizeof(cint).} = enum
    ZT_ARCHITECTURE_UNSPECIFIED = 0, ZT_ARCHITECTURE_X86 = 1, ZT_ARCHITECTURE_X64 = 2,
    ZT_ARCHITECTURE_ARM32 = 3, ZT_ARCHITECTURE_ARM64 = 4, ZT_ARCHITECTURE_MIPS32 = 5,
    ZT_ARCHITECTURE_MIPS64 = 6, ZT_ARCHITECTURE_POWER32 = 7,
    ZT_ARCHITECTURE_POWER64 = 8, ZT_ARCHITECTURE_OPENRISC32 = 9,
    ZT_ARCHITECTURE_OPENRISC64 = 10, ZT_ARCHITECTURE_SPARC32 = 11,
    ZT_ARCHITECTURE_SPARC64 = 12, ZT_ARCHITECTURE_DOTNET_CLR = 13,
    ZT_ARCHITECTURE_JAVA_JVM = 14, ZT_ARCHITECTURE_WEB = 15


type
  ZT_VirtualNetworkConfig* {.bycopy.} = object
    nwid*: uint64
    mac*: uint64
    name*: array[127 + 1, char]
    status*: ZT_VirtualNetworkStatus
    `type`*: ZT_VirtualNetworkType
    mtu*: cuint
    physicalMtu*: cuint
    dhcp*: cint
    bridge*: cint
    broadcastEnabled*: cint
    portError*: cint
    netconfRevision*: culong
    assignedAddressCount*: cuint
    assignedAddresses*: array[16, sockaddr_storage]
    routeCount*: cuint
    routes*: array[32, ZT_VirtualNetworkRoute]

  ZT_VirtualNetworkList* {.bycopy.} = object
    networks*: ptr ZT_VirtualNetworkConfig
    networkCount*: culong

  ZT_PeerPhysicalPath* {.bycopy.} = object
    address*: sockaddr_storage
    lastSend*: uint64
    lastReceive*: uint64
    trustedPathId*: uint64
    linkQuality*: cint
    expired*: cint
    preferred*: cint

  ZT_Peer* {.bycopy.} = object
    address*: uint64
    versionMajor*: cint
    versionMinor*: cint
    versionRev*: cint
    latency*: cuint
    role*: ZT_PeerRole
    pathCount*: cuint
    paths*: array[4, ZT_PeerPhysicalPath]

  ZT_PeerList* {.bycopy.} = object
    peers*: ptr ZT_Peer
    peerCount*: culong

  ZT_StateObjectType* {.size: sizeof(cint).} = enum
    ZT_STATE_OBJECT_NULL = 0, ZT_STATE_OBJECT_IDENTITY_PUBLIC = 1,
    ZT_STATE_OBJECT_IDENTITY_SECRET = 2, ZT_STATE_OBJECT_PLANET = 3,
    ZT_STATE_OBJECT_MOON = 4, ZT_STATE_OBJECT_PEER = 5,
    ZT_STATE_OBJECT_NETWORK_CONFIG = 6


type
  ZT_Node* = cint
  ZT_VirtualNetworkConfigFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer;
                                        a5: uint64; a6: ptr pointer;
                                        a7: ZT_VirtualNetworkConfigOperation;
                                        a8: ptr ZT_VirtualNetworkConfig): cint {.
      cdecl.}
  ZT_VirtualNetworkFrameFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer;
                                       a5: uint64; a6: ptr pointer; a7: uint64;
                                       a8: uint64; a9: cuint; a10: cuint;
                                       a11: pointer; a12: cuint) {.cdecl.}
  ZT_EventCallback* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer; a5: ZT_Event;
                         a6: pointer) {.cdecl.}
  ZT_StatePutFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer;
                            a5: ZT_StateObjectType; a6: array[2, uint64];
                            a7: pointer; a8: cint) {.cdecl.}
  ZT_StateGetFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer;
                            a5: ZT_StateObjectType; a6: array[2, uint64];
                            a7: pointer; a8: cuint): cint {.cdecl.}
  ZT_WirePacketSendFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer; a5: int64;
                                  a6: ptr sockaddr_storage; a7: pointer; a8: cuint;
                                  a9: cuint): cint {.cdecl.}
  ZT_PathCheckFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer; a5: uint64;
                             a6: int64; a7: ptr sockaddr_storage): cint {.cdecl.}
  ZT_PathLookupFunction* = proc (a2: ptr ZT_Node; a3: pointer; a4: pointer; a5: uint64;
                              a6: cint; a7: ptr sockaddr_storage): cint {.cdecl.}
  ZT_Node_Callbacks* {.bycopy.} = object
    version*: clong
    statePutFunction*: ZT_StatePutFunction
    stateGetFunction*: ZT_StateGetFunction
    wirePacketSendFunction*: ZT_WirePacketSendFunction
    virtualNetworkFrameFunction*: ZT_VirtualNetworkFrameFunction
    virtualNetworkConfigFunction*: ZT_VirtualNetworkConfigFunction
    eventCallback*: ZT_EventCallback
    pathCheckFunction*: ZT_PathCheckFunction
    pathLookupFunction*: ZT_PathLookupFunction


proc ZT_Node_new*(node: ptr ptr ZT_Node; uptr: pointer; tptr: pointer;
                 callbacks: ptr ZT_Node_Callbacks; now: uint64): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_new", dynlib: libzerotiercore.}
proc ZT_Node_delete*(node: ptr ZT_Node) {.cdecl, importc: "ZT_Node_delete",
                                      dynlib: libzerotiercore.}
proc ZT_Node_processWirePacket*(node: ptr ZT_Node; tptr: pointer; now: uint64;
                               localSocket: int64;
                               remoteAddress: ptr sockaddr_storage;
                               packetData: pointer; packetLength: cuint;
                               nextBackgroundTaskDeadline: ptr uint64): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_processWirePacket", dynlib: libzerotiercore.}
proc ZT_Node_processVirtualNetworkFrame*(node: ptr ZT_Node; tptr: pointer;
                                        now: uint64; nwid: uint64;
                                        sourceMac: uint64; destMac: uint64;
                                        etherType: cuint; vlanId: cuint;
                                        frameData: pointer; frameLength: cuint;
                                        nextBackgroundTaskDeadline: ptr uint64): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_processVirtualNetworkFrame", dynlib: libzerotiercore.}
proc ZT_Node_processBackgroundTasks*(node: ptr ZT_Node; tptr: pointer; now: uint64;
                                    nextBackgroundTaskDeadline: ptr uint64): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_processBackgroundTasks", dynlib: libzerotiercore.}
proc ZT_Node_join*(node: ptr ZT_Node; nwid: uint64; uptr: pointer; tptr: pointer): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_join", dynlib: libzerotiercore.}
proc ZT_Node_leave*(node: ptr ZT_Node; nwid: uint64; uptr: ptr pointer; tptr: pointer): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_leave", dynlib: libzerotiercore.}
proc ZT_Node_multicastSubscribe*(node: ptr ZT_Node; tptr: pointer; nwid: uint64;
                                multicastGroup: uint64; multicastAdi: culong): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_multicastSubscribe", dynlib: libzerotiercore.}
proc ZT_Node_multicastUnsubscribe*(node: ptr ZT_Node; nwid: uint64;
                                  multicastGroup: uint64; multicastAdi: culong): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_multicastUnsubscribe", dynlib: libzerotiercore.}
proc ZT_Node_orbit*(node: ptr ZT_Node; tptr: pointer; moonWorldId: uint64;
                   moonSeed: uint64): ZT_ResultCode {.cdecl,
    importc: "ZT_Node_orbit", dynlib: libzerotiercore.}
proc ZT_Node_deorbit*(node: ptr ZT_Node; tptr: pointer; moonWorldId: uint64): ZT_ResultCode {.
    cdecl, importc: "ZT_Node_deorbit", dynlib: libzerotiercore.}
proc ZT_Node_address*(node: ptr ZT_Node): uint64 {.cdecl, importc: "ZT_Node_address",
    dynlib: libzerotiercore.}
proc ZT_Node_get_status*(node: ptr ZT_Node; status: ptr ZT_NodeStatus) {.cdecl,
    importc: "ZT_Node_status", dynlib: libzerotiercore.}
proc ZT_Node_peers*(node: ptr ZT_Node): ptr ZT_PeerList {.cdecl,
    importc: "ZT_Node_peers", dynlib: libzerotiercore.}
proc ZT_Node_networkConfig*(node: ptr ZT_Node; nwid: uint64): ptr ZT_VirtualNetworkConfig {.
    cdecl, importc: "ZT_Node_networkConfig", dynlib: libzerotiercore.}
proc ZT_Node_networks*(node: ptr ZT_Node): ptr ZT_VirtualNetworkList {.cdecl,
    importc: "ZT_Node_networks", dynlib: libzerotiercore.}
proc ZT_Node_freeQueryResult*(node: ptr ZT_Node; qr: pointer) {.cdecl,
    importc: "ZT_Node_freeQueryResult", dynlib: libzerotiercore.}
proc ZT_Node_addLocalInterfaceAddress*(node: ptr ZT_Node;
                                      `addr`: ptr sockaddr_storage): cint {.cdecl,
    importc: "ZT_Node_addLocalInterfaceAddress", dynlib: libzerotiercore.}
proc ZT_Node_clearLocalInterfaceAddresses*(node: ptr ZT_Node) {.cdecl,
    importc: "ZT_Node_clearLocalInterfaceAddresses", dynlib: libzerotiercore.}
proc ZT_Node_sendUserMessage*(node: ptr ZT_Node; tptr: pointer; dest: uint64;
                             typeId: uint64; data: pointer; len: cuint): cint {.cdecl,
    importc: "ZT_Node_sendUserMessage", dynlib: libzerotiercore.}
proc ZT_Node_setNetconfMaster*(node: ptr ZT_Node;
                              networkConfigMasterInstance: pointer) {.cdecl,
    importc: "ZT_Node_setNetconfMaster", dynlib: libzerotiercore.}
proc ZT_Node_setTrustedPaths*(node: ptr ZT_Node; networks: ptr sockaddr_storage;
                             ids: ptr uint64; count: cuint) {.cdecl,
    importc: "ZT_Node_setTrustedPaths", dynlib: libzerotiercore.}
proc ZT_version*(major: ptr cint; minor: ptr cint; revision: ptr cint) {.cdecl,
    importc: "ZT_version", dynlib: libzerotiercore.}