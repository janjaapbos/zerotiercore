# Bindings for ZeroTierCore

## FFI based

The bindings are based on FFI. This method can be applied to many targets.
Besides Python and Nim, we can also include targets such as Lua, Rust and
Go.  Currently only Linux is tested, but I will also include Mac OSX and
Windows platforms.

In the [generate](generate) directory the sources for the bindings are generated with the [generate.py](generate/generate.py) script parsing the ZeroTierOne.h.

## Python
The bindings for python are in [ztpy](ztpy). The Python Node class is implemented in [ztnode.py](ztpy/ztnode.py). There is also [ztscapy.py](ztpy/ztscapy.py) which launches a couply ofembedded  ZeroTier nodes and enables interaction with these objects through the Scapy interpreter.

## Nim
The Nim code is in [ztnim](ztnim). The main Node functions are implemented in [ztnode.nim](ztnim/ztnode.nim) which imports the generated [zerotiercore.nim](ztnim/zerotiercore.nim).

### Chatapp & bots
Next on the list to do is to make an example chat app library for Nim, which can be used on all main platforms: Windows, OSX, Linux, Android and iOS. Also, in order to enable bots configured or written by endusers, I will include [Duktape](http://www.duktape.org) as an embedded Javascript engine.

## Lua, Rust, Go, Unity etc.
Will be done after the Nim example app is done. Volunteers are welcome!