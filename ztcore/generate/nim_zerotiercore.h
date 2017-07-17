/* auto generated */

#ifdef C2NIM
#  dynlib libzerotiercore
#  cdecl
#  if defined(windows)
#    define libzerotiercore "zerotiercore.dll"
#  elif defined(macosx)
#    define libzerotiercore "libzerotiercore.dylib"
#  else
#    define libzerotiercore "libzerotiercore.so"
#  endif
#endif

#include <stdint.h>

#mangle _WIN32 WIN32
#mangle _WIN64 WIN64

// For the struct sockaddr_storage structure
//#if defined(_WIN32) || defined(_WIN64)
//#include <WinSock2.h>
//#include <WS2tcpip.h>
//#include <Windows.h>
//#else /* not Windows */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
//#endif /* Windows or not */

#mangle uint16_t uint16
#mangle int32t int32
#mangle uint32_t uint32
#mangle uint8_t uint8
#mangle uint64_t uint64
#mangle int64_t int64

#mangle __u6_addr8 xxu6_addr8
#mangle __u6_addr16 xxu6_addr16
#mangle __u6_addr32 xxu6_addr32
#mangle __ss_align xxss_align
#mangle __ss_padding xxss_padding
#mangle __in6_u xxin6_u
#mangle ZT_NETWORK_RULE_ACTION__MAX_ID ZT_NETWORK_RULE_ACTION_MAX_ID
#mangle ZT_NETWORK_RULE_MATCH__MAX_ID ZT_NETWORK_RULE_MATCH_MAX_ID
#mangle ZT_Node_status ZT_Node_get_status




typedef unsigned short int in_port_t;
typedef uint32_t socklen_t;
typedef struct sockaddr
{
        unsigned short int sa_family;   /* Common data: address family and length.  */
        char sa_data[14];               /* Address data.  */
};

typedef struct sockaddr_storage
{
        unsigned short int ss_family;   /* Address family, etc.  */
        char __ss_padding[118];
        unsigned long __ss_align;    /* Force desired alignment.  */
};

typedef uint32_t in_addr_t;
typedef struct in_addr
{
        in_addr_t s_addr;
};

typedef struct in6_addr
{
        union
        {
                uint8_t __u6_addr8[16];
                uint16_t __u6_addr16[8];
                uint32_t __u6_addr32[4];
        } __in6_u;
};

typedef struct sockaddr_in
{
        unsigned short int sin_family;
        in_port_t sin_port;             /* Port number.  */
        struct in_addr sin_addr;        /* Internet address.  */

        /* Pad to size of `struct sockaddr'.  */
        unsigned char sin_zero[8];
};

/* Ditto, for IPv6.  */
typedef struct sockaddr_in6
{
        unsigned short int sin6_family;
        in_port_t sin6_port;            /* Transport layer port # */
        uint32_t sin6_flowinfo;         /* IPv6 flow information */
        struct in6_addr sin6_addr;      /* IPv6 address */
        uint32_t sin6_scope_id;         /* IPv6 scope-id */
};









enum ZT_ResultCode
{
ZT_RESULT_OK = 0,
ZT_RESULT_OK_IGNORED = 1,
ZT_RESULT_FATAL_ERROR_OUT_OF_MEMORY = 100,
ZT_RESULT_FATAL_ERROR_DATA_STORE_FAILED = 101,
ZT_RESULT_FATAL_ERROR_INTERNAL = 102,
ZT_RESULT_ERROR_NETWORK_NOT_FOUND = 1000,
ZT_RESULT_ERROR_UNSUPPORTED_OPERATION = 1001,
ZT_RESULT_ERROR_BAD_PARAMETER = 1002
};

enum ZT_Event
{

ZT_EVENT_UP = 0,
ZT_EVENT_OFFLINE = 1,
ZT_EVENT_ONLINE = 2,

ZT_EVENT_DOWN = 3,

ZT_EVENT_FATAL_ERROR_IDENTITY_COLLISION = 4,

ZT_EVENT_TRACE = 5,

ZT_EVENT_USER_MESSAGE = 6
};

typedef struct
{
uint64_t origin;
uint64_t typeId;
const void *data;
unsigned int length;
} ZT_UserMessage;
typedef struct
{
uint64_t address;
const char *publicIdentity;
const char *secretIdentity;
int online;
} ZT_NodeStatus;
enum ZT_VirtualNetworkStatus
{
ZT_NETWORK_STATUS_REQUESTING_CONFIGURATION = 0,
ZT_NETWORK_STATUS_OK = 1,
ZT_NETWORK_STATUS_ACCESS_DENIED = 2,
ZT_NETWORK_STATUS_NOT_FOUND = 3,
ZT_NETWORK_STATUS_PORT_ERROR = 4,
ZT_NETWORK_STATUS_CLIENT_TOO_OLD = 5
};
enum ZT_VirtualNetworkType
{
ZT_NETWORK_TYPE_PRIVATE = 0,
ZT_NETWORK_TYPE_PUBLIC = 1
};

