[PHP] Just Say "No" To PHP's mysql(i) Interface
===============================================

I've recently "inherited" some PHP scripts for an otherwise pretty cool project. Now, I used to get paid for my PHP, back in the day. Doing medical trials. Back when PHP was considered the duck's nuts and you couldn't tell people otherwise. Even though some people really should've.

We spent a lot of time making sure our code was not exploitable. Naturally I assumed that everyone else was also taking those precautions. Because, you know, you always assume everyone else is doing the same stuff you're doing.

Anyway, this code made me realise that there's still people out there using PHP's mysql(i) interface. In rather... injectable ways. Basically creating SQL queries doing string concatenation. Which is bad, mmmkaaay? So I figure someone should reiterate this again: *Do NOT, _EVER_ do that!*

Just say _NO_. There's never a legit reason for this. Use PDO with prepared statements instead. The prepared statement part being really important here.

Seriously, never use anything but prepared statements.

Ever.

Period.

But all the examples I've seen are in mysql(i)!
-----------------------------------------------

Then apparently you [need some better examples](http://wiki.hashphp.org/PDO_Tutorial_for_MySQL_Developers).

But everyone is doing it!
-------------------------

Well, then everyone is fucking dumb, how about that?

(They're not really, your frame of reference is apparently just rather suboptimally skewed.)

But it's so much more complicated to use PDO!
---------------------------------------------

Bollocks.

Plus, the lack of random string concatenations make your code that much more readable. So you'll remember what you were doing in N weeks from now.

Anything But Prepared Statements Are Evil
=========================================

Here's some typical PHP to query some stuff using the standard mysql interface that PHP has - [taken from the aforementioned page on how to use PDO](http://wiki.hashphp.org/PDO_Tutorial_for_MySQL_Developers):

    $results = mysql_query(sprintf("SELECT * FROM table WHERE id='%s' AND name='%s'", 
                           mysql_real_escape_string($id), mysql_real_escape_string($name))) or die(mysql_error());

This is actually a decent example, as all the parameters are escaped using mysql_real_escape_string(). (Well, unless you expect $id to be a number.) Sadly, you're much more likely to see this piece of code written like this:

    $results = mysql_query("SELECT * FROM table WHERE id='$id' AND name='$name'") or die(mysql_error());

Or, even more likely...

    $results = mysql_query("SELECT * FROM table WHERE id='{$_REQUEST['id']}' AND name='{$_REQUEST['name']}'");

Guess what's wrong with that? Yep, stuff isn't escaped: you're just passing in user-controlled variables in one way or another. Also, error handling is dropped completely (surprising how often that happens). Your attacker could easily sneak in a SQL injection, e.g. by setting the id parameter to "'; drop database foo --". Or something.

But I always escape my query input!
-----------------------------------

Great, good job at duplicating what is essentially the job of prepared statements - as offered by PDO in the default PHP modules!

Also, you really aren't. Yeah, I know you _think_ you are, and you're probably even pretty thorough. But there's going to be that one contributor that gets something slipped past the radar. Or that one line you quickly hacked in at 3am during that spring right before release time. Or... you get the drift.

So how does PDO help in this case?
----------------------------------

Simple, from that same page:

    $stmt = $db->prepare("SELECT * FROM table WHERE id=? AND name=?");
    $stmt->execute(array($id, $name));
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

I'm not a big fan of using double quotes when not needed, or of writing SQL statements in capitals, for that matter. But it does clarify why you should always prepare your statements and use placeholders: No matter if $id or $name are actually strings or numbers, the type will be right. And passing them as an array to execute() means they will get escaped properly, and automatically.

Oh, and fetchALL(PDO::FETCH_ASSOC) will also fetch you a proper associative array with all the elements. No need to guess which part of the result has which column name and in which order. That means, no more switcheroos. Neat.

No need to worry about anything. Isn't that great?

Extra Bonus Features
====================

PDO will actually happily work with just about any common database you'd want to throw at it. Including PostgreSQL and SQLite. Huzzah!

Oh, and you can reuse those prepared statements. There's also a proper syntax around named parameters (basically use ":foo" and set a corresponding ":foo" array element with the value you like.)

So yeah, _please_ stop using mysql(i) and _stop creating queries with string concatenation_! It's not that hard to use something sane, and your users will thank you for it. In fact, it's more readable, too!

Be safe! Lose Scripts Drop Databases!
