#!/usr/bin/env python

from cffi import FFI

def create_module():
    ffi = FFI()
    ffi.cdef(open('zerotiercore.h').read())
    ffi.set_source(
        '_zerotiercore', '#include <ZeroTierOne.h>\n',
        libraries=['zerotiercore'],
        include_dirs=["."],
        library_dirs=["."]
    )
    return ffi

ffi = create_module()


if __name__ == '__main__':
    print('compiling')
    ffi.compile()
    print('done compiling')
