# Bindings for ZeroTierCore

## FFI based

The bindings are based on FFI. This method can be applied to many targets.
Besides Python and Nim, we can also include targets such as Lua, Rust and
Go.  Currently only Linux is tested, but I will also include Mac OSX and
Windows platforms.

In the [generate](generate) directory the sources for the bindings are generated with the [generate.py](generate/generate.py) script parsing the ZeroTierOne.h.

## Python
The bindings for python are in [python](python). The Python Node class is implemented in [ztnode.py](python/ztnode.py). There is also [ztscapy.py](python/ztscapy.py) which launches a couple of embedded  ZeroTier nodes and enables interaction with these objects through the Scapy interpreter.

## Nim
The Nim code is in [nim](nim). The main Node functions are implemented in [ztnode.nim](nim/ztnode.nim) which imports the generated [zerotiercore.nim](generate/zerotiercore.nim).

### Chatapp
Next on the list to do is to make an example chat app library for Nim, which can be used on all main platforms: Windows, OSX, Linux. Also, in order to enable scripts configured or written by endusers, I will include [Duktape](http://www.duktape.org) as an embedded Javascript engine.

[NiGui](https://github.com/trustable-code/NiGui), a cross-platform desktop GUI written in Nim will be used as the GUI library for desktops.

The ambition is to have a cross platform app, with embedded ZeroTier and Duktape, that can be built for all platforms while providing native speed and look & feel.

## Lua, Rust, Go, Unity etc.
Will be done after the Nim example app is done. Volunteers are welcome!