enum ZT_VirtualNetworkRuleType
{
ZT_NETWORK_RULE_ACTION_DROP = 0,
ZT_NETWORK_RULE_ACTION_ACCEPT = 1,
ZT_NETWORK_RULE_ACTION_TEE = 2,
ZT_NETWORK_RULE_ACTION_WATCH = 3,
ZT_NETWORK_RULE_ACTION_REDIRECT = 4,
ZT_NETWORK_RULE_ACTION_BREAK = 5,
ZT_NETWORK_RULE_ACTION__MAX_ID = 15,
ZT_NETWORK_RULE_MATCH_SOURCE_ZEROTIER_ADDRESS = 24,
ZT_NETWORK_RULE_MATCH_DEST_ZEROTIER_ADDRESS = 25,
ZT_NETWORK_RULE_MATCH_VLAN_ID = 26,
ZT_NETWORK_RULE_MATCH_VLAN_PCP = 27,
ZT_NETWORK_RULE_MATCH_VLAN_DEI = 28,
ZT_NETWORK_RULE_MATCH_MAC_SOURCE = 29,
ZT_NETWORK_RULE_MATCH_MAC_DEST = 30,
ZT_NETWORK_RULE_MATCH_IPV4_SOURCE = 31,
ZT_NETWORK_RULE_MATCH_IPV4_DEST = 32,
ZT_NETWORK_RULE_MATCH_IPV6_SOURCE = 33,
ZT_NETWORK_RULE_MATCH_IPV6_DEST = 34,
ZT_NETWORK_RULE_MATCH_IP_TOS = 35,
ZT_NETWORK_RULE_MATCH_IP_PROTOCOL = 36,
ZT_NETWORK_RULE_MATCH_ETHERTYPE = 37,
ZT_NETWORK_RULE_MATCH_ICMP = 38,
ZT_NETWORK_RULE_MATCH_IP_SOURCE_PORT_RANGE = 39,
ZT_NETWORK_RULE_MATCH_IP_DEST_PORT_RANGE = 40,
ZT_NETWORK_RULE_MATCH_CHARACTERISTICS = 41,
ZT_NETWORK_RULE_MATCH_FRAME_SIZE_RANGE = 42,
ZT_NETWORK_RULE_MATCH_RANDOM = 43,
ZT_NETWORK_RULE_MATCH_TAGS_DIFFERENCE = 44,
ZT_NETWORK_RULE_MATCH_TAGS_BITWISE_AND = 45,
ZT_NETWORK_RULE_MATCH_TAGS_BITWISE_OR = 46,
ZT_NETWORK_RULE_MATCH_TAGS_BITWISE_XOR = 47,
ZT_NETWORK_RULE_MATCH_TAGS_EQUAL = 48,
ZT_NETWORK_RULE_MATCH_TAG_SENDER = 49,
ZT_NETWORK_RULE_MATCH_TAG_RECEIVER = 50,
ZT_NETWORK_RULE_MATCH__MAX_ID = 63
};

