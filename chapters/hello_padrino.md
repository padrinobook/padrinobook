## Hello Padrino

The basic layout of our application is displayed on the following image application:


![Figure 1-1. Start page of the app](images/01/application_overview.jpg)


It is possible that you know this section from several tutorials, which makes you even more comfortable with your first program.


Now, get your hands dirty and start coding.


First of all we need to install the [padrino gem](https://rubygems.org/gems/padrino "Padrino"). We are using the last stable version of Padrino (during the release of this book it is version [0.14.0.1](https://rubygems.org/gems/padrino/versions/0.14.0.1 "Padrino 0.14.0.1")). Execute this command.


```sh
$ gem install padrino
```


This will install all necessary dependencies and gets you ready to start. Now we will generate a fresh new Padrino project:


```sh
$ padrino generate project hello-padrino
```


Let's go through each part of this command:


- `padrino generate`:[^padrino-gen] Tells Padrino to execute the generator with the specified options. The options can be used to create other **components** for your app, like a **mailing system** or an **admin panel** to manage your database entries. We will handle these things in a future chapter. A shortcut for generate is `g` which we will use in all following examples.
- `project`: Tells Padrino to generate a new app.
- `hello-padrino`: The name of the new app, which is also the directory name.


[^padrino-gen]: You can also use `padrino g` or `padrino-gen` for the `generate` command, which will be used in the rest of this book

The console output should look like the following:


```sh
  create
  create  .gitignore
  create  config.ru
  create  config/apps.rb
  create  config/boot.rb
  create  public/favicon.ico
  create  public/images
  create  public/javascripts
  create  public/stylesheets
  create  .components
  create  app
  create  app/app.rb
  create  app/controllers
  create  app/helpers
  create  app/views
  create  app/views/layouts
  append  config/apps.rb
  create  Gemfile
  create  Rakefile
  create  exe/hello-padrino
  create  tmp
  create  tmp/.keep
  create  log
  create  log/.keep
skipping  orm component...
skipping  test component...
skipping  mock component...
skipping  script component...
skipping  renderer component...
skipping  stylesheet component...
identical  .components
   force  .components
   force  .components

=================================================================
hello-padrino is ready for development!
=================================================================
$ cd ./hello-padrino
$ bundle
=================================================================
```


The last line in the console output tells you the next steps you have to perform. Before we start coding our app, we need some sort of package management for Ruby gems.


Ruby has a nice package manager called [bundler](https://bundler.io/ "Bundler") which installs all necessary gems in the versions you would like to have for your project. Other developers know now how to work with your project even after years. The [Gemfile](https://bundler.io/gemfile.html#gemfiles "Gemfile") declares the gems that you want to install. Bundler takes the content of the Gemfile and will install every package declared in this file.


To install [bundler 1.14.6](https://rubygems.org/gems/bundler/versions/1.14.6 "Bundler 1.14.6"), execute the following command and check the console output:


```sh
$ gem install bundler
```


Now we have everything we need to run the `bundle` command and install our dependencies:


```sh
$ cd hello-padrino
$ bundle
  Fetching gem metadata from https://rubygems.org/.........
```


Let's open the file `app/app.rb` (think of it as the root controller of your app) and insert the following code before the last `end`:


```ruby
# app/app.rb

module HelloWorld
  class App < Padrino::Application

    get "/" do
      "Hello Padrino!"
    end

  end
end
```


Now run the app with:


```sh
$ bundle exec padrino start
```


Instead of writing `start`, we can also use the `s` alias. Now, fire up your browser with the URL <http://localhost:3000> and see the `Hello World` Greeting being printed.


Congratulations, you've built your first Padrino app!


### Directory Structure of Padrino

Navigating through the various parts of a project is essential. Thus we will go through the basic file structure of the
*hello-padrino* project. The app consists of the following parts:


```sh
|-- app
|   |-- app.rb
|   |-- controllers
|   |-- helpers
|   `-- views
|       `-- layouts
|-- bin
|-- config
|   |-- apps.rb
|   |-- boot.rb
|   `-- database.rb
|-- config.ru
|-- Gemfile
|-- Gemfile.lock
|-- public
|   |-- favicon.ico
|   |-- images
|   |-- javascripts
|   `-- stylesheets
|-- Rakefile
`-- tmp
```


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
  default route, from which requests will be handled. Here you can set site wide configurations like caching, CSRF protection, sub-app mounting, etc.
  - **boot.rb**: Basic settings for your app which will be run when you start it. Here you can turn on or off the
  error logging, enable internationalization and localization, load any prerequisites like HTML5 or Mailer helpers, etc.
  - **database.rb**: Define the adapters for all the environments in your application.
- **config.ru**: Contains the complete configuration options of the app, such as which port the app listens to, whenever
  it uses other Padrino apps as middleware and more. This file will be used when Padrino is started from the command line.
- **public**: Directory where you put static resources like images directory, JavaScript files, and style sheets. You can
  use for your asset packaging sinatra-assetpack or sprockets.
- **tmp**: This directory holds temporary files for intermediate processing like cache, tests, local mails, etc.

