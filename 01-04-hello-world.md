## Hello world

The basic layout of our application is displayed on the following image application:


![Figure 1-1. Start page of the app](images/01/application_overview.jpg)


It is possible that you know this section from several tutorials, which makes you even more comfortable with
your first program.


Now, get your hands dirty and start coding.


First of all we need to install the *padrino gem*. We are using the last stable version of Padrino (during the release of
this book it is version **0.11.2**). Execute this command.


{: lang="bash" }
    $ gem install padrino


This will install all necessary dependencies and gets you ready to start. Now we will generate a fresh new Padrino
project:


{: lang="bash" }
    $ padrino generate project hello-world


Let's go through each part of this command:


- `padrino generate`: Tells Padrino to execute the generator with the specified options. The options can be
  used to create other **components** for your app, like a **mailing system** or an **admin panel** to manage your
  database entries. We will handle these things in a future chapter. A shortcut for generate is `g` which we will use
  in all following examples.
- `project`: Tells Padrino to generate a new app.
- `hello-world`: The name of the new app, which is also the directory name.


The console output should look like the following:


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


The last line in the console output tells you the next steps you have to perform. Before we start coding our app, we
need some sort of package management for Ruby gems.


Ruby has a nice package manager called [bundler](http://gembundler.com/ "Bundler") which installs all necessary gems in
the versions you would like to have for your project. This makes it very easy for other developers to work with your
project even after years. The [Gemfile](http://gembundler.com/gemfile.html "Gemfile") declares the gems that you want to
install. Bundler takes the content of the Gemfile and will install every package declared in this file. 


To install bundler, execute the following command and check the console output:


{: lang="bash" }
    $ gem install bundler
        Fetching: bundler-1.3.5.gem (100%)
        Successfully installed bundler-1.3.5
        1 gem installed


Now we have everything we need to run the `bundle` command and install our dependencies:


{: lang="bash" }
    $ cd hello-world
    $ bundle
      Fetching gem metadata from http://rubygems.org/.........

      Using rake ...
      Using ...
      Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.


Let's open the file `app/app.rb` (think of it as the root controller of your app) and insert the following code before
the last `end`:


{: lang="ruby" }
    module HelloWorld
      class App < Padrino::Application

        get "/" do
          "Hello World!"
        end

      end
    end


Now run the app with:


{: lang="bash" }
    $ bundle exec padrino start


Instead of writing `start`, we can also use the `s` alias. Now, fire up your browser with the URL
*http://localhost:3000* and see the `Hello World` Greeting being printed.


Congratulations! You've built your first Padrino app.



## Directory structure of Padrino

Navigating through the various parts of a project is essential. Thus we will go through the basic file structure of the
*hello-world* project. The app consists of the following parts:


{: lang="bash" }
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

%%/* vim: set ts=2 sw=2 textwidth=120: */
