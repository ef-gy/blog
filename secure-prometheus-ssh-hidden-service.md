# Secure Prometheus Monitoring via SSH over Hidden Service

So you've set up monitoring via Prometheus, e.g. [by following a guide like this one](https://machineperson.github.io/monitoring/2016/01/04/exporting-apache-metrics-to-prometheus.html). The obvious next step is to make sure all the servers you want to monitor this way are actually reachable by Prometheus - and you definitely want to make sure your monitoring data isn't tampered with in transit.

This is reasonably straightforward if you control or trust the network, but if your monitoring targets are on remote networks and will traverse unsafe networks, such as the internet... well... not so much, then. There, you basically need to solve three problems:

  * Make it possible for Prometheus to scrape its target, no matter where it is.
  * Authenticate the target, and Prometheus to the target.
  * Prevent malicious users from messing with the data in flight.

In particular the reachability is a bit of doozie - the inspiration for all this was basically that I wanted to monitor my [portable, battery-powered Raspberry Pi Tor gateway](/raspberry-pi-tor-gateway) from one of my servers. The typical way to do that is to play with my firewall at home and use NAT to allow inbound connections to the Pi, but since the thing is portable that wouldn't always work - for instance when the Pi is resting comfortably in my backpack at work.

To do this in a reasonably roundabout way, we bring together a few different programmes that were most definitely not meant to work together:

  * [Prometheus](https://prometheus.io/), to do the monitoring.
  * [Tor Hidden Services](https://torproject.org/), to let us access our monitoring target without having to punch holes in firewalls and add some trust that we're talking to the right server.
  * SSH, to authenticate Prometheus to our monitoring target and prevent data from being tampered with in-flight.
  * socat (or netcat, etc), to allow the SSH client to talk to our Hidden Service.
  * [eldritchd](https://github.com/ef-gy/eldritchd) (or autossh, etc), to make sure our SSH tunnel actually stays alive.
  * Some Prometheus target. It'd be boring without that - I'll go with [imperiald](https://github.com/ef-gy/imperiald) here, because that's basically a node_exporter that I wrote before I knew about [node_exporter](https://github.com/prometheus/node_exporter).

I've a feeling that lineup would make Cronenberg proud. Basically, we'll get this:

![Prometheus dashboard for the imperiald CPU load metrics.](/png/prometheus-dashboard-imperiald-cpu)

From this:

![salty-dog, your friendly neighborhood Tor gateway.](/jpeg/salty-dog-battery-pack-1)

Wherever. With Science! And Tor!

Sound good? Let's get to it, then!

## Setting up the SSH Hidden Service

The Hidden Service needs to be set up on the monitoring target. Our sample machine will be my Raspberry Pi, which [I've previously set up Tor on](/raspberry-pi-tor-gateway). It's also configured to connect to WiFi networks automatically in places I usually hang out at, and it also has an SSH server installed.

To set up the Hidden Service, we really only need to add the following lines to /etc/tor/torrc:

    HiddenServiceDir /srv/tor
    HiddenServicePort 22 127.0.0.1:22

Tor will create the necessary private key and do all the plumbing the next time it's restarted. To make sure that works, we also need to create the directory we just told it to put files in:

    # mkdir -p /srv/tor
    # chown debian-tor /srv/tor

Now that we're all set up, we can restart Tor:

    # /etc/init.d/tor restart

This'll take a bit longer than usual, as Tor needs to create a new private key. But once that's done, we're pretty much done with this step. Your shiny new .onion address can be found in the HiddenServiceDir's *hostname* file:

    # cat /srv/tor/hostname
    foobarbaz1234.onion

Take note of this address, and move on to the next step. Also note that we *did not* create a HiddenServicePort for *anything but SSH*. We don't want to expose the Prometheus target's HTTP server directly!

## Setting up SSH to access Hidden Services

On the machine running Prometheus, you'll need to be able to talk to your shiny new SSH Hidden Service. Unfortunately, OpenSSH can't use SOCKS proxies directly, which is what the Tor client offers for clients to connect through Tor. Fortunately it does have a pretty slick ProxyCommand that lets us abuse *socat* to help SSH connect.

You could substitute *netcat* or another programme for this, but I just like *socat*, so... meh.

If you haven't done so already, install *socat*, *tor* and *openssh*:

    # apt-get install socat tor ssh

Then, configure the SSH client to use Tor for .onion addresses by adding the following to /etc/ssh/ssh_config (or to a user's ~/.ssh/config):

    Host *.onion
      ProxyCommand socat STDIO SOCKS4A:127.0.0.1:%h:%p,socksport=9050

    Host myhiddenservice
      HostName foobarbaz1234.onion

The first block here is what allows .onion addresses to work with SSH - it assumes socat is installed and Tor is running locally, on the default port 9050.

The second block is just to give your SSH Hidden Service a more memorable name. That part is optional, but this would be a good place to e.g. put the hostname so you can just type "ssh hostname" to connect through Tor.

Once you're done with all that, do a quick connection test to make sure you can actually connect to your monitoring target:

    $ ssh myhiddenservice

This might be a bit slower than usual, but you should be able to log on and get a shell.

Assuming that works, you've now already solved all of the basic problems: no matter where your target machine is, as long as it has Tor access you can now access it without having to worry about local firewalls. Due to the way Hidden Services work, you can rest assured you're talking to the right box, and SSH authenticates both parties *and* makes sure the data stream isn't tampered with.

Now to get Prometheus talking through all this...

## SSH Port Forwarding

SSH has a somewhat little-known feature built in that allows you to listen on a TCP port on one side of the connection and plumb it to a different TCP port on the other side of the connection - again, all without requiring you to tell your firewall about it, but only assuming you can get from one host to the other via SSH.

Note that this section assumes that you're running the following as an unprivileged user that can log onto your target machine without a password using SSH key files or certificates. [I've prepared a handy guide on all of that in case you forgot to bring yours](/hardening-ssh).

Since we already made SSH connections work in the previous step, creating this tunnel is dead simple. Assuming your Prometheus target is exporting metrics at port 9091, and the local port for scraping should be 2345, you'd simply run this:

    $ ssh myhiddenservice -L 2345:127.0.0.1:9091 -N

And there we go. The *-L* option sets up the port forwarding as described, and the *-N* option makes sure that SSH does not start a shell - which we don't need. As long as that command is running, you can access your metrics at localhost:2345. To test this, use curl on your Prometheus host:

    $ curl http://127.0.0.1:2345/metrics

This obviously requires your target machine to have whatever daemon you're trying to monitor running on its port 9091.

The only drawback to this, is that OpenSSH won't just reconnect if something happens to your SSH connection. You can fix that by using *autossh* in place of *ssh*, which is straightforward enough.

You may remember that I mentioned *eldritchd* in the outline. This is a daemon I cooked up that tries to revive programmes if they die - and it also exports some Prometheus metrics of its own. It's still very much a work in progress, but if you want to give it a shot then just [install it from sources](https://github.com/ef-gy/eldritchd) and prepend it to the command line:

    $ eldritchd -- ssh myhiddenservice -L 2345:127.0.0.1:9091 -N

To make it spawn in the background, add the 'daemonise' flag:

    $ eldritchd daemonise -- ssh myhiddenservice -L 2345:127.0.0.1:9091 -N

And to enable monitoring...

    $ eldritchd daemonise http:127.0.0.1:3456 -- ssh myhiddenservice -L 2345:127.0.0.1:9091 -N

... which would also open port 3456 for Prometheus to scrape. It doesn't export all that many metrics, yet, but I'll be adding things along the way. One of the metrics it does have, is a counter of how many times it had to respawn your tunnel, which is a good metric to have.

## Configuring Prometheus

This final step is fairly straightforward. Simply get Prometheus to scrape localhost:2345 - or whatever port you picked for the SSH tunnel. This should get you started:

    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'system'
      
        target_groups:
          - targets: ['localhost:2345']
            labels:
              instance: 'myhiddenservice'

If you set up *eldritchd* with monitoring in the previous step, you could also monitor that separately. Just add another job that scrapes localhost:3456 - and again, modulo whatever port you picked.

Now start Prometheus in the usual way...

    $ prometheus -config.file=prometheus.yml

... and enjoy your shiny new super-secure Cronenberg'd monitoring setup.

## Further Considerations

### Removing SSH from the chain

You could forego SSH and simply use socat in its place and set up the Hidden Service to allow access to the monitoring target directly instead of SSH if you don't mind others seeing your monitoring data without authenticating through SSH.

This might be slightly more appealing if Prometheus could scrape UNIX sockets directly, as Tor allows setting up Hidden Services through that, and the port on the Hidden Service address is pretty much virtual anyway. Socat then also allows routing to a UNIX socket as opposed to TCP, which would make the potential attack surface slightly smaller by opening fewer TCP sockets.

### Prometheus Service Discovery

This doesn't play all that nice with Prometheus' service discovery options. You could create a wrapper to use file-based SD that creates a JSON file whenever a link is established and removes the file when it's done. I'll probably end up doing that and throw in something to assign random ports for all parts of this.