# Using a Battery-powered Raspberry Pi as a Tor Gateway

Time to have some fun with a shiny new Raspberry Pi! Obviously one of the things I had to do, was to make it work as an AP for my iPad Pro to connect to, so I could SSH in and do some actual work.

It turns out that it's pretty straightforward to go from there to a neat little Tor gateway. For, you know, whenever you'd need that. The finished product looks something like this:

![salty-dog.becquerel.org, a battery-powered Raspberry Pi that is all set up and running Tor. Also note that it's currently powered on.](/jpeg/salty-dog)

To create one of these handy little buggers, you'll need the following:

 * 1 Raspberry Pi
 * 2 USB WiFi dongles
 * 1 USB battery pack

Make sure the battery pack has enough power to get the Raspberry Pi to boot. Also, we'll assume you already set up wpa-supplicant for use with one of your WiFi dongles.

Oh yeah, and while you're running that Pi off a battery, you probably won't be plugging that HDMI port into anything so you could just get rid of all that useless X11.

## Part 1: Setting up the AP

There's a number of guides floating around for this, so this will just be a quick rundown. In essence, you need to add the WiFi dongle, give it a static interface name, set up a DHCP server and then set up hostapd. Everything but plugging in the dongle and setting up hostapd are technically optional, but it's just less of a hassle to do the lot of it.

After plugging in the WiFi dongle, edit or create a /etc/udev/rules.d/70-wireless.rules, like so:

    # config file snippet
    # rename wireless interface that works as an AP
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="aa:bb:cc:dd:ee:ff", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="wlan*", NAME="ap0"

To find the MAC address to put in place of "aa:bb:cc:dd:ee:ff", you can use the "ifconfig" command, which lists all the active interfaces with their "hardware address." The easiest way to apply this rule and see if it worked is to unplug and then replug the adaptor. Also, consider adding the MAC address of the other wireless adaptor that you're not using as an AP, and name it "wlan0" instead of "ap0."

We'll also want to give it a static IP address. To do so, edit /etc/network/interfaces and add a block like this:

    auto ap0
    allow-hotplug ap0
    iface ap0 inet static
      address 10.4.0.1
      netmask 255.255.255.0

Again, easiest way to apply this is to unplug and replug the adaptor. If you don't like using 10.x.x.x addresses, remember to adjust further references to 10.4.0.1 to the address you picked. Once that is done, install the necessary system daemons, like so:

    # apt-get install udhcpd hostapd

Set up udhcpd by editing /etc/udhcp.conf. You could set it up like this:

    start 10.4.0.4
    end 10.4.0.254
    interface ap0

    opt     dns     8.8.8.8 4.2.2.2
    opt     subnet  255.255.255.0
    opt     router  10.4.0.1
    opt     lease   864000

The "dns" option is probably not needed, as you won't be enabling IP forwarding anyway, but setting it to the public Google DNS servers shouldn't hurt, either.

To enable udhcpd, edit /etc/default/udhcpd and change the "DHCPD_ENABLED" variable to "yes."

Set up hostapd by editing /etc/hostapd/hostapd.conf. Here's an example config:

    interface=ap0
    ssid=my-tor-ap
    hw_mode=g
    channel=6
    macaddr_acl=0
    auth_algs=1
    ignore_broadcast_ssid=0
    wpa=2
    wpa_passphrase=my-tor-passphrase
    wpa_key_mgmt=WPA-PSK
    wpa_pairwise=TKIP
    rsn_pairwise=CCMP

Adjust the ssid= and wpa_passphrase= settings to your liking. There's probably no need to set a driver= line, but then it probably won't hurt, either. Note how we used interface=ap0, which is what we named the interfaces via udev.

To enable hostapd, edit /etc/default/hostapd. A complete config file would look like this:

    DAEMON_CONF="/etc/hostapd/hostapd.conf"

You could start the daemons manually now, but you'll want this to work without having to log on so verify that by just rebooting your Pi. Assuming everything worked, move on to the next section.

Do note that, unlike what other guides say, in this context you should *not* enable IP forwarding on the Pi. That's because you want to force traffic through Tor, and setting up IP forwarding allows client devices to bypass this restriction.

## Part 2: Setting up Tor

Tor is fairly easy to set up. The only issue you'll have is getting some devices to talk to it, but we'll get to that in the next paragraph. For now, just install the daemon:

    # apt-get install tor

It'll now be configured and good to go, except that Tor will only listen for connections on 127.0.0.1:9050. Therefore you can't use it as a bridge, yet. To fix that, edit /etc/tor/torrc. The lines needed to convince Tor to listen your new AP are...

    SocksPort 9050
    SocksPort 10.4.0.1:9050

... and once you restart Tor you should already be able to connect to Tor's SOCKS proxy from a different host on the same network. Feel free to verify that the proxy is in fact used by resolving your IP address (search for "What is my IP address" in DuckDuckGo or Google). Hidden Services should now also be available, [which you could verify by browsing to this blog's hidden service at vturtipc7vmz6xjy.onion](http://vturtipc7vmz6xjy.onion/).

## Part 3: Getting iOS to use Tor

iOS devices, among others, do not have an option to set a SOCKS proxy in their network configuration. Fortunately it is still possible to use those proxies with a little help of a proxy auto-config file. To use one of these, your Pi will need to be able to serve files via HTTP, so install a web server if you haven't done so already:

    # apt-get install nginx-light

Next, create a file /var/www/html/proxy.pac, with the following contents:

    function FindProxyForURL(url, host) {
      if (isInNet(host, "10.0.0.0", "255.0.0.0")) {
        return "DIRECT";
      }

      return "SOCKS 10.4.0.1:9050";
    }

Finally, set the HTTP proxy to "Auto" in iOS' network settings, and set the URL to http://10.4.0.1/proxy.pac.

![This is what your settings should look like once you're done.](/png/raspberry-pi-tor-proxy)

Your iDevice should now be able to use the SOCKS proxy. Yay! :)
