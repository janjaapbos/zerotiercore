# Bindings for ZeroTierCore

## FFI based

The bindings are based on FFI. This method can be applied to many targets.
Besides Python and Nim, we can also include targets such as Lua, Rust and
Go.  Currently only Linux is tested, but I will also include Mac OSX and
Windows platforms.

The [generate/generate.py](generate/generate.py) script generates
the bindings based on the ZeroTierOne.h.

## Python
The bindings for python are in [ztpy](ztpy).
