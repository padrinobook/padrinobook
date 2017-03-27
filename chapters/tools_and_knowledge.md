## Tools and Knowledge

I won't tell you which operating system you should use - there is an interesting discussion on [hackernews](https://news.ycombinator.com/item?id=3786674 "hackernews"). I'll leave it free for the reader of this book which to use, because you are reading this book to learn Padrino.


To actually see a running padrino app, you need a web browser of your choice. For writing the application, you can either use an Integrated Development Environment (IDE) or with a plain text editor.


Nowadays there are a bunch of Integrated Development Environments (IDEs) out there:


- [RubyMine by JetBrains](https://www.jetbrains.com/ruby "RubyMine") - commercial, available for all platforms
- [Eclipse Dynamic Languages Toolkit](https://projects.eclipse.org/projects/technology.dltk "Aptana RadRails") - free, available for all platforms


Here is a list of plain text editors which are a popular choice among Ruby developers:


- [Emacs](https://www.gnu.org/s/emacs "Emacs") - free, available for all platforms.
- [Gedit](https://wiki.gnome.org/Apps/Gedit "Gedit") - free, available for Linux and Windows.
- [Notepad++](https://notepad-plus-plus.org "Notepad ++") - free, available only for Windows.
- [SublimeText](https://www.sublimetext.com/ "SublimeText") - commercial, available for all platforms.
- [Textmate](https://macromates.com/ "Textmate") - commercial, available only for Mac.
- [Vim](http://www.vim.org "Vim") - free, available for all platforms.


All tools have their strengths and weaknesses. Try to find the software that works best for you. The main goal is that
you comfortable because you will spend a lot of time with it.


### Installing Ruby With rbenv

Instead of using the build-in software package for Ruby of your operating system, we will use
[rbenv](https://github.com/sstephenson/rbenv "rbenv") which lets you switch between multiple versions of Ruby.


First, we need to use [git](http://git-scm.org "git") to get the current version of rbenv:


```sh
$ cd $HOME
$ git clone git://github.com/sstephenson/rbenv.git .rbenv
```


In case you shouldn't want to use git, you can also download the latest version as a zip file from
[GitHub](http://github.com "GitHub").


You need to add the directory that contains rbenv to your `$PATH` environment variable.  If you are on Mac, you have to
replace `.bashrc` with `.bash_profile` in all of the following commands):


```sh
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
```


To enable auto completion for `rbenv` commands, we need to perform the following command:


```sh
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
```


Next, we need to restart our shell to enable the last changes:


```sh
$ exec $SHELL
```


Basically, there are two ways to install different versions of Ruby: You can compile Ruby on your
own and try to manage the versions and gems on your own, or you use a tool that helps you.


**ruby-build**

Because we don't want to download and compile different Ruby versions on our own, we will use the
[ruby-build](https://github.com/sstephenson/ruby-build "ruby-build") plugin for rbenv:


```sh
$ mkdir ~/.rbenv/plugins
$ cd ~/.rbenv/plugins
$ git clone git://github.com/sstephenson/ruby-build.git
```


If you now run `rbenv install` you can see all the different Ruby version you can install and use for different Ruby
projects. We are going to install `ruby 1.9.3-p392`:


```sh
$ rbenv install 1.9.3-p392
```


This command will take a couple of minutes, so it's best to grab a Raider, which is now known as
[Twix](http://en.wikipedia.org/wiki/Twix "Twix").  After everything runs fine, you have to run `rbenv rehash` to rebuild
the internal rbenv libraries. The last step is to make Ruby 1.9.3-p392 the current executable on your machine:


```sh
$ rbenv global 1.9.3-p392
```


Check that the correct executable is active by exexuting `ruby -v`. The output should look like:


```sh
$ 1.9.3-p392 (set by /home/.rbenv/versions)
```


Now you are a ready to hack on with Padrino!


### Ruby Knowledge

For any non-Ruby people, I strongly advise you to check out one of these books and learn the basics of Ruby before
continuing here.


- [Programming Ruby](http://pragprog.com/book/ruby3/programming-ruby-1-9 "Programming Ruby") - the
  standard book on Ruby.
- [Poignant Guide to Ruby](http://www.scribd.com/doc/8545174/Whys-Poignant-Guide-to-Ruby "Poignant Guide To Ruby") -
  written by the nebulous programmer [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff "Stiff") in
  an entertaining and educational way.


In this book, I assume readers having Ruby knowledge and will not be explaining every last detail. I will explain Padrino-specific coding techniques and how to get most parts under test.

