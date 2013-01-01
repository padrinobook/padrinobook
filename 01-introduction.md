%%/* vim: set ts=2 sw=2 textwidth=120: */

# Introduction

Why another book about how to develop an application (app) in Rails? But wait, this book should give you a basic
introduction how to develop a web app with [Padrino](http://www.padrinorb.com/ "Padrino"). Padrino is "The Elegant Ruby
Web Framework". Padrino is based upon [Sinatra](http://www.sinatrarb.com/ "Sinatra"), which is a simple a Domain
Specific Language  for quickly creating web apps in Ruby. When writing Sinatra apps many developers miss some of
the extra conveniences that Rails offers, this is where Padrino comes in as it provides many of these while still
staying true to Sinatra's philosophy of being simple and lightweight. To say it with words of the Padrino webpage: "Padrino
is a full-stack ruby framework built upon Sinatra".


## Motivation

My motivation is to provide up-to-date documentation for Padrino. Although Padrino borrows many ideas and techniques
from it's big brother Rails, it aims to be more modular and allows you to interchange various components with
considerable ease.


## Basics And Tools

I won't tell you which operating system you should use - there is an interesting discussion on
[hackernews](http://news.ycombinator.com/item?id=3786674 "hackernews"). I leave it free for the reader of this book
which to use, because basically you are reading this book to learn Padrino.

To actually see a running padrino app, you need a web browser of your choice.

For writing the application, you can either use an Integrated Development Environment (IDE) or with
a plain text editor.

Nowadays there are a bunch of Integrated Development Environments (IDEs) out there:

- [RubyMine by JetBrains](http://www.jetbrains.com/ruby/ "RubyMine") - commercial, available for all platforms
- [Aptana RadRails](http://www.aptana.com/products/radrails "Aptana RadRails") - free, available for all platforms

Here is a list of plain text editors which are a popular choice among Ruby developers:


- [Emacs](http://www.gnu.org/s/emacs/ "Emacs") - free, available for all platforms.
- [Gedit](http://projects.gnome.org/gedit/ "Gedit") - free, available for Linux.
- [Notepad++](http://notepad-plus-plus.org/ "Notepad ++") - free, available only for Windows.
- [SublimeText](http://www.sublimetext.com "SublimeText") - commercial, available for all platform.
- [Textmate](http://macromates.com/ "Textmate") - commercial, available only for Mac.
- [Vim](http://www.vim.org/ "Vim") - free, available for all platform.


All tools have their strengths and weaknesses. Try to find the software that works best for you. The main goal is that
you are comfortable with it because you will spend a lot of time with it.


### Ruby Knowledge

For any non-Ruby people, I strongly advise you to check out one of these books and learn the basics of Ruby before
continuing here.

- [Programming Ruby](http://pragprog.com/book/ruby3/programming-ruby-1-9 "Programming Ruby") - the
  standaard book on Ruby.
- [Poignant Guide to Ruby](http://www.scribd.com/doc/8545174/Whys-Poignant-Guide-to-Ruby "Poignant Guide To Ruby") -
  written by the nebulous programmer [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff "Stiff") in
  a entertaining and educational way.


In this book, I assume readers having Ruby knowledge and will not be explaining every last detail. I will, however, explain
Padrino-specific coding techniques.


## Installing Ruby With rbenv

Instead of using the build-in software package for Ruby of your operating system, we will use
[rbenv](https://github.com/sstephenson/rbenv/ "rbenv") which lets you switch between multiple versions of Ruby.


First, we need to use [git](http://git-scm.org) to get the current version of rbenv:


{: lang="bash" }
    $ cd $HOME
    $ git clone git://github.com/sstephenson/rbenv.git .rbenv


In case you shouldn't want to use git, you can also download the latest version as a zip file from [Github](http://github.com).

You need to add the directory that contains rbenv to your `$PATH`environment variable.  If you are on Mac, you have
to replace `.bashrc` with `.bash_profile` in all of thefollowing commands):


{: lang="bash" }
    $ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc


To enable auto completion for `rbenv` commands, we need to perform the following command:


{: lang="bash" }
    $ echo 'eval "$(rbenv init -)"' >> ~/.bashrc


Next, we need to restart our shell to enable the last changes:


{: lang="bash" }
    $ exec $SHELL


Basically, there are two ways to install different versions of Ruby: You can compile Ruby on your
own and try to manage the versions and gems on your own, or you use a tool that helps you.


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


This command will take a couple of minutes, so it's best to grab a Raider, which is now known as [Twix](http://en.wikipedia.org/wiki/Twix "Twix").
After everything runs fine, you have to run `rbenv rehash` to rebuild the internal rbenv libraries. The last step is to makeRuby 1.9.3-p286
the current executable on your machine:


{: lang="bash" }
    $ rbenv global 1.9.3-p286


Check that the correct executable is active by exexuting `ruby -v`. The output should look like:


{: lang="bash" }
    $ 1.9.3-p286 (set by /home/.rbenv/versions)


Now you are a "rookie" [Ruby Rogue](http://rubyrogues.com/ "Ruby Rouges").


### Compiling Ruby On Your Own

If you want to compile a different version of Ruby that is not offered with rbenv, then make sure you have
the following packages installed for your os: `make, g++, wget` and `unzip`. Continue to select your preferred
[Ruby versions ](http://ftp.ruby-lang.org/pub/ruby/ "ruby versions") and then download the appropriate package:


{: lang="bash" }
    $ cd ~/.rbenv/versions
    $ wget http://ftp.ruby-lang.org/pub/ruby/ruby-1.9.3-p286.zip


Go to the directory `.rbenv/versions` where you will find the downloaded file. Next unzip the file:


{: lang="bash" }
    $ unzip ruby-1.9.3-p286.zip


Configure the compilation and perform the installation:


{: lang="bash" }
    $ cd ~/.rbenv/versions
    $ ./configure --prefix=$HOME/.rbenv/versions/ruby-1.9.3.p286
    $ make
    $ make install


Following these steps, you gain knowledge about the whole process of configuration and compilation
of custom Ruby versions. However, this doesn't always work:'


{: lang="bash" }
    $ ruby -v
    Segmentation fault


If you want to be on the safe side, then use ruby-build.


## Hello world

The basic layout of our application is displayed on the following image application:


![Figure 1-1. Start page of the app](images/01/application_overview.jpg)


It is possible that you know this section from several tutorials, which makes you even more comfortable with
your first program.

Now, get your hands dirty and start coding.

First of all we need to install the padrino gem. We are using the last stable version of Padrino (during the release of this book it is version **0.10.7**). Execute this command.


{: lang="bash" }
    $ gem install padrino


This will install all necessary dependencies and makes you ready to get started. Now we will generate a fresh new
Padrino project:


{: lang="bash" }
    $ padrino generate project hello-world


Let's go through each part of this command:


- `padrino generate`: Tells Padrino to execute thegenerator with the specified options. The options can be
  used to create other **components** for your app like a **mailing system** or an **admin panel** to manage your
  database entries. We will handle these things in a further chapter. A shortcut for generate is `g` which we will use
  in all following examples.
- `project`: Tells Padrino to generate a new app.
- `hello-world`: The name of the new app, which is also the folder name.


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


The last line in the console output tells you the next steps you have to perform. Before we are going to start coding our
app, we need some sort of package managing for Ruby gems.


Ruby has a nice gem manager called [bundler](http://gembundler.com/ "Bundler") which installs all necessary gems in the
versions you would like to have for your project. This makes it very easy for other developers to work with your project
even after years. The [Gemfile](http://gembundler.com/gemfile.html "Gemfile") declares the gems that you want to
install. Bundler takes the content of the Gemfile and will install everything declared inside this file. To install
bundler, execute the following command and check the console output:


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


Let's open the file `app/app.rb` (think of it as the root controller of your app) and insert the following:


{: lang="ruby" }
    class HelloWorld < Padrino::Application

      get "/" do
        "Hello World!"
      end

    end


Now run the app with:


{: lang="bash" }
    $ padrino start


Instead of writing `start`, we can also use the alias `s`. Now, fire up your browser with the URL
*http://localhost:3000* and see the `Hello World` Greeting being printed.


Congratulations! You've built your first Padrino app.



### Folder structure of a Padrino app

Navigating through the various parts of a project is essential. Thus we will go through the basic file structure of the
*hello-world* project. The app consists of the following parts:


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
- **app**: Contains the "executable" files of your project with controllers, helpers, and views of your app.
  - **app.rb**: The primary configuration file of your application.
  - **controller**: The controllers make the model data available to the view. They define the URL routes that are
    callable in your app and defines the actions that are triggered by requests.
  - **helper**: Helpers are small snippet of code that can be called in your views to help you to prevent repetition -
    following the `DRY` (Don't Repeat Yourself) principle.
  - **views**: Contains the templates that are filled with model data and rendered by a controller.
- **config**: General settings for the app, including hooks (explained later) that should be performed before or after the app is
  loaded, setting the environment (e.g. production, development, test) and mounting other apps within the existing app
  under different subdomains.
  - **apps.rb**: Allows you to configure a compound app that consists of several smaller apps. Each
    app has his own default route form which requests will be handled by that app.
  - **boots.rb**: Basic settings for your app which will be run when you start the app.
- **config.ru**: Contains the complete configuration options of the app, such as which port the app listens to, whenever
  it uses other Padrino apps as middleware and more. This file will be used when Padrino is started from the command line.
- **public**: Folder where you put static resources like images folder, JavaScript files, and style sheets.
- **tmp**: This directory holds temporary files for intermediate processing.


## Conclusion

We have covered a lot of stuff in this chapter: installing the Padrino gem, finding the right tools to manage different Ruby
versions, and creating our first Padrino app. Now it is time to jump into a real project!

