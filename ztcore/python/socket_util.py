import socket

# https://github.com/apexo/pgdtls/blob/master/pgdtls/sockutil.py
# https://github.com/apexo/pgdtls/blob/master/pgdtls/hdr/socket.py


def addrtuple_to_sockaddr(ffi, family, addr):
    if family not in (socket.AF_INET, socket.AF_INET6):
        raise ValueError("unsupported address family: %r" % (family,))
    binaddr = socket.inet_pton(family, addr[0])
    if family == socket.AF_INET:
        if len(addr) != 2:
            raise ValueError("unsupported IN address: %r" % (addr,))
        name = ffi.new("struct sockaddr_in*")
        #name.sin_family = socket.htons(family)
        name.sin_family = family
        name.sin_port = socket.htons(addr[1])
        ffi.buffer(ffi.addressof(name.sin_addr))[:] = binaddr
    else:
        if not 2 <= len(addr) <= 4:
            raise ValueError("unsupported IN6 address: %r" % (addr,))
        name = ffi.new("struct sockaddr_in6*")
        #name.sin6_family = socket.htons(family)
        name.sin6_family = family
        name.sin6_port = socket.htons(addr[1])
        name.sin6_flowinfo = 0 if len(addr) < 3 else socket.htonl(addr[2])
        ffi.buffer(ffi.addressof(name.sin6_addr))[:] = binaddr
        name.sin6_scope_id = 0 if len(addr) < 4 else socket.htonl(addr[3])
    return name

def addrtuple_to_name(ffi, family, addr):
    sockaddr = addrtuple_to_sockaddr(family, addr)
    return ffi.buffer(sockaddr)[:]

def name_to_addrtuple(ffi, name):
    assert isinstance(name, bytes)
    assert len(name) in (16, 28)
    temp = ffi.new("unsigned char[]", name)
    sa = ffi.cast("struct sockaddr*", temp)
    return sockaddr_to_addrtuple(sa)

def sockaddr_to_addrtuple(ffi, sa):
    #family = socket.ntohs(sa.sa_family)
    family = sa.sa_family
    if family == socket.AF_INET:
        sin = ffi.cast("struct sockaddr_in*", sa)
        return socket.inet_ntop(family, ffi.buffer(ffi.addressof(sin.sin_addr))[:]), socket.ntohs(sin.sin_port)
    elif family == socket.AF_INET6:
        sin6 = ffi.cast("struct sockaddr_in6*", sa)
        return socket.inet_ntop(family, ffi.buffer(ffi.addressof(sin6.sin6_addr))[:]), socket.ntohs(sin6.sin6_port), socket.ntohl(sin6.sin6_flowinfo), socket.ntohl(sin6.sin6_scope_id)
    else:
        raise ValueError("unsupported address family: %r" % (family,))

def sockaddr_storage_to_addrtuple(ffi, ss):
    family = ss.ss_family
    if family == socket.AF_INET:
        sin = ffi.cast("struct sockaddr_in*", ss)
        return socket.inet_ntop(family, ffi.buffer(ffi.addressof(sin.sin_addr))[:]), socket.ntohs(sin.sin_port)
    elif family == socket.AF_INET6:
        sin6 = ffi.cast("struct sockaddr_in6*", ss)
        return socket.inet_ntop(family, ffi.buffer(ffi.addressof(sin6.sin6_addr))[:]), socket.ntohs(sin6.sin6_port), socket.ntohl(sin6.sin6_flowinfo), socket.ntohl(sin6.sin6_scope_id)
    else:
        raise ValueError("unsupported address family: %r" % (family,))
