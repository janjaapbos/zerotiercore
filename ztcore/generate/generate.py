#!/usr/bin/env python2

import commands
from cffi import FFI

ffi = FFI()

SS_ALIGNTYPE = "unsigned long"
SS_PADSIZE = 128 - 2 - ffi.sizeof(SS_ALIGNTYPE)
IN_PORT_T = "unsigned short int"
SIN_PADSIZE = 16 - ffi.sizeof(IN_PORT_T) - ffi.sizeof("unsigned short int") - 4

nim_prefix="""/* auto generated */

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

""" % locals()

prefix = """

typedef %(IN_PORT_T)s in_port_t;
typedef uint32_t socklen_t;
typedef struct sockaddr
{
        unsigned short int sa_family;   /* Common data: address family and length.  */
        char sa_data[14];               /* Address data.  */
};

typedef struct sockaddr_storage
{
        unsigned short int ss_family;   /* Address family, etc.  */
        char __ss_padding[%(SS_PADSIZE)d];
        %(SS_ALIGNTYPE)s __ss_align;    /* Force desired alignment.  */
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
        unsigned char sin_zero[%(SIN_PADSIZE)d];
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

""" % locals()

py_callbacks = """

extern "Python" static int PyNodeVirtualNetworkConfigFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t nwid,void **nuptr,enum ZT_VirtualNetworkConfigOperation op,const ZT_VirtualNetworkConfig *nwconf);
extern "Python" static void PyNodeEventCallback(ZT_Node *node,void *uptr,void *tptr,enum ZT_Event event,const void *metaData);
extern "Python" static void PyNodeStatePutFunction(ZT_Node *node,void *uptr,void *tptr,enum ZT_StateObjectType type,const uint64_t id[2],const void *data,int len);
extern "Python" static int PyNodeStateGetFunction(ZT_Node *node,void *uptr,void *tptr,enum ZT_StateObjectType type,const uint64_t id[2],void *data,unsigned int maxlen);
extern "Python" static int PyNodeWirePacketSendFunction(ZT_Node *node,void *uptr,void *tptr,int64_t localSocket,const struct sockaddr_storage *addr,const void *data,unsigned int len,unsigned int ttl);
extern "Python" static void PyNodeVirtualNetworkFrameFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t nwid,void **nuptr,uint64_t sourceMac,uint64_t destMac,unsigned int etherType,unsigned int vlanId,const void *data,unsigned int len);
extern "Python" static int PyNodePathCheckFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t ztaddr,int64_t localSocket,const struct sockaddr_storage *remoteAddr);
extern "Python" static int PyNodePathLookupFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t ztaddr,int family,struct sockaddr_storage *result);

"""

test_py_callbacks = """

extern "Python" static int PyNodeVirtualNetworkConfigFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t nwid,void **nuptr,enum ZT_VirtualNetworkConfigOperation op,const ZT_VirtualNetworkConfig *nwconf);
extern "Python" static void PyNodeEventCallback(ZT_Node *node,void *uptr,void *tptr,enum ZT_Event event,const void *metaData);
extern "Python" static long PyNodeDataStoreGetFunction(ZT_Node *node,void *uptr,void *tptr,const char *name,void *buf,unsigned long bufSize,unsigned long readIndex,unsigned long *totalSize);
extern "Python" static int PyNodeDataStorePutFunction(ZT_Node *node,void *uptr,void *tptr,const char *name,const void *data,unsigned long len,int secure);
extern "Python" static int PyNodeWirePacketSendFunction(ZT_Node *node,void *uptr,void *tptr,const struct sockaddr_storage *localAddr,const struct sockaddr_storage *addr,const void *data,unsigned int len,unsigned int ttl);
extern "Python" static void PyNodeVirtualNetworkFrameFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t nwid,void **nuptr,uint64_t sourceMac,uint64_t destMac,unsigned int etherType,unsigned int vlanId,const void *data,unsigned int len);
extern "Python" static int PyNodePathCheckFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t ztaddr,const struct sockaddr_storage *localAddr,const struct sockaddr_storage *remoteAddr);
extern "Python" static int PyNodePathLookupFunction(ZT_Node *node,void *uptr,void *tptr,uint64_t ztaddr,int family,struct sockaddr_storage *result);

"""

xprefix = """

typedef unsigned short sa_family_t;

typedef struct sockaddr_storage
{
  sa_family_t ss_family;
  char __ss_padding[%(SS_PADSIZE)d];
  %(SS_ALIGNTYPE)s __ss_align;
};

""" % locals()

nim_lines = nim_prefix.split('\n') + prefix.split('\n')
py_lines = prefix.split('\n')

r = commands.getstatusoutput('cpp ZeroTierOne.h >ZeroTierOne.tmp')
if r[0]:
    raise RuntimeError(r)

with open('ZeroTierOne.tmp') as fp:
    add = False
    for ln in fp:
        ln = ln.strip()
        if not ln:
            continue
        if ln == 'typedef void ZT_Node;':
            nim_lines.append('#ifndef C2NIM')
            nim_lines.append(ln)
            nim_lines.append('#else')
            nim_lines.append('typedef int ZT_Node;')
            nim_lines.append('#endif')
            py_lines.append(ln)
            continue
        if ln.startswith('#'):
            if 'ZeroTierOne.h' in ln:
                nim_lines.append('')
                py_lines.append('')
                add = True
            else:
                add = False
            continue
        if add:
            nim_lines.append(ln)
            py_lines.append(ln)

open('nim_zerotiercore.h', 'w').write('\n'.join(nim_lines))
open('py_zerotiercore.h', 'w').write('\n'.join(py_lines) + py_callbacks)

r = commands.getstatusoutput('c2nim --cdecl nim_zerotiercore.h --out:zerotiercore.nim')
if r[0]:
    raise RuntimeError(r)