typedef struct
{

uint8_t t;
union {
struct {
uint8_t ip[16];
uint8_t mask;
} ipv6;
struct {
uint32_t ip;
uint8_t mask;
} ipv4;
uint64_t characteristics;
uint16_t port[2];
uint64_t zt;
uint32_t randomProbability;
uint8_t mac[6];
uint16_t vlanId;
uint8_t vlanPcp;
uint8_t vlanDei;
uint16_t etherType;
uint8_t ipProtocol;
struct {
uint8_t mask;
uint8_t value[2];
} ipTos;
uint16_t frameSize[2];
struct {
uint8_t type;
uint8_t code;
uint8_t flags;
} icmp;
struct {
uint32_t id;
uint32_t value;
} tag;
struct {
uint64_t address;
uint32_t flags;
uint16_t length;
} fwd;
} v;
} ZT_VirtualNetworkRule;
typedef struct
{
struct sockaddr_storage target;
struct sockaddr_storage via;
uint16_t flags;
uint16_t metric;
} ZT_VirtualNetworkRoute;
typedef struct
{
uint64_t mac;
unsigned long adi;
} ZT_MulticastGroup;
enum ZT_VirtualNetworkConfigOperation
{
ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_UP = 1,
ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_CONFIG_UPDATE = 2,
ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_DOWN = 3,
ZT_VIRTUAL_NETWORK_CONFIG_OPERATION_DESTROY = 4
};
enum ZT_PeerRole
{
ZT_PEER_ROLE_LEAF = 0,
ZT_PEER_ROLE_MOON = 1,
ZT_PEER_ROLE_PLANET = 2
};
enum ZT_Vendor
{
ZT_VENDOR_UNSPECIFIED = 0,
ZT_VENDOR_ZEROTIER = 1
};
enum ZT_Platform
{
ZT_PLATFORM_UNSPECIFIED = 0,
ZT_PLATFORM_LINUX = 1,
ZT_PLATFORM_WINDOWS = 2,
ZT_PLATFORM_MACOS = 3,
ZT_PLATFORM_ANDROID = 4,
ZT_PLATFORM_IOS = 5,
ZT_PLATFORM_SOLARIS_SMARTOS = 6,
ZT_PLATFORM_FREEBSD = 7,
ZT_PLATFORM_NETBSD = 8,
ZT_PLATFORM_OPENBSD = 9,
ZT_PLATFORM_RISCOS = 10,
ZT_PLATFORM_VXWORKS = 11,
ZT_PLATFORM_FREERTOS = 12,
ZT_PLATFORM_SYSBIOS = 13,
ZT_PLATFORM_HURD = 14,
ZT_PLATFORM_WEB = 15
};
enum ZT_Architecture
{
ZT_ARCHITECTURE_UNSPECIFIED = 0,
ZT_ARCHITECTURE_X86 = 1,
ZT_ARCHITECTURE_X64 = 2,
ZT_ARCHITECTURE_ARM32 = 3,
ZT_ARCHITECTURE_ARM64 = 4,
ZT_ARCHITECTURE_MIPS32 = 5,
ZT_ARCHITECTURE_MIPS64 = 6,
ZT_ARCHITECTURE_POWER32 = 7,
ZT_ARCHITECTURE_POWER64 = 8,
ZT_ARCHITECTURE_OPENRISC32 = 9,
ZT_ARCHITECTURE_OPENRISC64 = 10,
ZT_ARCHITECTURE_SPARC32 = 11,
ZT_ARCHITECTURE_SPARC64 = 12,
ZT_ARCHITECTURE_DOTNET_CLR = 13,
ZT_ARCHITECTURE_JAVA_JVM = 14,
ZT_ARCHITECTURE_WEB = 15
};
typedef struct
{
uint64_t nwid;
uint64_t mac;
char name[127 + 1];
enum ZT_VirtualNetworkStatus status;
enum ZT_VirtualNetworkType type;
unsigned int mtu;
unsigned int physicalMtu;

int dhcp;
int bridge;
int broadcastEnabled;
int portError;
unsigned long netconfRevision;
unsigned int assignedAddressCount;

struct sockaddr_storage assignedAddresses[16];
unsigned int routeCount;
ZT_VirtualNetworkRoute routes[32];
} ZT_VirtualNetworkConfig;
typedef struct
{
ZT_VirtualNetworkConfig *networks;
unsigned long networkCount;
} ZT_VirtualNetworkList;
typedef struct
{
struct sockaddr_storage address;
uint64_t lastSend;
uint64_t lastReceive;
uint64_t trustedPathId;
int linkQuality;
int expired;
int preferred;
} ZT_PeerPhysicalPath;
typedef struct
{
uint64_t address;
int versionMajor;
int versionMinor;
int versionRev;
unsigned int latency;
enum ZT_PeerRole role;
unsigned int pathCount;
ZT_PeerPhysicalPath paths[4];
} ZT_Peer;
typedef struct
{
ZT_Peer *peers;
unsigned long peerCount;
} ZT_PeerList;
enum ZT_StateObjectType
{
ZT_STATE_OBJECT_NULL = 0,

ZT_STATE_OBJECT_IDENTITY_PUBLIC = 1,

ZT_STATE_OBJECT_IDENTITY_SECRET = 2,

ZT_STATE_OBJECT_PLANET = 3,

ZT_STATE_OBJECT_MOON = 4,

ZT_STATE_OBJECT_PEER = 5,

ZT_STATE_OBJECT_NETWORK_CONFIG = 6
};
#ifndef C2NIM
typedef void ZT_Node;
#else
typedef int ZT_Node;
#endif

typedef int (*ZT_VirtualNetworkConfigFunction)(
ZT_Node *,
void *,
void *,
uint64_t,
void **,
enum ZT_VirtualNetworkConfigOperation,
const ZT_VirtualNetworkConfig *);

typedef void (*ZT_VirtualNetworkFrameFunction)(
ZT_Node *,
void *,
void *,
uint64_t,
void **,
uint64_t,
uint64_t,
unsigned int,
unsigned int,
const void *,
unsigned int);

