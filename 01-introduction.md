# Introduction

Why another book about how to develop an application (app) in Rails? But wait, this book should give you a basic introduction how to
develop a web app with [Padrino](http://www.padrinorb.com/). Padrino is "The Elegant Ruby Web Framework". Padrino is based
upon [Sinatra](http://www.sinatrarb.com/ "Sinatra"), which is a simple a Domain Specific Language (DSL) for quickly creating
web apps in Ruby. When writing Sinatra apps many developers miss some of the extra conveniences that Rails offers,
this is where Padrino comes in as it provides many of these while still staying true to Sinatra's ethos of being simple and
lightweight. To say it with words of the Padrino webpage: "Padrino is a full-stack ruby framework built upon Sinatra".


## Motivation

My motivation is to provide up-to-date documentation for Padrino. Although Padrino borrows many ideas and techniques from it's big
brother Rails it aims to be more modular and allows you to interchange various components with considerable ease.


## Basics and Tools

I won't tell you which operating system you should use - there is an interesting discussion on
[hackernews](http://news.ycombinator.com/item?id=3786674 "hackernews"). I leave it free for the reader of this book which to use -
basically you are reading this book to learn Padrino.

I assume that you already have your favorite browser - in the end you you just need to call a certain URL in your browser to see
the your Padrino app running.

Nowadays there are a bunch of Integrated Development Environments (IDEs) out there:

- [RubyMine by JetBrains](http://www.jetbrains.com/ruby/ "RubyMine") - commercial, available for all platforms
- [Aptana RadRails](http://www.aptana.com/products/radrails "Aptana RadRails") - free, available for all platforms

Besides, you can also use plain text editors which is a popular choice among Ruby developers:

- [Notepad++](http://notepad-plus-plus.org/ "Notepad ++") - free, available only for Windows
- [Textmate](http://macromates.com/ "Textmate") - commercial, available only for Mac
- [Gedit](http://projects.gnome.org/gedit/ "Gedit") - free, available for Linux
- [Vim](http://www.vim.org/ "vim") - free, available for all platform
- [Emacs](http://www.gnu.org/s/emacs/ "emacs") - free, available for all platforms
- [SublimeText](http://www.sublimetext.com "SublimeText") - commercial, available for all platform

All tools have their strengths and weaknesses - find software that works best for you or write even something by yourself. The
main goal is that you are comfortable with it because you will mostly spend a lot of time with it.

### Additional tools

This sections contains a list of tools that are optional. That means that you can survive without them but learning them can help
you in various situations and makes it easier for you to react upon changes.


#### Ruby

For any non-Ruby people, I strongly advise you to check out one of these books and learn the basics of Ruby before continuing here.

- [Programming Ruby](http://pragprog.com/book/ruby3/programming-ruby-1-9 "Programming Ruby")
- [why's (poignant) Guide to Ruby](http://www.scribd.com/doc/8545174/Whys-Poignant-Guide-to-Ruby "why's (poignant) Guide to Ruby")
  - written by the nebulous programmer [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff "why the lucky
    stiff") in a entertaining and educational way.

In this book I will be assuming some Ruby knowledge and will not be explaining every last detail, I will however explain Padrino
specific coding techniques.


#### Version controlling with Git

During software development it is important to keep track of your source code changes. That is what version control systems (VCSs)
are all about.  Git helps you to keep track of the changes in your code. You can switch between certain versions in your code,
create branches to experiment with code, and easily manage your code in distributed teams. If you want to deepen your knowledge
into this topic, you can consult the following book and only references:

- [Pro Git](http://progit.org/ "Pro Git") - this free online book explains the basic internals of git, and what the workflow can
  be like. Learn the fundamentals and internals of git with the help of beautiful images.
- [gitref](http://gitref.org/ "gitref") - page with the basic commands you have to use to be productive when working with Git.

**Remember**: Without version control you are lost. Git helps to detect changes in your code base, to better collaborate with
other people, and to get out of the pit when you break something badly. You can experiment in *branches* to create running code,
or to build a prototype to test design and technical limitation.

There are other VCSs out there like:

- [cvs](http://en.wikipedia.org/wiki/Concurrent_Versions_System "cvs") (*concurrent version system*),
- [svn](http://en.wikipedia.org/wiki/Apache_Subversion "svn") (*subversion*), or
- [Mercurial](http://mercurial.selenic.com/ "Mercurial")

Feel free to track the progress of your app with several small commits and branches.


#### Heroku

The [Heroku cloud app platform](http://www.heroku.com/ "ruby gem") enables you to deploy your Padrino / Ruby app
on the Heroku platform. It manages the database creation and installation of the gems - difficult configurations tasks are handled by
this platform. Heroku is so attractive that even the creator of Ruby,
[Yukihiro Matsumoto](http://blog.heroku.com/archives/2011/7/12/matz_joins_heroku/ "Yukihiroatsumoto"), works as *Chief Architect
of Ruby* on this platform.


## Installing the necessary tools

If you are an advanced user, you can skip these section and jump straight forward to the "Hello World" section.


### Installing Ruby

Instead of using the build in package for Ruby, we will use [rbenv](https://github.com/sstephenson/rbenv/) which lets you switch
between multiple versions of Ruby.

First, we need to clone rbenv:

    $ cd $HOME
    $ git clone git://github.com/sstephenson/rbenv.git .rbenv

Now we add the recently installed `.rbenv` directory in the `bin` path (if you are on Mac, you have to replace `.bashrc` with
`.bash_profile` in all of the following commands):

    $ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

To enable auto completion for `rbenv` commands, we need to perform the following command:

    $ echo 'eval "$(rbenv init -)"' >> ~/.bashrc

Next, we need to restart our shell to enable the last changes:

    $ exec $SHELL

Now the we have two ways to install Ruby versions: The easy one with a plugin, and the difficult one where we have to compile Ruby
on our own.


#### ruby-build

Because we don't want to download and compile different Ruby versions on our own, we will use
[ruby-build](https://github.com/sstephenson/ruby-build "ruby-build") plugin for rbenv:

    $ mkdir ~/.rbenv/plugins
    $ cd ~/.rbenv/plugins
    $ git clone git://github.com/sstephenson/ruby-build.git


If you now run `rbenv install` you can see all the different Ruby version you can install and use for different Ruby projects. We
are going to install `ruby 1.9.2-p290`:

    $ rbenv install 1.9.2-p290

This command will take a couple of minutes (why you will ask, you have perform the steps of the next chapter), so it's best to
grab a Raider, which is now know as [twix](http://en.wikipedia.org/wiki/Twix "Twix"). After everything runs fine, you have to run
`rbenv rehash` to rebuild the internal rbenv libraries. The last step is to made Ruby 1.9.2-p290 available on your whole machine:

    $ rbenv global 1.9.2-p290

And check the selection of the correct Ruby version with `ruby -v`. The output should look like:

    $ * 1.9.2-p290 (set by /home/.rbenv/versions)

Now you are a "rookie" [Ruby Rogue](http://rubyrogues.com/).


#### Compiling Ruby on your own

Before we start make that you have installed the following packages: `make, g++, wget` and `unzip`.

First, you need to get the Ruby version (you can find other versions [here](http://ftp.ruby-lang.org/pub/ruby/)):

    $ cd ~/.rbenv/versions
    $ wget http://ftp.ruby-lang.org/pub/ruby/ruby-1.9.2-p290.zip

Under `.rbenv/versions` you will find all the different installed Ruby versions. Next do:

    $ unzip ruby-1.9.2-p290.zip

Configure the compilation and perform the installation:

    $ cd ~/.rbenv/versions
    $ ./configure --prefix=$HOME/.rbenv/versions/ruby-1.9.2.p290
    $ make
    $ make install

The good is,that you know how the whole configuration works, what compiles, and what doesn't. The bad is that if you get

    $ ruby -v
    Segmentation fault

you hardly know whats going on. So my pragmatic advice is, use the first method.

If you get this working, you are a "real" [Ruby Rogue](http://rubyrogues.com/).


## Hello world

On the following image you can see the basic image of our application[^omnigraffle]:

![Figure 1-1. Start page of the app](images/01/application_overview.jpg)

[^omnigraffle]: You can use a classical stencil and paper to create mockups. I'm using
[Omnigraffle](http://www.omnigroup.com/products/omnigraffle/ "Omnigraffle") with the stencil extensions by
[konigi](http://konigi.com/tools/omnigraffle-wireframe-stencils "konigi") for writing wireframes.

You know this section from several tutorials, which makes you comfortable with your first program in a new programming language.
Get your hands dirty and start coding. First of all we need to install the gem with:

    $ gem install padrino

We are using the last stable version of Padrino (during the release of this book it is version **0.10.5**).

This will install all necessary dependencies and makes you ready to create your web app. Now we will generate a fresh
new Padrino project:

    $ padrino generate project hello-world

We will go through each part:

- `padrino generate` - tells Padrino to perform the generator with the specified options. The generate options can be used to
  create other *components* for your app like a mailing system or a nice admin panel to manage your database entries. A
  shortcut for generate is `g`
- `project` - tells Padrino to generate a new app.
- `hello-world` - the name of the new app and this is also the folder name.

The console output should looks like the following:

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
    skipping  orm component...
    skipping  test component...
    skipping  mock component...
    skipping  script component...
    applying  haml (renderer)...
       apply  renderers/haml
      insert  Gemfile
    skipping  stylesheet component...
    identical  .components

    =================================================================
    hello-world is ready for development!
    =================================================================
    $ cd ./hello-world
    $ bundle install
    =================================================================

The last line in the console output tells you the next steps you have to perform. Before we are going to start our app,
we need some sort of package managing for Ruby.

Ruby has a nice gem manager called [bundler](http://gembundler.com/ "bundler") which installs all necessary gems in specific
versions you would like to have in your project. The [Gemfile](http://gembundler.com/gemfile.html "Gemfile") declares the gems
that you want to install. Bundler takes the content of the Gemfile and will install everything declared inside this file. To
install bundler perform the following command

    $ gem install bundler
        Fetching: bundler-1.2.0.gem (100%)
        Successfully installed bundler-1.2.0
        1 gem installed

Now we have everything to start our app:

    $ cd hello-world
    $ bundle install
      Fetching gem metadata from http://rubygems.org/.........
      Using rake (0.9.2.2)
      Installing i18n (0.6.1)
      Using multi_json (1.3.6)
      Installing activesupport (3.2.8)
      Using bundler (1.2.0)
      Installing haml (3.1.7)
      Using rack (1.4.1)
      Using url_mount (0.2.1)
      Using http_router (0.10.2)
      Using mime-types (1.19)
      Using polyglot (0.3.3)
      Using treetop (1.4.10)
      Using mail (2.3.3)
      Using rack-protection (1.2.0)
      Using tilt (1.3.3)
      Installing sinatra (1.3.3)
      Using thor (0.15.4)
      Using padrino-core (0.10.7)
      Using padrino-helpers (0.10.7)
      Using padrino-admin (0.10.7)
      Using padrino-cache (0.10.7)
      Using padrino-gen (0.10.7)
      Using padrino-mailer (0.10.7)
      Using padrino (0.10.7)
      Using sinatra-flash (0.3.0)
      Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

Let's open the file `app/app.rb` (this is like the root controller) and insert the following:

    class HelloWorld < Padrino::Application

      get "/" do
        "Hello World!"
      end

    end

Now run the app with:

    $ padrino s

(`s` is an acronym for start) and fire up your browser with the URL *http://localhost:3000*. Be happy if you see the following:

![Figure 1-3. Hello world in your browser](images/01/hello_world.jpg)

You can now say that you have built your first Padrino app with no great effort and it still feels natural.


### Wait, there is more - the file structure

Navigating through the various parts of a project is essential. Thus we will go through the basic file structure of the
*hello-world* project:

    |-- Gemfile
    |-- app
    |   |-- app.rb
    |   |-- controllers
    |   |-- helpers
    |   `-- views
    |       `-- layouts
    |-- config
    |   |-- apps.rb
    |   `-- boot.rb
    |-- config.ru
    |-- public
    |   |-- favicon.ico
    |   |-- images
    |   |-- javascripts
    |   `-- stylesheets
    `-- tmp

We will go through each part.

- **Gemfile**: The place where you put all the necessary *gems* for your project. Bundle takes the content of this file and
  installs all the declared dependencies inside this file.
- **app**: Contains the "executable" files of your project with controllers, helpers, and views of your app
  - **app.rb**: The primary configuration file of your application.
  - **controller**: The controllers make the model data available to the view and handles the correct paths and which actions are
    triggered when requests are fired up against certain routes
  - **helper**: Helpers are small snippet of code that can be called in your views to help you to prevent repetition - also called
    `DRY` (Don't Repeat Yourself)
  - **views**: Holds the display templates to fill in with data to be rendered by in a controller
- **config**: General settings for the app , that means which hooks should be performed before or after the app is
  loaded, setting the environment (e.g. production, development, test), mounting other apps within the existing app
  under different subdomains.
  - **apps.rb**: Mounts different Padrino apps under a certain domain and/or host. It is like building a castle consisting of
    different already crafted parts like moats, wall, and baily
  - **boots.rb**: Basic settins for your app which will be run when you start the app
- **config.ru**: Contains the complete configuration options of the app, such as which port the app listens to,
  whenever it uses other Padrino apps as middleware and more. This file will be used when Padrino is runs on the command line.
- **public**: Place where you put global files to be available for the public audience of your page like images folder, JavaScript
  files, and style sheets.
- **tmp**: This directory holds temporary files for intermediate processing


## Conclusion

We have covered a lot of stuff in this chapter: installing the Padrino gem, finding the right tools for the job, and using version
control with Git. Now it is time to jump into a real project!

