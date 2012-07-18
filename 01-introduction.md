# Introduction

Why another book about how to develop an application in Rails? But wait, this book should give you a
basic introduction how to develop a web application with [Padrino](http://www.padrinorb.com/).
Padrino is "The Elegant Ruby Web Framework". Padrino is based upon [Sinatra](http://www.sinatrarb.com/
"Sinatra"), which is a simple a Domain Specific Language (DSL) for quickly creating web-applications
in Ruby. When writing Sinatra applications many developers miss some of the extra conveniences that
Rails offers, this is where Padrino comes in as it provides many of these whilst still staying true to
Sinatra's ethos of being simple and lightweight. To say it with words of the Padrino webpage: "Padrino
is a full-stack ruby framework built upon Sinatra".


## Motivation

My motivation is to provide up-to-date documentation for Padrino. It is exceptional to Rails,
providing separate branches of your favorite HTML/CSS/SQL layers and many more. Each of the used
techniques will be described when it will be used and repeated in whole parts of the book.


## Basics and Tools

In one sentence: I'm using **Vim** on **Mac OS X** along with **Git** for source code
tracking and **heroku** for deploying an application.


### Operation System

"War... War never changes." this quote from my all-time favorite video game series
[Fallout](http://en.wikipedia.org/wiki/Fallout_(video_game) "Fallout") describes the battle of the
different operating systems. I will briefly give you an overview what you can take:

- [Windows](http://windows.microsoft.com/ "Windows"): This commercial operating system is installed
  on a huge range of computers. Much software and games are available for this operation system.
  Updates comes regularly, and everything is mostly intuitive. One big problem of Windows is its
  mouse affinity: There are shortcuts and handy tips available. It is good for development, but
  lacks some comfort and design issues (you may not know, when you haven't worked with Linux).
- [Unix/Linux](http://en.wikipedia.org/wiki/Linux "Unix/Linux"): Highly configurable, and has many
  Open Source Tools. If you come from the Windows world, your brain will burn like hell because
  everything is different. The program calls are different, you can install new software via
  *console*, the firewall is safe, and you can run most commands in the terminal (no annoying mouse
  clicks anymore if you avoid graphical work). It is great for development because the great
  community is passionate about building software, and most software is Open Source so you don't
  have to pay for it.
- [Mac OS X](http://www.apple.com/macosx/ "Mac OS X"): The core under it is Unix, so you can reuse
  your Linux knowledge. Many people say that products from Apple are very expensive. In the contrast
  they provide you with an extremely stable, highly configurable, and reliable system, which has
  some really nice software for it. If you haven't paid for software in your life, some piece of
  software will make you want to pay for it because in my eyes, Mac is the gap between Windows and
  Linux. It can be changed in any any way you want (Linux) and has some really good software for it
  (Microsoft). Development on this machine is extreme good, because it underlines the needs of
  developers.

There is a war between these three operation systems, and which you chose is a matter of taste. As
you can see on this pictures, I'm using a Mac. I like and love (and yeah, I had to pay a lot of
patience and learning to come to the point where I can say, that it was worth paying that much money
for the hardware).


### Editor

Nowadays there are a bunch of IDEs out there: [RubyMine by JetBrains](http://www.jetbrains.com/ruby/
"RubyMine") (commercial) [Aptana RadRails](http://www.aptana.com/products/radrails "Aptana
RadRails") (free).  Or you can switch to some text editors [Textmate](http://macromates.com/
"Textmate") (commercial for Mac only), [Vim](http://www.vim.org/ "vim"), and
[Emacs](http://www.gnu.org/s/emacs/), which just run on every server and under every terminal.

All tools have their strengths and weaknesses - find your most passionate piece of software or write
even something by yourself. The main goal is that you are comfortable with it because you will
mostly spend a lot of time with it.  Due to the fact that I use the command line extensively, I
prefer to use a "classical" **text editor** (see my [vim-settings repository on github](https://github.com/matthias-guenther/vim-settings "vim-settings repository on github") if
you want to see which tool I use every day). In the end you have to decide what you want to take.
![Figure 1-2. Picture of Vim with NERDTree](images/01/editor.jpg)


### Browser

Here it is the as with the editors: There are many of them with great plugins out there for
web development. The mostly used browsers by Rails developer are:

- [Firefox](http://www.mozilla.org/en-US/firefox/new/ "Firefox"): Has a tons of plugins, is free,
  and with the magnificent [Firebug](http://getfirebug.com/ "Firebug") plugin, which let you inspect
  HTML document, measure the loading time of certain parts
- [Chrome](http://www.google.com/chrome "Chrome"): This browser is from Google It feels very fast
  and is shipped with *inspect element*[^inspect] to search the DOM[^dom]. It integrates the ability
  to debug JavaScript
- [Opera](http://www.opera.com/ "Opera"): Never used it, and don't know why I should (instead you
  tell my why and I will quote your words if they convince me)

There are more outside this main domain, like [Safari by Apple](http://www.apple.com/safari/ "Safari
by Apple"), [Lynx webbrowser](http://lynx.isc.org/ "Lynx webbrowser") (quite an experience to use
just a plain text browser) and the well known [Internet
Explorer](http://windows.microsoft.com/en-US/internet-explorer/downloads/ie "Internet Explorer").
Get out, grab the thing you want, and then gets your hands dirty.

[^inspect]: This is like a Firebug pendant of Firefox.
[^dom]: stands for *Document Object Model* and is a tree-like representation of the HTML page.


### Additional tools

This sections contains a list of tools that are optional. That means that you can survive without
them but learning them can help you in various situations and makes it easier for you to react upon
changes.


#### Ruby

For any non-Ruby people, I strongly advice you to check out one of these books and learn the basics
of Ruby before continuing here.

- [Programming ruby](http://pragprog.com/book/ruby3/programming-ruby-1-9 "Programming ruby")
- [why's (poignant) Guide to Ruby](http://www.scribd.com/doc/8545174/Whys-Poignant-Guide-to-Ruby
  "why's (poignant) Guide to Ruby") - written by the nebulous programmer [why the lucky
  stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff "why the lucky stiff") in a entertaining
  and educational way.


In this project I will explain difficult language constructs in Ruby - but don't assume that I
will explain them in every way.


#### Git

During software development it is important to keep track of your source code changes. That is what
version control systems (VCSs) is all about.  Git helps you to keep track of the changes in your
code. You can switch between certain versions in your code, create branches to experiment with code,
and easily manage your code in distributed teams. If you want to deepen your knowledge into this
topic, you can consult the following book and only references:

- [Pro Git](http://progit.org/ "Pro Git") - this free online book explains the basic internals
  of git, and what the workflow can be like. Learn the fundamentals and internals of git with the
  help of beautiful images.
- [gitref](http://gitref.org/ "gitref") - page with the basic commands you have to use to be
  productive when working with Git.

Recommended git GUIs for displaying your repository and complete git-wrapper for Vim:

- [gitk](http://gitk.sourceforge.net/ "gitk") - gives you a tree-like overview of your git
  repository (it works on every platform)
- [gitx](http://gitx.frim.nl/ "gitx") - branching, merging, committing, you can even stage different
  changes in your code with this tool. It looks like a diamond and checking in your code will make
  you happy
- [fugitive](https://github.com/tpope/vim-fugitive/ "fugitive") - git wrapper for Vim, very good for
  command-line guys who don't want to leave the editor. Works good, if you are the only person
  working on a project (like I'm doing writing this book)

**Remember**: Without version control you are lost. Git helps to detect changes in your code base, to
better collaborate with other people, and to get out of the pit when you break something badly. You
can experiment in *branches* to create running code, or to build a prototype to test design and
technical limitation.

There are other VCSs out there like:

- [cvs](http://en.wikipedia.org/wiki/Concurrent_Versions_System "cvs") (*concurrent version system*),
- [svn](http://en.wikipedia.org/wiki/Apache_Subversion "svn") (*subversion*), or
- [Mercurial](http://mercurial.selenic.com/ "Mercurial")

In this book I will explain the commands of Git when they first occur, and repeat the commands
every time I did during the development. Repeating is very important when learning something new.


#### Heroku

The [Heroku cloud application platform](http://www.heroku.com/ "ruby gem") enables you to deploy
your Rails application on the Heroku platform. It manage the database creation, installation of the
gems - difficult configurations tasks are handled by this platform. Heroku is so attractive that
even the creator of ruby, [Yukihiro
Matsumoto](http://blog.heroku.com/archives/2011/7/12/matz_joins_heroku/ "Yukihiroatsumoto"), works
as *Chief Architect of Ruby* on this platform.


## Hello world and Git

On the following image you can see the basic image of our application[^omnigraffle]:

![Figure 1-1. Start page of the application](images/01/application_overview.jpg)

[^omnigraffle]: You can use a classical stencil and paper to create mockups. I'm using
[Omnigraffle](http://www.omnigroup.com/products/omnigraffle/ "Omnigraffle") with the stencil
extensions by [konigi](http://konigi.com/tools/omnigraffle-wireframe-stencils "konigi") for writing
wireframes.


You know this sections from several tutorials which makes you comfortable with your first program in
a new programming language. Get your hands dirty and start coding. First of all we need to install
the gem with:

    $ gem install padrino

We are using the last stable version of Padrino (during the release of this book it is version
**0.10.5**).

This will install all necessary dependencies and makes you ready to create your web applications.
Now we will generate a fresh new Padrino project:

    $ padrino generate project hello-world

We will go through each part:

- `padrino generate` - tells Padrino to perform the generator with the specified options. The
  generate options can be used to create other *components* for your application like a mailing
  system or a nice admin panel to manage your database entries. A shortcut for generate is `g`
- `project` - tells Padrino to generate a new application.
- `hello-wolrd` - the name of the new application and this is also the folder name.


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
    brand_new is ready for development!
    =================================================================
    $ cd ./brand_new
    $ bundle install
    =================================================================

The last line in the console output tells you the next steps you have to perform.  Going in the
application folder and starting the application:

    $ cd hello-world
    $ bundle install

The command `bundle install` will install with [bundler](http://gembundler.com/ "bundler") all
the necessary gem dependencies for your project which are declared in your *GemFile*.

Let's open the file *app/app.rb* (this is like the root controller) and write in the following:

    class HelloWorld < Padrino::Application

      get "/" do
        "Hello World!"
      end

    end

Now run:

    $ padrino start

and fire up your browser with the URL *http://localhost:3000*. Be happy with the following pictures:

![Figure 1-3. Hello world in your browser](images/01/hello_world.jpg)

You can say, you have built your first Padrino application in less than five minutes. Time to put a
hand on your shoulder and have a party dance.


### Installing Git and configure it

We want to get the least possible thing to be working. Follow the [installation
section](http://progit.org/book/ch1-4.html "installation section") of the **Pro git** book to
install git on your local machine. After that you need to setup your user name and email address (so
that other can see who blames the last lines of code):

    $ git config --global user.name "wikimatze"
    $ git config --global user.email "matthias.guenther@wikimatze.de"

It is possible to define [git
aliases](http://gitready.com/intermediate/2009/02/06/helpful-command-aliases.html "git aliases") for
comment commands so that you have to hack less chars. But this is the first time you are using git,
repeating commands is the best way to learn, and everyone has a different opinion what aliases
should be used, I will not create further configurations.


### Initialize a Git repository

Git can keep track of every file you have in a certain directory. Let's assume that you have a brand
new Padrino application in the directory *padrino\_brand\_new*. First you need to initialize git in
the project folder:

    $ cd ~/hello-world
    $ git init
    > Initialized empty Git repository in ~/padrino_brand_new/.git/

Now that you started a new repository and it is time to add new files. If you type in `git status`
you will see a list of all *untracked*, *modified*, or *changed* files in your
folder. Again, git gives you a nice console output what you can do in the next steps:

    # On branch master
    #
    # Initial commit
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    # .components
    # .gitignore
    # Gemfile
    # app/
    # config.ru
    # config/
    # public/
    nothing added to commit but untracked files present (use "git add" to track)

If you are new to git (and want to do the same work again and again), you have to type in *git add
<filename* for each part of the files. But git is as smart to provides you with a handy command to
add all files simultaneously recursively:

    $ git add .

The '.' stays for the current directory and git then knows that it should track all files and
components (which even stay in subdirectories) recursively. During this phase, we have just
*staged* the files and not committed them in the repository. Let's do it:

    $ git commit -m "initial commit (Padrino and Git rocks)"

The '-m' options tells git to take a message for the commit[^tpope]

[^tpope]: I'm a big fan of [Tim Pope's](http://tpo.pe/ "Tim Popes") Vim plugins.  With the
[fugitive](https://github.com/tpope/vim-fugitive "fugitive") he has written a fully integrated git
into the Vim environment.  According to Pope's philosophy, a commit message should not be longer than
80 chars - anything that is longer is an indicator that you are writing too much, or have too big of a
commit with too many changes.


### gitignore

This file let's you specify which files should not be added to the Git repository.  When you start
your Padrino application with `padrino start` it will start to track requests you can see in the
console in the *log/* directory. You don't want to have this in your commit history, so you have to
write in your *.gitignore* files

    log/**/*

This tells git to ignore all changes in all subdirectories of the *log* directory. You are lucky to
work with Padrino, and it will automatically add a *.gitignore file* when you start a new project, with
all entries you need:

    .DS_Store
    log/**/*
    tmp/**/*
    bin/*
    vendor/gems/*
    !vendor/gems/cache/
    .sass-cache/*

Just keep your mind on committing small changes for your project.


### Wait, there is more - the file structure

Navigating through the various parts of a project is essential. Thus we will go through the basic
file structure of the *hello-world* project:

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

- **Gemfile**: The place where you put all the necessary *gems* for your project.
- **app**: Contains the "executable" files of your project with controllers, helpers, and views for
  displaying the contents of your application.
- **config**: General settings for the application, that means which hooks should be performed
  before or after the application is loaded, setting the environment (e.g. production, development,
  test), mounting other application within the existing application under different subdomains.
- **config.ru**: Contains the complete configuration options of the application, such as which port
  the application listens to, whenever it uses other Padrino apps as middleware and more. See more
  under TBD.
  application from the command line.
- **public**: Place where you put global files to be available for the public audience of
  your page like images folder, JavaScript files, or style sheets
- **tmp**: If you are running your application under Nginx than tmp contains a file named
  *restart.txt* which reboots another Padrino application.


## Conclusion

We have covered a lot of stuff in this chapter: installing the Padrino gem, finding the right tools
for the job, and used to version control with git. Now it is time to jump into a real project!

