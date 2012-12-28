%%/* vim: set ts=2 sw=2 textwidth=120: */

# Introduction

Why another book about how to develop an application (app) in Rails? But wait, this book should give you a basic
introduction how to develop a web app with [Padrino](http://www.padrinorb.com/ "Padrino"). Padrino is "The Elegant Ruby
Web Framework". Padrino is based upon [Sinatra](http://www.sinatrarb.com/ "Sinatra"), which is a simple a Domain
Specific Language (DSL) for quickly creating web apps in Ruby. When writing Sinatra apps many developers miss some of
the extra conveniences that Rails offers, this is where Padrino comes in as it provides many of these while still
staying true to Sinatra's ethos of being simple and lightweight. To say it with words of the Padrino webpage: "Padrino
is a full-stack ruby framework built upon Sinatra".


## Motivation

My motivation is to provide up-to-date documentation for Padrino. Although Padrino borrows many ideas and techniques
from it's big brother Rails it aims to be more modular and allows you to interchange various components with
considerable ease.


## Basics And Tools

I won't tell you which operating system you should use - there is an interesting discussion on
[hackernews](http://news.ycombinator.com/item?id=3786674 "hackernews"). I leave it free for the reader of this book
which to use - basically you are reading this book to learn Padrino.


I assume that you already have your favorite browser - in the end you you just need to call a certain URL in your
browser to see the your Padrino app running.


Nowadays there are a bunch of Integrated Development Environments (IDEs) out there:


- [RubyMine by JetBrains](http://www.jetbrains.com/ruby/ "RubyMine") - commercial, available for all platforms
- [Aptana RadRails](http://www.aptana.com/products/radrails "Aptana RadRails") - free, available for all platforms


Besides, you can also use plain text editors which is a popular choice among Ruby developers:


- [Emacs](http://www.gnu.org/s/emacs/ "Emacs") - free, available for all platforms.
- [Gedit](http://projects.gnome.org/gedit/ "Gedit") - free, available for Linux.
- [Notepad++](http://notepad-plus-plus.org/ "Notepad ++") - free, available only for Windows.
- [SublimeText](http://www.sublimetext.com "SublimeText") - commercial, available for all platform.
- [Textmate](http://macromates.com/ "Textmate") - commercial, available only for Mac.
- [Vim](http://www.vim.org/ "Vim") - free, available for all platform.


All tools have their strengths and weaknesses. Try to find the software that works best for you. The main goal is that
you are comfortable with it because you will mostly spend a lot of time with it. Feel free to write your software if you
can't find anything.


## Ruby

For any non-Ruby people, I strongly advise you to check out one of these books and learn the basics of ruby before
continuing here.

- [Programming Ruby](http://pragprog.com/book/ruby3/programming-ruby-1-9 "Programming Ruby")
- [Poignant Guide to Ruby](http://www.scribd.com/doc/8545174/Whys-Poignant-Guide-to-Ruby "Poignant Guide To Ruby") -
  written by the nebulous programmer [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff "Stiff") in
  a entertaining and educational way.


In this book I will be assuming some Ruby knowledge and will not be explaining every last detail, I will however explain
Padrino specific coding techniques.


## Installing Ruby With rbenv

Instead of using the build in package for Ruby, we will use [rbenv](https://github.com/sstephenson/rbenv/ "rbenv") which
lets you switch between multiple versions of Ruby.


First, we need to get the resources of rbenv:


{: lang="bash" }
    $ cd $HOME
    $ git clone git://github.com/sstephenson/rbenv.git .rbenv


In case you shouldn't want to use git you can also download the latest zip.  Now we add the recently installed `.rbenv`
directory in the `bin` path (if you are on Mac, you have to replace `.bashrc` with `.bash_profile` in all of the
following commands):


{: lang="bash" }
    $ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc


To enable auto completion for `rbenv` commands, we need to perform the following command:


{: lang="bash" }
    $ echo 'eval "$(rbenv init -)"' >> ~/.bashrc


Next, we need to restart our shell to enable the last changes:


{: lang="bash" }
    $ exec $SHELL


Now the we have two ways to install Ruby versions: The easy one with a plugin, and the difficult one where we have to
compile Ruby on our own.


### ruby-build

Because we don't want to download and compile different Ruby versions on our own, we will use
[ruby-build](https://github.com/sstephenson/ruby-build "ruby-build") plugin for rbenv:


{: lang="bash" }
    $ mkdir ~/.rbenv/plugins
    $ cd ~/.rbenv/plugins
    $ git clone git://github.com/sstephenson/ruby-build.git


If you now run `rbenv install` you can see all the different Ruby version you can install and use for different Ruby
projects. We are going to install `ruby 1.9.3-p286`:


{: lang="bash" }
    $ rbenv install 1.9.3-p286


This command will take a couple of minutes (why you will ask, you have perform the steps of the next chapter), so it's
best to grab a Raider, which is now know as [twix](http://en.wikipedia.org/wiki/Twix "Twix"). After everything runs
fine, you have to run `rbenv rehash` to rebuild the internal rbenv libraries. The last step is to made Ruby 1.9.2-p290
available on your whole machine:


{: lang="bash" }
    $ rbenv global 1.9.3-p286


And check the selection of the correct Ruby version with `ruby -v`. The output should look like:


{: lang="bash" }
    $ 1.9.3-p286 (set by /home/.rbenv/versions)


Now you are a "rookie" [Ruby Rogue](http://rubyrogues.com/ "Ruby Rouges").


### Compiling Ruby On Your Own

Before we start make that you have installed the following packages: `make, g++, wget` and `unzip`. First, you need to
get the Ruby version (you can find other versions [here](http://ftp.ruby-lang.org/pub/ruby/ "ruby versions")):


{: lang="bash" }
    $ cd ~/.rbenv/versions
    $ wget http://ftp.ruby-lang.org/pub/ruby/ruby-1.9.3-p286.zip


Under `.rbenv/versions` you will find all the different installed Ruby versions. Next do:


{: lang="bash" }
    $ unzip ruby-1.9.3-p286.zip


Configure the compilation and perform the installation:


{: lang="bash" }
    $ cd ~/.rbenv/versions
    $ ./configure --prefix=$HOME/.rbenv/versions/ruby-1.9.3.p286
    $ make
    $ make install


The good is, that you know how the whole configuration works, what compiles, and what doesn't. The bad is that if you get


{: lang="bash" }
    $ ruby -v
    Segmentation fault


you hardly know whats going on. So my pragmatic advice is, use the first method.

If you get this working, you are a "real" **Ruby Rouge**


## Hello world

The basic layout of our application is displayed On the following image application:


![Figure 1-1. Start page of the app](images/01/application_overview.jpg)


You know this section from several tutorials, which makes you comfortable with your first program in a new programming
language.  Get your hands dirty and start coding. First of all we need to install the padrino gem with:


{: lang="bash" }
    $ gem install padrino


We are using the last stable version of Padrino (during the release of this book it is version **0.10.7**).


This will install all necessary dependencies and makes you ready to get started. Now we will generate a fresh new
Padrino project:


{: lang="bash" }
    $ padrino generate project hello-world


We will go through each part:


- `padrino generate`: Tells Padrino to perform the generator with the specified options. The generate options can be
  used to create other **components** for your app like a **mailing system** or an **admin panel** to manage your
  database entries. We will handle these things in a further chapter. A shortcut for generate is `g` which we will use
  in all following examples.
- `project`: Tells Padrino to generate a new app.
- `hello-world`: The name of the new app and this is also the folder name.


The console output should looks like the following:


{: lang="bash" }
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


Ruby has a nice gem manager called [bundler](http://gembundler.com/ "Bundler") which installs all necessary gems in the
versions you would like to have for your project. This makes it very easy for other developers to work with your project
even after years. The [Gemfile](http://gembundler.com/gemfile.html "Gemfile") declares the gems that you want to
install. Bundler takes the content of the Gemfile and will install everything declared inside this file. To install
bundler perform the following command:


{: lang="bash" }
    $ gem install bundler
        Fetching: bundler-1.2.3.gem (100%)
        Successfully installed bundler-1.2.3
        1 gem installed


Now we have everything to run the `bundle` command to install our dependencies:


{: lang="bash" }
    $ cd hello-world
    $ bundle
      Fetching gem metadata from http://rubygems.org/.........

      Using rake (10.0.3)
      Using i18n (0.6.1)
      Using multi_json (1.5.0)
      Using activesupport (3.2.9)
      Using bundler (1.2.3)
      Using haml (3.1.7)
      Using rack (1.4.1)
      Using url_mount (0.2.1)
      Using http_router (0.10.2)
      Using mime-types (1.19)
      Using polyglot (0.3.3)
      Using treetop (1.4.12)
      Using mail (2.3.3)
      Using rack-protection (1.3.2)
      Using tilt (1.3.3)
      Using sinatra (1.3.3)
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


{: lang="ruby" }
    class HelloWorld < Padrino::Application

      get "/" do
        "Hello World!"
      end

    end


Now run the app with:


{: lang="bash" }
    $ padrino start


(instead of writing `start` we can also use the alias `s`) and fire up your browser with the URL
*http://localhost:3000*. Be happy you've made it and built your first Padrino app with no great effort.


### Wait

Navigating through the various parts of a project is essential. Thus we will go through the basic file structure of the
*hello-world* project:


{: lang="bash" }
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


- **Gemfile**: The place where you put all the necessary *gems* for your project. Bundle takes the content of this file
  and installs all the declared dependencies inside this file.
- **app**: Contains the "executable" files of your project with controllers, helpers, and views of your app
  - **app.rb**: The primary configuration file of your application.
  - **controller**: The controllers make the model data available to the view and handles the correct paths and which
    actions are triggered when requests are fired up against certain routes
  - **helper**: Helpers are small snippet of code that can be called in your views to help you to prevent repetition -
    also called `DRY` (Don't Repeat Yourself)
  - **views**: Holds the display templates to fill in with data to be rendered by in a controller
- **config**: General settings for the app , that means which hooks should be performed before or after the app is
  loaded, setting the environment (e.g. production, development, test), mounting other apps within the existing app
  under different subdomains.
  - **apps.rb**: Mounts different Padrino apps under a certain domain and/or host. It is like building a castle
    consisting of different already crafted parts like moats, wall, and baily
  - **boots.rb**: Basic settins for your app which will be run when you start the app
- **config.ru**: Contains the complete configuration options of the app, such as which port the app listens to, whenever
  it uses other Padrino apps as middleware and more. This file will be used when Padrino is runs on the command line.
- **public**: Place where you put global files to be available for the public audience of your page like images folder,
  JavaScript files, and style sheets.
- **tmp**: This directory holds temporary files for intermediate processing


## Conclusion

We have covered a lot of stuff in this chapter: installing the Padrino gem, finding the right tools for the job, and
using version control with Git. Now it is time to jump into a real project!

