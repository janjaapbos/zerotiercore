# Python & ZeroTier

Work in progress, also need to extent and test for other platforms than Linux.

You may need to pip install docopt and cffi.

## Building

First generate the bindings. See [generate](../generate).

Ensure that libzerotiercore.so is in your path.

Compile the module like:

```
# ./compile.py
compiling
done compiling
```

If you do not have a ZeroTier network ID, create one at [my.zerotier.com](https://my.zerotier.com)

Next you can start the ztscapy demo (replace the network ID with the one you want to join):

```

# ./ztscapy.py --nwids 93afae5963d24817
Welcome to Scapy (2.3.3)
ZT
>>> Node n2 has been initialized
Node n1 has been initialized
Node n3 has been initialized
Node n2 is online
Node n1 is online
Node n3 is online

>>>
```

## Python PIP package

To do.
