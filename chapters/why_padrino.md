Before you dig into a new framework you ask yourself: "Why should I invest time in learning a new framework?". I will
not answer this with "it depends" (of course it depends on your situation) but rather provide you with all the
information so that you can decide on your own.


# Why would one use Padrino over Sinatra?

This question came from [@moneyscarf](https://twitter.com/moneyscarf "@moneyscarf").

Well Padrino is *based* on the excellent Sinatra micro-framework. Padrino inherits the simplicity and expressiveness of
Sinatra but gives you the extra sugar when you want to build non-trivial applications.


It **adds value** on Sinatra with a clear MVC approach, generators (for applications, controller, models, mailer), tag
helpers for reusing components in your views, offers localization, a basic project structure, several caching mechanisms,
mailers, and speeds up your development cycle by automatically server reloads.


Besides you can easily scaffold new applications very easy with available components for testing, rendering, JavaScript, CSS so
that you don't need to configure those for yourself (see http://padrinorb.com/#agnostic). If one component is missing,
you can add the missing part on your own by writing a custom generator.


Sinatra and Padrino goes hand in hand:


- it uses Sinatra router, but the controllers and routes are combined in the same space and you can use nested routing
(http://padrinorb.com/guides/controllers/routing/#nested-routes)
- it uses Sinatra rendering basic erb rendering, and Padrino makes it easy to use haml, slim, liquid instead).


So if you have a Sinatra applications and it gets bigger and bigger, then you may graduate to Padrino if you need it.


# Why Rails over Padrino?

There's a lot of folks who insist that people who don't know better should just use Rails for the amount of effort that
goes into security in Rails, versus having to know about XSS, CSRF, SQL Injection, etc. In Sinatra/Padrino you need to add Rack Middleware
to have those protections.

The greatest strength of Rails is it's claim "convetion over complexity". It assumes common basis for testing,
debugging, and app structure to generate all of this for you so that you can work trouble-free as well as creative on
your tasks. For the software you write in Rails, you can be sure that the same parts (like ActiveRecord) are always in
use.


Downsides of Rails? It's opiniated. Many people nowadays say that Rails is bad. But why? The most told problem with is
that it is *bloated* and not easy to learn in the beginning. Bloated means in this context, that many things are loaded
on the startup time of your application that can influence the performance of your application.


Padrino gives you in comparison to Rails more power of choice. The use of Modularity components results in low-lever
design. But you have to be careful of the potential to have a more complex and flexible architecture which can be
unstable if you decide to use the wrong components when designing your application.


