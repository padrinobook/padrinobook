## Motivation

Shamelessly I have to tell you that I'm learning Padrino through writing a book about instead of doing a blog post
series about it. Besides I want to provide up-to-date documentation for Padrino which is at the moment scattered around
the Padrino's web page [padrinorb.com](http://www.padrinorb.com/).


Although Padrino borrows many ideas and techniques from it's big brother [Rails](http://rubyonrails.org/) it aims to be
more modular and allows you to interchange various components with considerable ease. You will see this when you will
the creation of two different application we are going to build throughout the book.


### Why Padrino With The Developer Point of View

Nothing is enabled without explicit choice. You as a programmer know what database is best for your application, which
Gems don't carry security issues. If you are honest to yourself you can only learn a framework by heart if you go and
digg under the hood. Because Padrino is so small it is easy to go through the code to understand most of the source.
There is no need for monkey-patching, almost everything can be changed via an API. Padrino is rack-friendly, so a lot of
techniques that are common to Ruby can be reused.  Having a low stack frame makes it easier for debugging.  The best
Rails convenience parts like `I18n` and `active_support` are available for you.


### Why Padrino In A Human Way?

Before going any further you may ask: Why should you care about learning and using another web framework? Because you
want something that is *easy to use*, *simple to hack*, and *open to any contribution*. If you've done
Rails before, you may reach the point where you can't see how things are solved in particular
order. In other words: There are many layers between you and the core of you application. You want to have the freedom
to chose which layers you want to use in your application. This freedoms comes with the help of the
[Sinatra framework](http://www.sinatrarb.com/).


Padrino adds the core values of Rails into Sinatra and gives you the following extras:


- `orm`: Choose which adapter you want for a new application. The ones available are: datamapper, sequel, activerecord,
  mongomapper, mongoid, and couchrest.
- `multiple application support`: Split you application into small, more manageble-and-testable parts that are easier to
  maintain and to test.
- `admin interface`: Provides an easy way to view, search, and modify data in your application.


When you are starting a new project in Padrino only a few files are created and, when your taking a closer look at them,
you will see what each part of the code does. Having less files means less code and that is easier to maintain. Less code
means that your application will run faster.


With the ability to manage different applications, for example: for your blog, your image gallery, or your payment
cycle; by separating your business logic, you can share data models, session information and the admin interface between
them without duplicating code.


[Remember](https://speakerdeck.com/daddye/padrino-framework-0-dot-11-and-1-dot-0): "**Be tiny. Be fast. Be a Padrino**"

%%/* vim: set ts=2 sw=2 textwidth=120: */
