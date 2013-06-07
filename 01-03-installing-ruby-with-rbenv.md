## Installing Ruby With rbenv

Instead of using the build-in software package for Ruby of your operating system, we will use
[rbenv](https://github.com/sstephenson/rbenv/ "rbenv") which lets you switch between multiple versions of Ruby.


First, we need to use [git](http://git-scm.org) to get the current version of rbenv:


{: lang="bash" }
    $ cd $HOME
    $ git clone git://github.com/sstephenson/rbenv.git .rbenv


In case you shouldn't want to use git, you can also download the latest version as a zip file from
[Github](http://github.com).


You need to add the directory that contains rbenv to your `$PATH`environment variable.  If you are on Mac, you have
to replace `.bashrc` with `.bash_profile` in all of the following commands):


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


**ruby-build**

Because we don't want to download and compile different Ruby versions on our own, we will use
[ruby-build](https://github.com/sstephenson/ruby-build "ruby-build") plugin for rbenv:


{: lang="bash" }
    $ mkdir ~/.rbenv/plugins
    $ cd ~/.rbenv/plugins
    $ git clone git://github.com/sstephenson/ruby-build.git


If you now run `rbenv install` you can see all the different Ruby version you can install and use for different Ruby
projects. We are going to install `ruby 1.9.3-p392`:


{: lang="bash" }
    $ rbenv install 1.9.3-p392


This command will take a couple of minutes, so it's best to grab a Raider, which is now known as
[Twix](http://en.wikipedia.org/wiki/Twix "Twix").  After everything runs fine, you have to run `rbenv rehash` to rebuild
the internal rbenv libraries. The last step is to makeRuby 1.9.3-p392 the current executable on your machine:


{: lang="bash" }
    $ rbenv global 1.9.3-p392


Check that the correct executable is active by exexuting `ruby -v`. The output should look like:


{: lang="bash" }
    $ 1.9.3-p392 (set by /home/.rbenv/versions)


Now you are a ready to hack on with Padrino!


%%/* vim: set ts=2 sw=2 textwidth=120: */

