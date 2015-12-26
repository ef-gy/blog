# Feedly Can't Handle Full XHTML Content in atom:content

I got a heads up about this a few days ago. As it turns out, [the most excellent feed reader Feedly](http://feedly.com/) can't handle atom:content nodes with full XHTML content, i.e. of the form:

    <atom:content type="application/xhtml+xml">
      <xhtml:html ...>
        <!-- ... -->
      </xhtml:html>
    </atom:content>

The content gets rendered all sad and unformatted, with just the literal text content of the nodes rendered. Like so:

![This is definitely not how this is supposed to be rendered.](/png/sad-feedly-feed)

Bad feed renders make kittens cry!

## And here's how to make it work

Atom's RFC specifically allows this. However, it also offers an alternative representation for XHTML, which is rather ugly but is in fact supported by Feedly. Oh joy!

    <atom:content type="xhtml">
      <xhtml:div>
        <!-- xhtml:html/xhtml:body/* contents go here -->
      </xhtml:div>
    </atom:content>

This is extremely hacky. The RFC states that the contents of an atom:content with this type attribute set *must* be exactly one xhtml:div, and the contents of *that* in turn are what is supposed to be used as the content of the atom:entry that it's attached to. [See section 4.1.3.3 of RFC 4287](https://tools.ietf.org/html/rfc4287#page-15) - specifically the third and fourth paragraphs.

Ugh. Div-abuse! Anyway, we can easily transform one form to the other, with the help of a pretty straightforward XSLT stylesheet:

    <?xml version="1.0" encoding="UTF-8"?>
    <xsl:stylesheet
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                  xmlns:xhtml="http://www.w3.org/1999/xhtml"
                  xmlns:atom="http://www.w3.org/2005/Atom"
                  xmlns="http://www.w3.org/2005/Atom"
                  exclude-result-prefixes="xhtml atom"
                  version="1.0">
      <xsl:output method="xml" version="1.0" encoding="UTF-8"
                  indent="no"
                  media-type="application/atom+xml"/>

      <xsl:strip-space elements="*" />

      <xsl:template match="@*|node()">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>

      <xsl:template match="atom:content[@type='application/xhtml+xml']">
        <content type="xhtml">
          <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="xhtml:html/xhtml:body/*"/>
          </div>
        </content>
      </xsl:template>
    </xsl:stylesheet>

Further, if we use nginx we can cache the result of this transformation - or apply it on the fly - and serve the mangled content to Feedly in particular:

    map $http_user_agent $capa {
        default "default";
        ~Feedly "dumb";
    }

    # ...

    server {
        # ...

        location ~ /(?<type>atom)/(?<file>.+) {
            alias $documentRoot/.cache/$hostnameproper/;
            try_files $file.$capa.$type $file.$type $file =404;

            types {
                application/atom+xml atom;
            }

            expires 1h;
        }

        # ...
    }

There's probably other feed readers around that would have the same issue, so this snippet would only need minor modification to that map regex there to help out with those. Oh and, obviously the location block would need to be adjusted according to however you expose your atom files. This variant uses try_files to search for foo.dumb.atom along with foo.atom.

With all of this applied, the feed looks much better:

![Yay! That got it to be less sad! :3](/png/working-feedly-feed)

It even gets the cover page to work:

![Cover page! Whoo! :3](/png/working-feedly-cover)

So that just leaves the question of why this rather hacky way of representing XHTML content made it into the RFC in the first place, and why some otherwise really good feed readers can't deal with properly formatted XHTML. *Sigh*.