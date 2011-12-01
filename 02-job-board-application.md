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


## A small start ##

In a first attempt we will start with generating a new project with the normal `padrino` command
(see section \ref{section 'Hello world'}):

    $ cd ~/padrino_projects
    $ padrino generate project job_app

Next, we need to specify the used *gem* in the *Gemfile* with your favored text editor (cause I'm a
big Vim fan boy `vim Gemfile`):

    source :rubygems

    gem 'padrino', '0.10.5'
    gem 'sqlite'

Let's include the gems for our project (later when *time has come*, we will add other gems) with
bundler:

    $ bundle install

Recall from section (\ref{section 'git - put your code under version control'}) that we need to put
our achievements under strong control:

    $ cd ~/padrino_projects/job_app
    $ git init
    $ git add .
    $ git commit -m 'first commit of a marvelous padrino application'

Can you remember what the git commands are doing. If yes or no, just read the following explanation
to refresh your memory:

- `git init` - initialize a new git repository
- `git add .` - add recursively all files to staging
- `git commit -m ` - check in your changes in the repository


## Creation of a user ##

There are many different ways how to develop a user for your system. In this way, we will go conform
the standard of nearly each application. A user in our system will have an *unique* identification
number **id** (useful for indexing and entry in our database), a **name** and an **email** each a
type string.


