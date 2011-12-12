# Job Board Application #

There are more IT jobs out there than people are available. It would be great if we have the
possibility to offer a platform where users can easily post new jobs offer (of course ruby and rails
jobs) to get enough people for your company.

This is the outline scenario - it's a real world example, so when your chef ask you if you know how
to create such piece of software raise your hand and say that you have some bleeding-edge technology
which fits perfect for the job.

The outline is easy, and as a developer you have implementation details with many good and cool
features in your mind. But step back from the thoughts to get started with switching your fingertips
on the keyboard. Clear your mind and take a piece of paper (or your favorite paint program) and
outline a scheme of what you want to create. Make small steps, test your code, integrate your code
often, and deploy your code. Don't worry, I will show you how you to create a healthy and motivating
work flow with many neat and small hints.  Sounds difficult in your ears? Well, actually it is, but
just start, and don't let your mind gets filled with fears and issues to hinder your daily progress.


## Creation of a user data model ##

There are many different ways how to develop a user for your system. In this way, we will go conform
the standard of nearly each application. A user in our system will have an *unique* identification
number **id** (useful for indexing and entry in our database), a **name** and an **email** each a
type string.

![Figure 2-1. user data model](images/02/user.jpg)


## Creation of a job offer data model ##

I like the **K.I.S.S**[^KISS] principle, so we will keep up the easy design. A job offer consists of
the following attributes:

- title: the concrete
- location: where the will be places
- description: what is important
- contact: an email address is sufficant - they should call you instead of vice versa
- time-start: what is the earliest date when you can start
- time-end: nothing lives forever - even a brittle job offer

Under normal circumstances it would be nice to upload an image, but we will limit this opportunity
to link to an existing image (most likely on flickr or some other image provider).

![Figure 2-2. job offer data model](images/02/job_offer.jpg)

[^KISS]: Is an acronym for *Keep it simple and stupid*.


## Basic coding of the app ##

After making some thoughts about the data models of our application it is time to put our dream into
reality.

In a first attempt we will start with generating a new project with the normal `padrino` command
(see section \ref{section 'Hello world'}) but this time it has a bunch of new options:

    $ cd ~/padrino_projects
    $ padrino g project job_app -t rspec -d activerecord -a sqlite -e haml -c sass -s jquery

Explanation of the new fields:

- **g**: is shortcut for generate (who does not love shortcut to keep you save you keystrokes)
- **-t rspec**: using the [RSpec](https://github.com/dchelimsky/rspec/wiki/get-in-touch "RSpec")
  testing framework (a later explanation about this will follow)
- **-d atciverecord**: using activerecord as the datamapper
- **-a sqlite**: specifying the orm[^orm] database adapter is [sqlite](http://www.sqlite.org/ "SQLite") -
  easy to maintainer and easy to inspect because all entries are saved in a plain text file
- **-e haml**: using [Haml](http://haml-lang.com/ "Haml")[^haml] markup as a *renderer* to describe HTML in
  better and faster way
- **-c sass**: using [Sass](http://sass-lang.com/ "Sass")[^sass] markup for describing the CSS[^css] of the
  application
- **-s jquery**: defining the script library we are using - for this app will be using the famous
  [jQuery](http://jquery.com/ "jQuery") library (other possible libraries are )

[^haml]: stands for ??? (couldn't find it out)
[^css]: stands for *Cascading Style Sheets*
[^orm]: stands for *object relational mapper*
[^sass]: stands for *Syntactical Awesome Style Sheets*

If this commands works, you have a nice green playground with all the Next, we need to specify the
used *gem* in the *Gemfile* with your favored text editor (cause I'm a big Vim fan boy `vim
Gemfile`):

    source :rubygems

    # Project requirements
    gem 'rake'
    gem 'sinatra-flash', :require => 'sinatra/flash'

    # Component requirements
    gem 'sass'
    gem 'haml'
    gem 'activerecord', :require => "active_record"
    gem 'sqlite3'

    # Test requirements
    gem 'rspec', :group => "test"
    gem 'rack-test', :require => "rack/test", :group => "test"

    # Padrino Stable Gem
    gem 'padrino', '0.10.5'

We are using the last stable version of Padrino (during the release of this book it is version
**0.10.5**). Let's include the gems for our project (later when *time has come*, we will add other
gems) with bundler[^bundler]:

    $ bundle install

[^bundler]: recall that bundler is service to install all the required gems for a certain project

Recall from section (\ref{section 'git - put your code under version control'}) that we need to put
our achievements under version control:

    $ git init
    $ git add .
    $ git commit -m 'first commit of a marvelous padrino application'

Can you remember what the git commands are doing. If yes or no, just read the following explanation
to refresh your memory:

- `git init` - initialize a new git repository
- `git add .` - add recursively all files to staging
- `git commit -m ` - check in your changes in the repository

Because we are hosting our application on [github]( "github") we need to push the project on the
platform. (TODO: installation explanation of github, maybe just a link)

    $ git remote add origin git@github.com:matthias-guenther/job_off_app.git
    $ git push origin master

![Figure 2-3. creating a new project on github](images/02/github.png)

Instead of *matthias-guenther* you have to replace this phrase with your personal github account
name.  That's it, now project is online and everyone can see it - even potential head-hunters which
want to hire you. We want to give extra credit for reader so that they can see what this project is
about. So we will add a README.md to the project

    $ git add README.md
    $ git commit -m 'add README'
    $ git push

If you want to check how it has to be, just checkout the
[sources](https://github.com/matthias-guenther/job_app "sources").


## Creating the basic layout ##

The first thing we will do, is to check out a new branch for this section. Let's fire up the console
an create a new branch

    $ git branch basic-layout
    $ git checkout basic-layout

With `git branch <name>` we create a new branch (in thins example one with the name *basic-layout*)
and with `git checkout <name>` we switch to this branch and all changes we make will only be visible
in this branch. To get an overview of all available branches type in `git branch`

    $ git branch
    * basic-layout
      master

Lets create a first version only with static content. The questions arise, where will be my
*index.html* page? Because we are not working with controllers, the easiest thing is to put the
*index.html* directly under the public folder in the project. And there you have your basic index
page. Let's start padrino with and open the browsers


Since we are done with the small feature, it is time to push our branch to the remote repository:

    $ git push origin basic-layout

