# Introduction and Setup

Why another book about how to develop an application (app) in Rails? But wait, this book should give you a basic
introduction on how to develop a web app with [Padrino](http://www.padrinorb.com/ "Padrino"). Padrino is "The Elegant
Ruby Web Framework". Padrino is based upon [Sinatra](http://www.sinatrarb.com/ "Sinatra"), which is a simple Domain
Specific Language for quickly creating web apps in Ruby. When writing Sinatra apps many developers miss some of the
extra conveniences that Rails offers, this is where Padrino comes in as it provides many of these while still staying
true to Sinatra's philosophy of being simple and lightweight. In order to understand the mantra of the Padrino webpage:
"Padrino is a full-stack ruby framework built upon Sinatra" you have to read on.


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



## Tools

I won't tell you which operating system you should use - there is an interesting discussion on
[hackernews](http://news.ycombinator.com/item?id=3786674 "hackernews"). I'll leave it free for the reader of this book
which to use, because basically you are reading this book to learn Padrino.


To actually see a running padrino app, you need a web browser of your choice.  For writing the application, you can
either use an Integrated Development Environment (IDE) or with a plain text editor.


Nowadays there are a bunch of Integrated Development Environments (IDEs) out there:


- [RubyMine by JetBrains](http://www.jetbrains.com/ruby/ "RubyMine") - commercial, available for all platforms
- [Aptana RadRails](http://www.aptana.com/products/radrails "Aptana RadRails") - free, available for all platforms


Here is a list of plain text editors which are a popular choice among Ruby developers:


- [Emacs](http://www.gnu.org/s/emacs/ "Emacs") - free, available for all platforms.
- [Gedit](http://projects.gnome.org/gedit/ "Gedit") - free, available for Linux and Windows.
- [Notepad++](http://notepad-plus-plus.org/ "Notepad ++") - free, available only for Windows.
- [SublimeText](http://www.sublimetext.com "SublimeText") - commercial, available for all platforms.
- [Textmate](http://macromates.com/ "Textmate") - commercial, available only for Mac.
- [Vim](http://www.vim.org/ "Vim") - free, available for all platforms.


All tools have their strengths and weaknesses. Try to find the software that works best for you. The main goal is that
you comfortable because you will spend a lot of time with it.


## Ruby Knowledge

For any non-Ruby people, I strongly advise you to check out one of these books and learn the basics of Ruby before
continuing here.


- [Programming Ruby](http://pragprog.com/book/ruby3/programming-ruby-1-9 "Programming Ruby") - the
  standard book on Ruby.
- [Poignant Guide to Ruby](http://www.scribd.com/doc/8545174/Whys-Poignant-Guide-to-Ruby "Poignant Guide To Ruby") -
  written by the nebulous programmer [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff "Stiff") in
  an entertaining and educational way.


In this book, I assume readers having Ruby knowledge and will not be explaining every last detail. I will, however,
explain Padrino-specific coding techniques and how to get most parts under test.



## Installing Ruby With rbenv

Instead of using the build-in software package for Ruby of your operating system, we will use
[rbenv](https://github.com/sstephenson/rbenv/ "rbenv") which lets you switch between multiple versions of Ruby.


First, we need to use [git](http://git-scm.org) to get the current version of rbenv:


```bash
$ cd $HOME
$ git clone git://github.com/sstephenson/rbenv.git .rbenv
```


In case you shouldn't want to use git, you can also download the latest version as a zip file from
[Github](http://github.com).


You need to add the directory that contains rbenv to your `$PATH` environment variable.  If you are on Mac, you have to
replace `.bashrc` with `.bash_profile` in all of the following commands):


```bash
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
```


To enable auto completion for `rbenv` commands, we need to perform the following command:


```bash
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
```


Next, we need to restart our shell to enable the last changes:


```bash
$ exec $SHELL
```


Basically, there are two ways to install different versions of Ruby: You can compile Ruby on your
own and try to manage the versions and gems on your own, or you use a tool that helps you.


**ruby-build**

Because we don't want to download and compile different Ruby versions on our own, we will use the
[ruby-build](https://github.com/sstephenson/ruby-build "ruby-build") plugin for rbenv:


```bash
$ mkdir ~/.rbenv/plugins
$ cd ~/.rbenv/plugins
$ git clone git://github.com/sstephenson/ruby-build.git
```


If you now run `rbenv install` you can see all the different Ruby version you can install and use for different Ruby
projects. We are going to install `ruby 1.9.3-p392`:


```bash
$ rbenv install 1.9.3-p392
```


This command will take a couple of minutes, so it's best to grab a Raider, which is now known as
[Twix](http://en.wikipedia.org/wiki/Twix "Twix").  After everything runs fine, you have to run `rbenv rehash` to rebuild
the internal rbenv libraries. The last step is to make Ruby 1.9.3-p392 the current executable on your machine:


```bash
$ rbenv global 1.9.3-p392
```


Check that the correct executable is active by exexuting `ruby -v`. The output should look like:


```bash
$ 1.9.3-p392 (set by /home/.rbenv/versions)
```


Now you are a ready to hack on with Padrino!



## Hello world

The basic layout of our application is displayed on the following image application:


![Figure 1-1. Start page of the app](images/01/application_overview.jpg)


It is possible that you know this section from several tutorials, which makes you even more comfortable with
your first program.


Now, get your hands dirty and start coding.


First of all we need to install the *padrino gem*. We are using the last stable version of Padrino (during the release of
this book it is version **0.11.2**). Execute this command.


```bash
$ gem install padrino
```


This will install all necessary dependencies and gets you ready to start. Now we will generate a fresh new Padrino
project:


```bash
$ padrino generate project hello-world
```


Let's go through each part of this command:


- `padrino generate`: Tells Padrino to execute the generator with the specified options. The options can be
  used to create other **components** for your app, like a **mailing system** or an **admin panel** to manage your
  database entries. We will handle these things in a future chapter. A shortcut for generate is `g` which we will use
  in all following examples.
- `project`: Tells Padrino to generate a new app.
- `hello-world`: The name of the new app, which is also the directory name.


The console output should look like the following:


```bash
  create
  create  .gitignore
  create  config.ru
  create  config/apps.rb
  create  config/boot.rb
  create  public/favicon.ico
  create  public/images
  create  public/javascripts
  create  public/stylesheets
  create  tmp
  create  .components
  create  app
  create  app/app.rb
  create  app/controllers
  create  app/helpers
  create  app/views
  create  app/views/layouts
  create  Gemfile
  create  Rakefile
skipping  orm component...
skipping  test component...
skipping  mock component...
skipping  script component...
applying  slim (renderer)...
   apply  renderers/slim
  insert  Gemfile
skipping  stylesheet component...
identical  .components
   force  .components
   force  .components

=================================================================
hello-world is ready for development!
=================================================================
$ cd ./hello-world
$ bundle
=================================================================
```


The last line in the console output tells you the next steps you have to perform. Before we start coding our app, we
need some sort of package management for Ruby gems.


Ruby has a nice package manager called [bundler](http://gembundler.com/ "Bundler") which installs all necessary gems in
the versions you would like to have for your project. This makes it very easy for other developers to work with your
project even after years. The [Gemfile](http://gembundler.com/gemfile.html "Gemfile") declares the gems that you want to
install. Bundler takes the content of the Gemfile and will install every package declared in this file.


To install bundler, execute the following command and check the console output:


```bash
$ gem install bundler
  Fetching: bundler-1.3.5.gem (100%)
  Successfully installed bundler-1.3.5
  1 gem installed
```


Now we have everything we need to run the `bundle` command and install our dependencies:


```bash
$ cd hello-world
$ bundle
  Fetching gem metadata from http://rubygems.org/.........

  Using rake ...
  Using ...
  Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
```


Let's open the file `app/app.rb` (think of it as the root controller of your app) and insert the following code before
the last `end`:


```ruby
module HelloWorld
  class App < Padrino::Application

    get "/" do
      "Hello World!"
    end

  end
end
```


Now run the app with:


```bash
$ bundle exec padrino start
```


Instead of writing `start`, we can also use the `s` alias. Now, fire up your browser with the URL
<http://localhost:3000> and see the `Hello World` Greeting being printed.


Congratulations! You've built your first Padrino app.


### Directory structure of Padrino

Navigating through the various parts of a project is essential. Thus we will go through the basic file structure of the
*hello-world* project. The app consists of the following parts:


```bash
|-- Gemfile
|-- Gemfile.lock
|-- app
|   |-- app.rb
|   |-- controllers
|   |-- helpers
|   `-- views
|       `-- layouts
|-- config
|   |-- apps.rb
|   |-- boot.rb
|   `-- database.rb
|-- config.ru
|-- public
|   |-- favicon.ico
|   |-- images
|   |-- javascripts
|   `-- stylesheets
`-- tmp
```


We will go through each part.


- **Gemfile**: The place where you declare all the necessary *gems* for your project. Bundle takes the content of this
  file and installs all the dependencies.
- **Gemfile.lock**: This is a file generated by Bundler after you run `bundle install` within your project. It is a
  listing of all the installed gems and their versions.
- **app**: Contains the "executable" files of your project, along with the controllers, helpers, and views of your app.
  - **app.rb**: The primary configuration file of your application. Here you can enable or disable various options like
    observers, your mail settings, specify the location of your assets directory, enable sessions, and other options.
  - **controller**: The controllers make the model data available to the view. They define the URL routes that are
    callable in your app and defines the actions that are triggered by requests.
  - **helper**: Helpers are small snippets of code that can be called in your views to help you prevent repetition -
    by following the `DRY` (Don't Repeat Yourself) principle.
  - **views**: Contains the templates that are filled with model data and rendered by a controller.
- **config**: General settings for the app, including hooks (explained later) that should be performed before or after
  the app is loaded, setting the environment (e.g. production, development, test) and mounting other apps within the
  existing app under different subdomains.
  - **apps.rb**: Allows you to configure a compound app that consists of several smaller apps. Each app has it's own
    default route, from which requests will be handled. Here you can set site wide configs like caching, csrf
    protection, sub-app mounting, etc.
  - **boot.rb**: Basic settings for your app which will be run when you start it. Here you can turn on or off the
    error logging, enable internationalization and localization, load any prerquisites like HTML5 or Mailer helpers,
    etc.
  - **database.rb**: Define the adapters for all the environments in your application.
- **config.ru**: Contains the complete configuration options of the app, such as which port the app listens to, whenever
  it uses other Padrino apps as middleware and more. This file will be used when Padrino is started from the command
  line.
- **public**: Directory where you put static resources like images directory, JavaScript files, and style sheets. You
  can use for your asset packaging sinatra-assetpack or sprockets.
- **tmp**: This directory holds temporary files for intermediate processing like cache, tests, local mails, etc.


## Conclusion

We have covered a lot of stuff in this chapter: installing the Padrino gem, finding the right tools to manage different
Ruby versions, and creating our first Padrino app. Now it is time to jump into a real project!

