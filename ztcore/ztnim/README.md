# Nim & ZeroTier

Work in progress, also need to extent and test for other platforms than Linux.

## Building

First generate the bindings. See [generate](../generate).

Ensure that libzerotiercore.so is in your path.

If you do not have a ZeroTier network ID, create one at [my.zerotier.com](https://my.zerotier.com)

The you can compile & run like (replace network ID with the one you want to join):

```
nim c -r ztnode --nwid 93afae5963d24817
```

## Nimble package

To do.