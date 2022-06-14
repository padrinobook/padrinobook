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


### Installing Ruby with RVM



Instead of using the build-in software package for Ruby of your operating system, we will use
[rvm](https://rvm.io/rvm/install "rvm"). RVM stands for *Ruby version manager* which let you switch between
multiple versions of Ruby.


First, we need to use [git](https://git-scm.org "git") to get the current version of rbenv:


```sh
#!/bin/bash
# https://rvm.io/rvm/install#installation
curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
source ~/.rvm/scripts/rvm
```


To check if everything is setup, please verify


```sh
$ rvm --version
rvm 1.29.12 (latest) by Michal Papis, Piotr Kuczynski, Wayne E. Seguin
[https://rvm.io]
```


If you have another operating system then just checkout the
[installation instructions](https://rvm.io/rvm/install "installation instructions").


Now we can use RVM to install the lastest ruby version:


```sh
$ rvm install ruby-3.1.2
Searching for binary rubies, this might take some time.
Found remote file https://rubies.travis-ci.org/ubuntu/20.04/x86_64/ruby-3.1.2.tar.bz2
Checking requirements for ubuntu.
Requirements installation successful.
ruby-3.1.2 - #configure
ruby-3.1.2 - #download
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
100 30.0M  100 30.0M    0     0  3514k      0  0:00:08  0:00:08 --:--:-- 4820k
No checksum for downloaded archive, recording checksum in user configuration.
ruby-3.1.2 - #validate archive
ruby-3.1.2 - #extract
ruby-3.1.2 - #validate binary
ruby-3.1.2 - #setup
ruby-3.1.2 - #gemset created /home/wm/.rvm/gems/ruby-3.1.2@global
ruby-3.1.2 - #importing gemset /home/wm/.rvm/gemsets/global.gems..........
ruby-3.1.2 - #generating global wrappers........
ruby-3.1.2 - #gemset created /home/wm/.rvm/gems/ruby-3.1.2
ruby-3.1.2 - #importing gemsetfile /home/wm/.rvm/gemsets/default.gems evaluated
to empty gem list
ruby-3.1.2 - #generating default wrappers........
```


To get an overview of other available ruby version you can run `$ rvm list known`


Check that the correct executable is active by exexuting `ruby -v`. The output should look like:


```sh
ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux]
```


Now you are a ready to hack on with Padrino!


### Ruby Knowledge

For any non-Ruby people, I strongly advise you to check out one of these books and learn the basics of Ruby before
continuing here.


- [Programming Ruby](https://pragprog.com/book/ruby4/programming-ruby-1-9-2-0 "Programming Ruby") - the
  standard book on Ruby.
- [Poignant Guide to Ruby](http://poignant.guide/ "Poignant Guide To Ruby") -
  written by [why the lucky stiff](https://en.wikipedia.org/wiki/Why_the_lucky_stiff "Stiff") in
  an entertaining and educational way.


In this book, I assume readers having Ruby knowledge and will not be explaining every last detail. I will explain
Padrino-specific coding techniques and how to get most parts under test.

