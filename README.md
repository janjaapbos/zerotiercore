# ZeroTierCore
Language bindings and explorations using embedded ZeroTier network nodes.

## Why?
Integrating [ZeroTier](https://www.zerotier.com) peer-to-peer networking, security and network rules into the application enables the application to directly and securely connect to clients (devices, services or other apps).

## Less is more!
For me, [ZeroTier](https://www.zerotier.com) has changed how I look at (enterprise) networking. Why depend on a vertical (networking) stack of one vendor (AWS, VMware, Azure, Openstack, Docker etc.), or even try to make them work together, if you can make them irrelevant. Just bring the network management right to the Windows or Linux containers or mobile devices. In that respect I am a fan of [LXD](https://www.ubuntu.com/containers/lxd). Amazing what we can do scaling and building up-on a Linux container!

So yes, that is where we currently use ZeroTier, right in the containers and seamslessly connect them amd the clients all together, deploying ZeroTier networks where network rules engine is driven by [tags and capabilities](https://www.zerotier.com/manual.shtml#3) of the devices.

The next logical step is to integrate ZeroTier networking to the apps and services. The app or service will than be able to directly refer to the underlying ZeroTier rules, identity management, and connectivity. We no longer have to manage the specific app / service network requirements at the OS / container level, but can directly do this at the application level.

Every app and service has its private network stack that directly connects with its clients and users. Realtime chat, messaging, service bus protocols, are possbible without reliyng on third component such as RabbitMQ, or cloud based messaging and backhaul. This also means one or more availabiltiy dependencies less.

## Learning more
This repository is first of all meant for myself, documenting as I explore the new possibilities and try to do some proof of concepts. Occasionally I may ask someone to take a look and help me out! Feel free to jump in.

I am also learning about the underlying protocols of ZeroTier. How to create rules, how they affect and regulate network traffic and how to troubleshoot these rules using tracing. In that respect, I have just made a little python program that combines both ZeroTier and [Scapy](https://github.com/secdev/scapy), a python library to construct and manipulate network packets. We can use this to easily create and observe network traffic and the network rules applied to them.

## The zerotiercore library
ZeroTierOne can be built as a library, with just the core node functions as described in [ZeroTierOne.h](https://github.com/zerotier/ZeroTierOne/blob/master/include/ZeroTierOne.h) to embed in a program.

Since I only know some python and also am looking at using [Nim](http://www.nim-lang.org) we need to create c bindings for these languages to libzerotiercore. This is shown in the subdirectory [ztcore/generate](ztcore/generate).

## Scapy with ZeroTier embedded
Below is a quick demo of the [ztcore/ztpy/ztscapy.py](ztcore/ztpy/ztscapy.py) code. After compiling ZeroTier and creating the binding we can do something like this.

```
./ztscapy.py -h
ZTScapy, embedding the ZeroTier Networking node in python with Scapy

Usage:
  ztscapy.py --nwids NETWORK_IDS [-n <number>]
  ztscapy.py -h show help

Options:
  --nwids NETWORK_IDS  comma seperated ZeroTier network IDs to join
  -n <number>          number of nodes to start [default: 3]
  -h --help            show this screen
```

We will go for the default, and have three ZeroTier nodes created and started in our program. Although these nodes are in the same program, they are in different threads and communicate through the standard ZeroTier protocol over UDP. However, since the nodes are initialized from the main thread, we can work with the node objects (through a python class) and easily verify sent and received traffic.

```
# ./ztscapy.py
Welcome to Scapy (2.3.3)
ZT
>>> Node n3 has been initialized
Node n1 has been initialized
Node n2 has been initialized
Node n3 is online
Node n1 is online
Node n2 is online

>>>
```

Great. The three nodes have been initialized (e.g. generated their ZeroTier identities) and where able to reach the public root servers. Let's check them out a litte.

```
>>> n1
<__main__.Node object at 0x7fcd35970450>
>>>
```

Yes, it looks a bit cryptic. I should add some descriptive methods!
Let's check out a bit more.

```
>>> n1.ztid
'c0331dd4aa'
>>> n2.ztid
'dd7a663e7f'
>>> n3.ztid
'671f23dc94'
>>>
```
These are their ZeroTier adresses, also known as device ID's.

Next we will check their ZeroTier network connection, as they should have autojoined the network configured in the python script.

```
>>> ffi.string(n1.list_networks().networks.name)
'0_ztcore'
>>>
>>>n1.list_networks().networks.nwid
10641916143449819159L
>>>
```

Ok, let's print the network id in hex.

```
>>> format(n1.list_networks().networks.nwid, 'x')
'93afae5963d24817'
>>>
```
Yes, that is the network I created at ZeroTier Central [my.zerotier.com](https://my.zerotier.com). Since it is configured as a public network, there is no need to authorize the new devices, and they get the network details such as the network name and setting automatically. However, network rules that are configured still apply. We'll check that out later.

By the way, now that I think of it, I should probably make the network private and authorize the devices explicitly, since I just published the network ID on github. If I do that, then I can also connect my laptop to the network and check what happens when I try to ping an embedded device.

![](docs/png/screenshot-central-n1.png)

Central shows that n1 (the device with ID c0331dd4aa is online and has the following IPv6 address: fcf0:7de6:4ec0:331d:d4aa::1 (we can skip the zero's between two colons).

I have also connected my laptop to this network, let's see what happens if I ping n1 at its ZeroTier IPv6 address.

From my laptop

```
$ ping6 -c 2 fcf0:7de6:4ec0:331d:d4aa::1
PING6(56=40+8+8 bytes) fcf0:7de6:4e76:6242:a208::1 --> fcf0:7de6:4ec0:331d:d4aa::1

--- fcf0:7de6:4ec0:331d:d4aa::1 ping6 statistics ---
2 packets transmitted, 0 packets received, 100.0% packet loss

```

We see these ping packets arriving at n1, by a debug print statement in the code.

```
>>> ('virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '163eb021fba6', 'destMac:', '1688e17e8d04', 'etherType:', '86dd', ' vlanId:', 0)
('virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '163eb021fba6', 'destMac:', '1688e17e8d04', 'etherType:', '86dd', ' vlanId:', 0)
```

Since libzerotiercore is ethernet level 2, without a level 3 IP stack, we can see the packets but not automatically respond to them. Unless of course when we start to use Scapy. That's why we included it in the script. But for now, let's just print some more. At least I have demonstrated to myself that I can directly and privately reach a program that runs somewhere in the cloud in a deeply nested container. I am sure we are doing at least 6 nat traversals, with some excentric firewalls in between.

```
>>> n1.vframes[:1]
[{'sourceMac': '163eb021fba6', 'dataLen': 56, 'etherType': '86dd', 'destMac': '1688e17e8d04', 'data': '`\x07\xfc\xa5\x00\x10:@\xfc\xf0}\xe6NvbB\xa2\x08\x00\x00\x00\x00\x00\x01\xfc\xf0}\xe6N\xc03\x1d\xd4\xaa\x00\x00\x00\x00\x00\x01\x80\x00OA\x1e\xde\x00\x00Yl\xddB\x00\x05;\xe7', 'nwid': '93afae5963d24817', 'vlanId': '0'}]
>>>
```

Oops, yes, let's now use Scapy.

```
>>> IPv6('`\x07\xfc\xa5\x00\x10:@\xfc\xf0}\xe6NvbB\xa2\x08\x00\x00\x00\x00\x00\x01\xfc\xf0}\xe6N\xc03\x1d\xd4\xaa\x00\x00\x00\x00\x00\x01\x80\x00OA\x1e\xde\x00\x00Yl\xddB\x00\x05;\xe7')
<IPv6  version=6L tc=0L fl=523429L plen=16 nh=ICMPv6 hlim=64 src=fcf0:7de6:4e76:6242:a208::1 dst=fcf0:7de6:4ec0:331d:d4aa::1 |<ICMPv6EchoRequest  type=Echo Request code=0 cksum=0x4f41 id=0x1ede seq=0x0 data='Yl\xddB\x00\x05;\xe7' |>>
```

Yes, that was the IP6 ping packet sent from my laptop.

Let's try to send something the other way around. Do a ping again, but now use Scapy to create a ping to my laptop, and who knows, perhaps we even get something back, because my laptop does have an ipstack connectect to this network.

So we can see the source IPv6 address, which is my laptop. I am going to do it the easy way, just swap src and dst and see what happens.

```
>>> packet = IPv6(version=6L, tc=0L, fl=523429L, plen=16, nh='ICMPv6', hlim=64, src='fcf0:7de6:4ec0:331d:d4aa::1', dst='fcf0:7de6:4e76:6242:a208::1')/ICMPv6EchoRequest( type='Echo Request', code=0, cksum=0x4f41, id=0x1ede, seq=0x0, data='Yl\xddB\x00\x05;\xe7')
>>> packet
<IPv6  version=6L tc=0L fl=523429L plen=16 nh=ICMPv6 hlim=64 src=fcf0:7de6:4ec0:331d:d4aa::1 dst=fcf0:7de6:4e76:6242:a208::1 |<ICMPv6EchoRequest  type=Echo Request code=0 cksum=0x4f41 id=0x1ede seq=0x0 data='Yl\xddB\x00\x05;\xe7' |>>
>>>
>>> packet.show()
###[ IPv6 ]###
  version= 6L
  tc= 0L
  fl= 523429L
  plen= 16
  nh= ICMPv6
  hlim= 64
  src= fcf0:7de6:4ec0:331d:d4aa::1
  dst= fcf0:7de6:4e76:6242:a208::1
###[ ICMPv6 Echo Request ]###
     type= Echo Request
     code= 0
     cksum= 0x4f41
     id= 0x1ede
     seq= 0x0
     data= 'Yl\xddB\x00\x05;\xe7'
```

Wow. That at least looks ok. Thank you Scapy! Can we also send this on the virtual wire? I would think so.

The data looks like this:

```
>>>repr(str(packet))
"'`\\x07\\xfc\\xa5\\x00\\x10:@\\xfc\\xf0}\\xe6N\\xc03\\x1d\\xd4\\xaa\\x00\\x00\\x00\\x00\\x00\\x01\\xfc\\xf0}\\xe6NvbB\\xa2\\x08\\x00\\x00\\x00\\x00\\x00\\x01\\x80\\x00OA\\x1e\\xde\\x00\\x00Yl\\xddB\\x00\\x05;\\xe7'"
>>>

```

Let's send it.

```
>>> n1.send_eth(nwid='93afae5963d24817', sourceMac='163eb021fba6', destMac='1688e17e8d04', data=repr(str(packet)), etherType='86dd', vlanId=0)
0
>>>
```
It returns 0, so it appears to have no error. Let's check whether we ave a reply.

```
>>> n1.vframes
[]
```
No, there are no received frames. Perhaps the reason is traced?

```
>>> n1.traced[-1:]
['E=2000 seth=0000163eb021fba6 deth=00001688e17e8d04 et=00000000000086dd vlan=0000000000000000 fl=00000000000000af reason=not a bridge']
>>>
```

Yes, apparently I am doing something wrong. It is true that briding is not allowed in the network configuration. I mistakenly switched source and dest mac addresses. If I swap them, I do see something with tcpdump at my laptop:

```
20:04:10.745897 IP6 version error: 2 != 6
```

I am probably not creating the correct payload. I will check this further later, when I am annotating the script. Nice to see that at least I am able to at least reach something from the cloud to my laptop. First continue with stuff that I think will work. ;-)

Let's now check the other nodes. That's why we created them, to easily experiment with sending and receiving packets. No tcpdump required, we can just inspect the python objects that hold the latest packets sent and received on the wire and the received virtual frames (the actual content that is encrypted on the wire).

I will try to send an ethernet frame from n1 to n2, with plaintext content, and will just specify a diffent etherType.

First find out the address details of n2.

```
>>> n2.ztid
'dd7a663e7f'
>>> n2.list_networks().networks.mac
24832024864721L
>>> format(n2.list_networks().networks.mac, 'x')
'1695a80567d1'
>>>
```

Ok. That seems good. But, what if I did not know the ethernet mac of n2? I could calculate it from it's ZeroTier device ID. I'll save that for later. Let's assume I know nothing about n2. Perhaps do a broadcast?

```
>>> n1.broadcast_eth(nwid='93afae5963d24817', sourceMac='1688e17e8d04', data='ping')
Traceback (most recent call last):
  File "<console>", line 1, in <module>
  File "./ztscapy.py", line 239, in broadcast_eth
    self.nextBackgroundTaskDeadline
TypeError: an integer is required
>>>
```
Oh, I see, I forgot to add checks in the function to convert a string hex address to integer. I will do that shortly, but for now I'll enter them in a different way: instead of using quotes I'll prepend 0x to the hex string. Nice thing about python!

```
>>> n1.broadcast_eth(nwid=0x93afae5963d24817, sourceMac=0x1688e17e8d04, data='ping')
0
```

Looks good, but I don't receive a response:

```
>>> n1.vframes
[]
``` 

Also I don't see errors in n1.traced. Let's try again.

```
>>> n1.broadcast_eth(nwid=0x93afae5963d24817, sourceMac=0x1688e17e8d04, data='ping')
0
>>> ('virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '1688e17e8d04', 'destMac:', 'ffffffffffff', 'etherType:', '0', ' vlanId:', 0)
('virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '1688e17e8d04', 'destMac:', 'ffffffffffff', 'etherType:', '0', ' vlanId:', 0)
```

Yes! I get responses of the other 2 nodes. Let's look at the frames received.

```
>>> n1.vframes
[]
```

This is empty? Oh yes, the debug messages we see are probably from n2 and n3. I will update the script to also print the name of the node that is printing the debug... And while I am at it replace the printing by using the logging module.

But then I should be able to see something in n2.vframes and n3.vframes, since that is the place where I cache the last received virtual frames.

```
>>> n2.vframes
[{'sourceMac': '1688e17e8d04', 'dataLen': 4, 'etherType': '0', 'destMac': 'ffffffffffff', 'data': 'ping', 'nwid': '93afae5963d24817', 'vlanId': '0'}]
>>> n3.vframes
[{'sourceMac': '1688e17e8d04', 'dataLen': 4, 'etherType': '0', 'destMac': 'ffffffffffff', 'data': 'ping', 'nwid': '93afae5963d24817', 'vlanId': '0'}]
>>>
```

Yes, we can see that both n2 and n3 have received the sent frame with just the work "ping" in it.

Let's them make reply with pong. The function where we should hook this ping reply logic currently looks like this:

```
@ffi.def_extern()
def PyNodeVirtualNetworkFrameFunction(zt_node_ptr, uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    print('virtualNetworkFrameFunction', 'nwid:', format(nwid, 'x'), 'sourceMac:', format(sourceMac, 'x'), 'destMac:', format(destMac, 'x'), 'etherType:', format(etherType, 'x'), ' vlanId:', vlanId)
    node.vframes.append(dict(nwid=format(nwid, 'x'), sourceMac=format(sourceMac, 'x'), destMac=format(destMac, 'x'), etherType=format(etherType, 'x'), vlanId=format(vlanId, 'x'), data=ffi.buffer(data, dataLen)[:], dataLen=dataLen))
    if len(node.vframes) > node.max_vframes:
        del node.vframes[0]
```

We'll add the logic to check for "ping" in the data, if the etherType is 0 and the vlanId is also 0. Also, we'll actually implement the logic in a method of the Node class, so this can be overridden in an extended class. The @ffi.def_extern function need to be defined at module level, but we can call a class method from there.

```
@ffi.def_extern()
def PyNodeVirtualNetworkFrameFunction(zt_node_ptr, uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen):
    node = get_node_by_zt_node_ptr(zt_node_ptr)
    print('virtualNetworkFrameFunction', 'nwid:', format(nwid, 'x'), 'sourceMac:', format(sourceMac, 'x'), 'destMac:', format(destMac, 'x'), 'etherType:', format(etherType, 'x'), ' vlanId:', vlanId)
    node.vframes.append(dict(nwid=format(nwid, 'x'), sourceMac=format(sourceMac, 'x'), destMac=format(destMac, 'x'), etherType=format(etherType, 'x'), vlanId=format(vlanId, 'x'), data=ffi.buffer(data, dataLen)[:], dataLen=dataLen))
    if len(node.vframes) > node.max_vframes:
        del node.vframes[0]
    node.virtualNetworkFrameFunction(uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen)
```

At the Node class the following is added:

```
    def get_network_mac(self, nwid):
        if isinstance(nwid, basestring):
            nwid = int(nwid, 16)
        i = 0
        netw = self.list_networks()
        while i < netw.networkCount:
            if netw[i].networks.nwid == nwid:
                return netw[i].networks.mac
            i += 1

    def virtualNetworkFrameFunction(self, uptr, tptr, nwid, nuptr, sourceMac, destMac, etherType, vlanId, data, dataLen):
        if etherType == 0 and vlanId == 0:
            if ffi.buffer(data, dataLen)[:].startswith("ping from ztid"):
                destMac = sourceMac
                localMac = self.get_network_mac(nwid)
                if not localMac:
                    print self.name, "Cannot find local mac address for: ", format(
                        nwid, 'x')
                else:
                    pong = "pong from ztid %s" % (self.ztid)
                    print self.name, 'sending', pong, 'to:', format(destMac, 'x')
                    self.send_eth(nwid=nwid, sourceMac=localMac, destMac=destMac, data=pong, etherType=0, vlanId=0)

```

Now we can enter the following at ztscapy.

```
# ./ztscapy.py
Welcome to Scapy (2.3.3)
ZT
>>> Node n1 has been initialized
Node n3 has been initialized
 Node n2 has been initialized

>>> Node n1 is online
Node n3 is online
Node n2 is online

>>> n1.broadcast_eth(nwid=0x93afae5963d24817, sourceMac=0x1688e17e8d04, data='ping from ztid ' + n1.ztid)
0
>>> n1.broadcast_eth(nwid=0x93afae5963d24817, sourceMac=0x1688e17e8d04, data='ping from ztid ' + n1.ztid)
0
>>> ('n3', 'virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '1688e17e8d04', 'destMac:', 'ffffffffffff', 'etherType:', '0', ' vlanId:', 0)
n3 sending pong from ztid 671f23dc94 to: 1688e17e8d04
('n2', 'virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '1688e17e8d04', 'destMac:', 'ffffffffffff', 'etherType:', '0', ' vlanId:', 0)
n2 sending pong from ztid dd7a663e7f to: 1688e17e8d04
('n1', 'virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '162fcd40853a', 'destMac:', '1688e17e8d04', 'etherType:', '0', ' vlanId:', 0)
('n1', 'virtualNetworkFrameFunction', 'nwid:', '93afae5963d24817', 'sourceMac:', '1695a80567d1', 'destMac:', '1688e17e8d04', 'etherType:', '0', ' vlanId:', 0)

>>>
```

That looks ok. Note that I usually have to repeat the first broadcast. That is a common thing with broadcasts. The subsequent broadcasts are usually received directly.

Now looking at the virtual frames:

```
>>> n2.vframes
[{'sourceMac': '1688e17e8d04', 'dataLen': 25, 'etherType': '0', 'destMac': 'ffffffffffff', 'data': 'ping from ztid c0331dd4aa', 'nwid': '93afae5963d24817', 'vlanId': '0'}]
>>> n3.vframes
[{'sourceMac': '1688e17e8d04', 'dataLen': 25, 'etherType': '0', 'destMac': 'ffffffffffff', 'data': 'ping from ztid c0331dd4aa', 'nwid': '93afae5963d24817', 'vlanId': '0'}]
>>> n1.vframes
[
{'sourceMac': '162fcd40853a', 'dataLen': 25, 'etherType': '0', 'destMac': '1688e17e8d04', 'data': 'pong from ztid 671f23dc94', 'nwid': '93afae5963d24817', 'vlanId': '0'},
{'sourceMac': '1695a80567d1', 'dataLen': 25, 'etherType': '0', 'destMac': '1688e17e8d04', 'data': 'pong from ztid dd7a663e7f', 'nwid': '93afae5963d24817', 'vlanId': '0'}
]
>>>
```

Great. We now have a way to discover the nodes on a shared network. Once we have the addresses, either mac or ztid, we have a way to directly send data to these nodes.

To send data directly one-on-one, we can either send network frames to specific mac addresses or add extra types of user messages: ZT_UserMessage as defined in [ZeroTierOne.h](https://github.com/zerotier/ZeroTierOne/blob/master/include/ZeroTierOne.h). 

To be continued.
