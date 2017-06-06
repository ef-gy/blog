# `fortuned`, the second

So, it's been a while since I wrote about
[that fortune cookie server](/project:fortune). I had sort of gotten bored of
it, you know how that happens. But over the long weekend, I found some time to
revisit that - this time as a proper API. Since I like to make fun of this whole
"frob as a service" thing. And because I can.

So I came up with
[this API for fortune cookies](https://github.com/ef-gy/fortuned/blob/master/README.md).
It's [all on GitHub](https://github.com/ef-gy/fortuned), doesn't have an SLA,
because that would be silly, but it did just get its first release. Long weekend
and all.

Like any good microservice thingy, you can query it with curl:

    curl https://api.ef.gy/fortune

Which will get you a random fortune cookie quote. If you set the `Accept` header
just right, you can also change the output format to either JSON or XML. Yay.
You can also request a specific cookie, though the ID numbers aren't really
guaranteed to be the same between restarts of the backend. The above API docs
have more details on all of that.

As a fun hack, in case you don't want to install the full fortune programme on
your own host, you can put this in your `.profile`:

    alias fortune='curl https://api.ef.gy/fortune'

And now you can use the `fortune` programme on your local host and be merry.
This is extra neat on OSX, which doesn't offer a native `fortune` programme.

## Overkill

No silly mini-API is complete without its own, dedicated node.js NPM client
package.
[So obviously I created one](https://www.npmjs.com/package/fortuned-api-client).
This one has the added bonus of also coming with a dedicated client script, in
case you don't trust curl, so you can do this:

    npm -g install fortuned-api-client

And then this to get your cookie:

    fortuned-cli.js

Yeah, the name isn't all that pretty, but there already was a `fortune` package
on NPM. And it had nothing to do with cookies. So weird.

Of course
[that also needed a RunKit example](https://runkit.com/59355a35962215001232782e/59357464551d0a0012fe557b),
as one does these days.

## But wait, there's more!

None of this would be complete without someone trying to jQuery the API, so in
the spirit of modern design,
[have a JSFiddle demo for how to do that](https://jsfiddle.net/jyujin/t87whwjr/62/),

I wonder if embedding works... it gave me the worst headache on GitHub:

<iframe width="100%" height="300" src="//jsfiddle.net/jyujin/t87whwjr/62/embedded/js,html,css,result/dark/" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

If you saw that, then good for you! :P