typedef void (*ZT_EventCallback)(
ZT_Node *,
void *,
void *,
enum ZT_Event,
const void *);

typedef void (*ZT_StatePutFunction)(
ZT_Node *,
void *,
void *,
enum ZT_StateObjectType,
const uint64_t [2],
const void *,
int);

typedef int (*ZT_StateGetFunction)(
ZT_Node *,
void *,
void *,
enum ZT_StateObjectType,
const uint64_t [2],
void *,
unsigned int);

typedef int (*ZT_WirePacketSendFunction)(
ZT_Node *,
void *,
void *,
int64_t,
const struct sockaddr_storage *,
const void *,
unsigned int,
unsigned int);

typedef int (*ZT_PathCheckFunction)(
ZT_Node *,
void *,
void *,
uint64_t,
int64_t,
const struct sockaddr_storage *);

typedef int (*ZT_PathLookupFunction)(
ZT_Node *,
void *,
void *,
uint64_t,
int,
struct sockaddr_storage *);

struct ZT_Node_Callbacks
{
long version;
ZT_StatePutFunction statePutFunction;
ZT_StateGetFunction stateGetFunction;
ZT_WirePacketSendFunction wirePacketSendFunction;
ZT_VirtualNetworkFrameFunction virtualNetworkFrameFunction;
ZT_VirtualNetworkConfigFunction virtualNetworkConfigFunction;
ZT_EventCallback eventCallback;
ZT_PathCheckFunction pathCheckFunction;
ZT_PathLookupFunction pathLookupFunction;
};

enum ZT_ResultCode ZT_Node_new(ZT_Node **node,void *uptr,void *tptr,const struct ZT_Node_Callbacks *callbacks,uint64_t now);

void ZT_Node_delete(ZT_Node *node);

enum ZT_ResultCode ZT_Node_processWirePacket(
ZT_Node *node,
void *tptr,
uint64_t now,
int64_t localSocket,
const struct sockaddr_storage *remoteAddress,
const void *packetData,
unsigned int packetLength,
volatile uint64_t *nextBackgroundTaskDeadline);

enum ZT_ResultCode ZT_Node_processVirtualNetworkFrame(
ZT_Node *node,
void *tptr,
uint64_t now,
uint64_t nwid,
uint64_t sourceMac,
uint64_t destMac,
unsigned int etherType,
unsigned int vlanId,
const void *frameData,
unsigned int frameLength,
volatile uint64_t *nextBackgroundTaskDeadline);

enum ZT_ResultCode ZT_Node_processBackgroundTasks(ZT_Node *node,void *tptr,uint64_t now,volatile uint64_t *nextBackgroundTaskDeadline);

enum ZT_ResultCode ZT_Node_join(ZT_Node *node,uint64_t nwid,void *uptr,void *tptr);

enum ZT_ResultCode ZT_Node_leave(ZT_Node *node,uint64_t nwid,void **uptr,void *tptr);

enum ZT_ResultCode ZT_Node_multicastSubscribe(ZT_Node *node,void *tptr,uint64_t nwid,uint64_t multicastGroup,unsigned long multicastAdi);

enum ZT_ResultCode ZT_Node_multicastUnsubscribe(ZT_Node *node,uint64_t nwid,uint64_t multicastGroup,unsigned long multicastAdi);

enum ZT_ResultCode ZT_Node_orbit(ZT_Node *node,void *tptr,uint64_t moonWorldId,uint64_t moonSeed);

enum ZT_ResultCode ZT_Node_deorbit(ZT_Node *node,void *tptr,uint64_t moonWorldId);
uint64_t ZT_Node_address(ZT_Node *node);
void ZT_Node_status(ZT_Node *node,ZT_NodeStatus *status);

ZT_PeerList *ZT_Node_peers(ZT_Node *node);

ZT_VirtualNetworkConfig *ZT_Node_networkConfig(ZT_Node *node,uint64_t nwid);
ZT_VirtualNetworkList *ZT_Node_networks(ZT_Node *node);

void ZT_Node_freeQueryResult(ZT_Node *node,void *qr);

int ZT_Node_addLocalInterfaceAddress(ZT_Node *node,const struct sockaddr_storage *addr);
void ZT_Node_clearLocalInterfaceAddresses(ZT_Node *node);

int ZT_Node_sendUserMessage(ZT_Node *node,void *tptr,uint64_t dest,uint64_t typeId,const void *data,unsigned int len);

void ZT_Node_setNetconfMaster(ZT_Node *node,void *networkConfigMasterInstance);

void ZT_Node_setTrustedPaths(ZT_Node *node,const struct sockaddr_storage *networks,const uint64_t *ids,unsigned int count);

void ZT_version(int *major,int *minor,int *revision);