# Getting down to business with a Raspberry Pi PIco UPS

You may remember the picture of my shiny little To-enabled Pi on the last blog post about [monitoring the very same device through Tor](/secure-prometheus-ssh-hidden-service). It had just received [a shiny new PIco UPS backpack with a LiPO battery](http://www.pimodules.com/_pdf/_pico/UPS_PIco%20FAQ_V1.0.pdf) from [pimodules.com](http://pimodules.com/). It turns out, however, that I first had to hack that a bit to make it usable for my purposes.

For one thing, it was a wee bit too big to fit in the current case, so I had to make room by getting a new one. Which obviously made the Pi rather happy:

![salty-dog with its shiny new battery pack and a fitting case.](/jpeg/salty-dog-battery-pack-2.jpeg)

For another, the device actually requires you to run a Python script as root so that the firmware can figure out if your Pi is booted or not, and to get it to shut down if a power failure is imminent. Now, I don't know [if you follow my Twitter](https://twitter.com/jyujinX), but on there I'd previously quite proudly declared that I'd gotten rid of Python on the sucker, and I wasn't about to put it back on permanently just to get the UPS to work.

Besides, running a Python script as root for a critical subsystem, such as your UPS, seems... ill-advised, at the least. AND there's a reason Python is generally in /usr/bin and not /bin. Just saying.

## Yay for some minor reverse-engineering

So now to find out what that Python script actually does and if we really need it. I had a quick look at it and it seems straightforward enough: it sets up some GPIO pins, waits for a LOW on one of them and then shells out to "sudo shutdown -h now" (and folks, if you're reading this: you can probably drop the "sudo"... seeing as how your instructions say to run this as root).

So, doesn't sound like anything critical. Let's try that without the script. And it works... almost. The PIco will happily run, and even fail over to the battery! But sadly the little charging light never comes on :(. And then running the script makes it go on! Sadness :(.

It turns out that the script does something else: it sets another pin to HIGH and LOW in a loop. A quick glance at the manual suggests that, indeed, the PIco requires a pulse train on one of the pins. Confusingly, the manual states this pin needs to be #27, and the script does it on #22... but meh, we all make typos.

Armed with that information, I came up with this shell script to simulate what the Python script did:

    #!/bin/sh

    raspi-gpio set 22 op;
    #raspi-gpio set 27 ip pu;

    while true; do
      raspi-gpio set 22 dh;
      sleep 0.25;
      raspi-gpio set 22 dl;
    #  raspi-gpio get 27;
      sleep 0.25;
    done

Note how the commented lines simulate what the pin #27 query - which controls the system shutdown - did in the script. This is not necessary for the important part, which is getting the PIco to recognise that the Pi is all booted up and subsequently get it to charge.

## Introducing: picod

So, running this script will actually get the PIco to do its thing and charge the battery. You might be tempted to think we're done, but... not just yet.

The thing is, as much as I really don't want to have Python for my UPS... shell is not really an improvement, either. But this little script did verify that our only requirement was the pulse train on pin #22.

So, a few hours of boredom later, [I ended up just rewriting the whole thing in C and calling it *picod*](https://github.com/ef-gy/rpi-ups-pico). It's using the Linux sysfs GPIO interface to get it all sorted, which is surprisingly decent to work with. It also takes care of the pin #27 shutdown signal *and* it comes with a manpage! W00t!

Go give it a shot and tell me if anything's missing - I'm always open for suggestions ;). I even [documented all the source code](/documentation/rpi-ups-pico), for your hacking convenience!