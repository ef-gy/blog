# A Primer on *div*-Abuse

*div* is one of the universal staples of web design. It really shouldn't be. The same goes for *span*. It's not like these tags are never the right tool for the job, but most of the time they're used they really shouldn't have been.

The problem is that using these tags when they wouldn't be necessary turns your HTML into a meaningless mess, which at the same time will make CSS to style it a lot harder to read and write than it would otherwise have to be - which in turn leads to people thinking that CSS is hard, when really it's not. So I've compiled this handy list to highlight the more common abuse cases out there. It also requires extra bandwidth, and I've yet to see a single site doing any of the following that then actually set up proper compression to fix it - or the extra whitespace and HTML comments people are so fond of, at that.

Please note that I made none of these examples up. I literally keep seeing them every time I use an HTML inspector on just about any random site.

## *div* for marking paragraphs

... or in general as a replacement for dedicated HTML elements. This might be due to a lack of knowledge, or just plain laziness. Either way, I'm *literally* seeing constructs like this:

    <div class="paragraph"> <!-- bonus points for using id="paragraph"! -->
      <!-- ... Lorem ipsum... -->
    </div>

With accompanying CSS like so:

    div.paragraph {
      /* ... */
    }

Here's the thing: HTML has dedicated tags for things. In this case, you're trying to use *p*. Not only is that a lot shorter, it'll also carry the intended semantic meaning. So write it like this:

    <p>
      <!-- ... Lorem ipsum... -->
    </p>

With nice and tidy CSS:

    p {
      /* ... */
    }

The same goes for other things often replaced with *div*s. Popular candidates are tables and especially lists - the latter of which does not just apply to counted lists and bullet points, but also quite especially for things like navigation menus.

## *div* in place of *span*

Some people only seem to know about *div*, the ubiquitously blank HTML block element for styling things, but not about *span*. The latter is pretty much the same, except that it's an inline element, so if you absolutely *must* use a blank element, and you're tempted to do this:

    div.inline {
      display: inline;
      /* ... */
    }

You're *really* doing it wrong. Use this entirely equivalent form instead:

    span {
      /* ... */
    }

Yes, *span* is a character longer than *div*, but then you'll save on not needing the class attribute. Better yet, find out why you were trying to use an inline markup block instead, and realise you probably just wanted to add some form of *em*phasis to a portion of text.

## *span* for making text bold/italic/etc in place of *em*

Whenever you use *span* (or the old *font*) to mark text as bold, italic or add other text highlighting, ask yourself: why are you adding this markup? 9 out of 10 times, it'll be because you want to *emphasise* some portion of text. There's an element for that in HTML. It's called *em*. Which is shorter than *span*, and it carries the meaning you intended.

Using *em* in place of, say, this bit of HTML:

    <p>
      Lorem <span class="italic">ipsum</span> dolor
      <!-- ... -->
    </p>

And this bit of CSS:

    span.italic {
      /* ... */
    }

Makes it a lot cleaner, like this:

    <p>
      Lorem <em>ipsum</em> dolor
      <!-- ... -->
    </p>

And this:

    em {
      /* ... */
    }

## The obnoxious *div* with *id="content"*

ID labels can differ, but in general this is a single *div* inside *body* that contains all the actual page contents to display. Sometimes accompanied by the even worse *div id="body"*, which surrounds the content block.

From what I've seen, this is often used in conjunction with fixed-width layouts, a class of evil on its own. The general use case here is to give the content a fixed width and to then align the block either centred or on the left of a browser window that will invariably be larger than the fixed width layout. Often in a misguided attempt at supporting irrelevant old browsers where CSS may not have worked as intended on *html* and *body* elements.

Regardless of why you're doing it, generally you're trying to have an HTML element to style that is inside another HTML element you can style. Like so:

    <body>
      <div id="content">
        <!-- ... -->
      </div>
    </body>

And the CSS goes something like this:

    body { /* or div#body in the worse case */
      /* ... */
    }

    div#content {
      /* ... */
    }

And therein lies the abuse case: you *always* have exactly that in a valid HTML file. Because that *requires* you to have an *html* root element, which you can style just like any other element. Obsolete browsers with weird bugs notwithstanding, this works exactly the same way. Your HTML and CSS would then be:

    <html>
      <!-- ... -->
      <body>
        <!-- ... -->
      </body>
    </html>

And the CSS is much tidier:

    html {
      /* ... */
    }

    body {
      /* ... */
    }

Here's the thing: *html* and *body* are both perfectly fine HTML block elements, so you can style them as such. At the same time, they're also unique in your HTML file. So using a *div* with an *id* attribute is quite pointless, as you're just adding more elements for literally no reason.

## *div*s to add *id* attributes for CSS styling

Here's another fun one: I've seen a lot of uses of *div* where the intent was to simply add an *id* to uniquely style a single other element. That would look like this:

    <div id="navigation">
      <ul>
        <!-- ... -->
      </ul>
    </div>

Then styled as such:

    div#navigation ul {
      /* ... */
    }

*id* is actually a valid attribute all over HTML - even for the root *html* and *body* node, if you need to use a single CSS file for several different layouts. The same is true for *class*, by the way. Anyway, this is easily rewritten as:

    <ul id="navigation">
      <!-- ... -->
    </ul>

Styled as:

    ul#navigation {
      /* ... */
    }

Now, in theory it had been a good idea to use an *id* in this case, as there's bound to be more unordered lists on a page than whatever you're using for your menu - albeit *ol* might make more sense for a menu, seeing as you may want the menu to list elements in a specific order. But I wanted to stick with actual examples I keep seeing in the wild, so... not going to mention *nav* or *dl*/*dt*/*dd* or *ol*.

So in practice, introducing that extra *div* only makes things a lot harder for you. So just go ahead and put that *id* on whatever element you're actually trying to style.
