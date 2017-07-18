# Requirements & binding generation

Below are the instructions for building the ZeroTierCore library and
generating the bindings to Python and Nim. For now it is just Linux.

[ work in progress, also need to include other targets as to OS and languages ]

## Requirements

A general compiler setup to build ZeroTier. Python2 is used for the
generate.py script.

## Building ZeroTier

A fork of the ZeroTierOne repo is included in this project as a submodule,
which includes the required Linux makefile changes needed to build libzerotier
as a shared library.

Go to the [ZeroTierOne](../../modules/ZeroTierOne) directory and execute:

```
# make ZT_STATIC=0 ZT_DEBUG=1 core-shared
```

The resultant libzerotiercore.so library needs to be found when linking. The
easiest is to copy libzerotiercore.so to /usr/local/lib and then run ldconfig:

```
# cp libzerotiercore.so /usr/local/lib
# ldconfig
```

## Generating the bindings

Run the generate.py script. The bindings will be created in the current
directory.

```
# ./generate.py
```

We can now proceed to compile the Python and Nim programs in their respective
directories.
