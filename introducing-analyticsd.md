Introducing: analyticsd
=======================

A few months ago, I'd blogged about [tracking bad SSH logins using Google
Analytics](/google-analytics-ssh). This works fine, but it has the disadvantage
of having to run a shell script as a daemon. I didn't quite like that, so I
ended up
[writing that once more in node.js](https://www.npmjs.com/package/analyticsd).

This might surprise some people, considering how I tend to complain about
JavaScript a lot. However, it turns out that node.js is one of the few languages
(or variants of one) that are likely to be available on most servers while also
containing everything needed to implement the daemon: an HTTP client, regular
expressions and file and process manipulation.

Features
========

analyticsd is not only a cleaner rewrite - as clean as possible in JS, anyway -
but it also packs more of a punch. Apart from doing the same analysis for SSH
logs, it can also:

  * analyse kippo honeypot logs
  * analyse nginx ("combined" format) HTTP logs
  * analyse scanlogd log messages
  * upload certain IP subsystem stats from /proc (on Linux)
  * tag Tor traffic as such
  * spawn itself as a proper daemon

The basic idea is still the same: tail log files and apply regular expressions
on each line, then mangle the result of that and send it to Google Analytics via
its Measurement Protocol.

The one anti-feature that I've yet to work out, is that it requires shelling out
to the GNU tail command. That's because tailing files that might be moved or
deleted is a bit of a pain in the neck, and considering how small a binary that
is, it wasn't worth fixing properly yet.

Well, and I don't quite like that it's in node.js as opposed to plain C++. I'm
working on another daemon that does roughly the same for Prometheus, written in
C++: [imperiald](https://github.com/jyujin/imperiald) - but that's still new and
probably buggy. Still, it's getting there and may eventually supersede
analyticsd, so keep an eye on it if this is of interest to you.

HTTP Logs
=========

It might seem somewhat weird that I decided to add support for HTTP logs to the
daemon - after all, the whole purpose of Google Analytics is to analyse traffic,
and it provides really neat JavaScript glue code that does all the hard lifting
for you, and the only thing you need to do is to add this to your templates so
this gets served on every request to your server.

The downside of this, is that this will only track accesses from clients with JS
enabled in their browsers. As it turns out, this is unlikely to be the case with
Tor users - or generally privacy-minded folks. Or feed readers.

HTTP logs contain almost all of the information that the JavaScript client can
gather, however, and by analysing and uploading those we can make use of almost
all of the awesome features of Google Analytics - even without relying on the
client-side JavaScript snippet. So we get the best of both worlds, more or less.

Installation
============
analyticsd is provided as a standard npm package, which means installation is as
simple as:

    # npm install -g analyticsd

The _-g_ flag makes npm install the package globally, so that it can be used on
the command line. Once that has been installed, use this:

    # analyticsd --tid UA-XXXXX-Y

Note that you probably want to use a separate property ID to test this. The
defaults should work fine on Debian. To find out about more options, use

    # man analyticsd

Yay for manpages. :)

Once you've set everything up just the way you like it, use:

    # analyticsd --tid UA-XXXXX-Y --daemon

This would fork to the background, running analyticsd as a proper system daemon.
The package doesn't come with an init script, so you'll want to add a line like
this to your /etc/rc.local - or similar, depending on your distribution.

Feedback
========

If you find any bugs, or would like certain features to be added, [please use
the bug tracker on GitHub](https://github.com/ef-gy/analyticsd/issues) to
provide feedback. Especially to request new features :).
