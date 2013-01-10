# Job Vacancy Application

There are more IT jobs out there than there are skilled people available. It would be great if we could have the
possibility to offer a platform where users can easily post new jobs vacancies to recruit people for their company.
Now our job is to build this software using Padrino. We will apply **K.I.S.S**[^KISS] principle to obtain a very easy
and extensible design.


First, we are going to create the app file and folder structure. Then we are adding feature by feature until
the app is complete. First, we will take a look at the basic design of our app. Afterwards, we will
implement one feature at a time.


[^KISS]: Is an acronym for *Keep it simple, stupid*.


## Creating a new application

Start with generating a new project with the canonical `padrino` command. In contrast to our "Hello World!" application
(app) before,
we are using new options:


{: lang="bash" }
    $ cd ~/padrino_projects
    $ padrino g project job-vacancy -d activerecord -t rspec -s jquery -e erb -a sqlite


Explanation of the fields commands:


- **g**: Is shortcut for `generate`.
- **-d activerecord**: We are using [Active Record](https://rubygems.org/gems/activerecord "Active Record") as the
  orm library (*Object Relational Mapper*).
- **-t rspec**: We are using the [RSpec](https://github.com/dchelimsky/rspec/wiki/get-in-touch "RSpec") testing
  framework.
- **-s jquery**: Defining the JavaScript library we are using - for this app will be using the ubiquitous
  [jQuery](http://jquery.com/ "jQuery") library.
- **-e erb**: We are using [ERB](http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html "ERB") (*embedded ruby*) markup
  for writing HTML templates. An alternative is [Haml](http://haml.info/ "Haml") or [Slim](http://slim-lang.com/ "Slim"), but
  to keep the project as simple as possible, we stick with ERB. Feel free to use them if you like to.
- **-a sqlite**: Our ORM[^orm] database adapter is [sqlite](http://www.sqlite.org/ "SQLite"). It is easy to install because the whole database is saved in a text file.


Since we are using RSpec for testing, we will use its' built-in mock extensions
[rspec-mocks](https://github.com/rspec/rspec-mocks "rspec mocks") for writing tests later. In case you want to use
another mocking library like [rr](https://rubygems.org/gems/rr "rr") or [mocha](http://gofreerange.com/mocha/docs/
"mocha"), feel free to add it with the **-m** option.


You can use a vast array of other options when generating your new Padrino app, this table shows the currently available
options:


|Component | Default | Aliases | Options                                                                      |
|----------|---------|---------|------------------------------------------------------------------------------|
|orm       | none    | -d      | mongoid, activerecord, datamapper, couchrest, mongomatic, ohm, ripple, sequel|
|test      | none    | -t      | bacon, shoulda, cucumber, testspec, riot, rspec, minitest                    |
|script    | none    | -s      | prototype, rightjs, jquery, mootools, extcore, dojo                          |
|renderer  | haml    | -e      | erb, haml, slim, liquid                                                      |
|stylesheet| none    | -c      | sass, less, scss, compass                                                    |
|mock      | none    | -m      | rr, mocha                                                                    |


Besides the `project` option for generating new Padrino apps, the following table illustrates the other generators
available:


|Option     | Description
|-----------|------------------------------------------------------------------------------------------------|
|project    | Generates a completely new app from the scratch.                                               |
|app        | You can define other apps to be mounted in your main app.                                      |
|mailer     | Creating new mailers within your app.                                                          |
|controller | A controller takes date from the models and puts them into view that are rendered              |
|model      | Models describe data objects of your application                                               |
|migration  | Migrations simplify changing the database schema.                                              |
|plugin     | Creating new Padrino projects based on a template file - it's like a list of commands          |
|           | which create your new app.                                                                     |
|admin      | A very nice built-in admin dashboard.                                                          |
|admin_page | TBD                                                                                            |


Later, when *the time comes*, we will add extra gems, for now though we'll grab the current gems using
Bundler[^bundler] by running at the command line:


{: lang="bash" }
    $ bundle install


[^bundler]: recall that bundler is a service to install all the required gems for a certain project.


### Basic Layout Template

Lets design our first version of the *index.html* page which is the starter page our app. An early design
question is: Where to put the *index.html* page? Because we are not working with controllers, the easiest thing is to
put the *index.html* directly under the public folder in the project.


We are using [HTML5](http://en.wikipedia.org/wiki/HTML5 "HTML5") for the page, and add the following code into
`public/index.html`:


{: lang="html" }
    <!DOCTYPE html>
    <html lang="en-US">
      <head>
        <title>Start Page</title>
      </head>
      <body>
        <p>Hello, Padrino!</p>
      </body>
    </html>


Explanation of the parts:


- `<!DOCTYPE html>` - The *document type* tells the browser which HTML version should be used for rendering the content
  correctly.
- `<head>...</head>` - Specifying meta information like title, description, and other things, this is also the place to
  where to add CSS and JavaScript files.
- `<body>...</body>` - In this section the main content of the page is displayed.


Plain static content - this used to be the way websites were created in the beginning of the web. Today, apps provide
dynamic layout. During this chapter, we will se how to add more and more dynamic parts to our app.


We can take a look at our new page by executing the following command:


{: lang="bash" }
    $ bundle exec padrino start


You should see a message telling you that Padrino has taken the stage, and you should be able to view our created index
page by visiting [http://localhost:3000/index.html](http://localhost:3000/index.html "index.html") in your
browser.


But hey, you might ask "Why do we use the `bundle exec`command - isn't just `padrino start`enough?" The reason for this
is that we use bundler to load exactly those Ruby gems that we specified in the Gemfile. I recommend that you use
`bundle exec`for all following commands, but to focus on Padrino, I will skip this command on the following parts of
the book.


You may have thought it a little odd that we had to manually requests the index.html in the URL when viewing our start page.
This is because our app currently has now idea about **routing**. Routing is the process to recognize requeste URLs and to
forward these requests to actions of controllers. With other words: A router is like a like vending machine where you put
in money to get a coke. In this case, the machine is the *router* which *routes* your input "Want a coke" to the action
"Drop a coke in the tray"


### First Controller And Routing

Lets add some basic routes for displaying our home-, about-, and contact-page. How can we do this? With the help of a
basic routing controller. A controller makes data from you app (in our case job offers) available to the view (seeing
the details of a job offer). Now let's create a controller in Padrino names page:


{: lang="bash" }
    $ padrino g controller page


The output of this command is:


{: lang="bash" }
    create  app/controllers/page.rb
    create  app/helpers/page_helper.rb
    create  app/views/page
     apply  tests/rspec
    create  spec/app/controllers/page_controller_spec.rb


(If you have questions about the output above, please drop me a line - I think it is so clear that it doesn't need any
explanation about it.)


Lets take a closer look at our page-controller:


{: lang="ruby" }
    # app/controller/page.rb

    JobVacancy.controllers :page do
      # get :index, :map => "/foo/bar" do
      #   session[:foo] = "bar"
      #   render 'index'
      # end

      # get :sample, :map => "/sample/url", :provides => [:any, :js] do
      #   case content_type
      #     when :js then ...
      #     else ...
      # end

      # get :foo, :with => :id do
      #   "Maps to url '/foo/#{params[:id]}'"
      # end

      # get "/example" do
      #   "Hello world!"
      # end

    end


The controller above defines for our `JobVacancy` the `:page` controller with no specified routes inside the
app. Let's change this and define the *about*, *contact*, and *home* actions:


{: lang="ruby" }
    # app/controller/page.rb

    JobVacancy.controllers :page do
      get :about, :map => '/about' do
        render :erb, 'page/about'
      end

      get :contact , :map => "/contact" do
        render :erb, 'page/contact'
      end

      get :home, :map => "/" do
        render :erb, 'page/home'
      end

    end


We will go through each line:


- `JobVacancy.controller :page` - Define the namespace *page* for our JobVacancy app. Typically, the controller
  name will also be part of the route.
- `do ... end` - This expression defines a block in Ruby. Think of it as a method without a name, also called anonymous
  functions, which is passed to another function as an argument.
- `get :about, :map => '/about'` - The HTTP command *get* starts the declaration of the route followed by the
  *about* action (in the form of a Ruby *symbol*), and is finally mapped to the explicit URL */about*. When you start
  your server with `bundle exec padrino s` and visit the URL `http.//localhost:3000/about`, you can see the rendered
  output of this request.
- `render :erb, 'page/about'` - This action tells us that we want to render an the *erb* file *page/about*. This file
  is actually located at `app/views/page/about.erb` file. Normally the views are placed under
  *app/views/<controller-name>/<action-name>.<ending>*  Instead of using an ERB templates, you could also use `:haml`,
  or another template language. If you are lazy, you can leave the   option for the rendering option completely out
  and leave the matching completely for Padrino.


To see what routes you have defined for your app just call `padrino rake routes`:


{: lang="bash" }
    $ padrino rake routes
    => Executing Rake routes ...


{: lang="bash" }
    Application: JobVacancy
    URL                  REQUEST  PATH
    (:page, :about)        GET    /about
    (:page, :contact)      GET    /contact
    (:page, :home)         GET    /


This command crawls through your app looking for delicious routes and gives you a nice overview about **URL,
REQUEST**, and **PATH**.


### App Template With ERB

Although we are now able to put content (albeit static) on our site, it would be nice to have some sort of basic styling
on our web page. First we need to generate a basic template for all pages we want to create. Lets create
*app/views/application.erb*:


{: lang="html" }
    <!DOCTYPE html>
    <html lang="en-US">
      <head>
        <title>Job Vacancy - find the best jobs</title>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>


Let's see what is going on with the `<%= yield %>` line. At first you may ask what does the `<>` symbols mean. They are
indicators that you want to execute Ruby code to fetch data that is put into the template. Here, the `yield` command will
put the content of the called page, like *about.erb* or *contact.erb*,  into the template.


### CSS design using Twitter bootstrap


The guys at Twitter were kind enough to make their CSS framework **Twitter Bootstrap** available for everyone to use. It is
available from Github at [public repository on Github](https://github.com/twitter/bootstrap/ "repository on Github").


Padrino itself also provides built-in templates for common tasks done on web app. These [padrino-recipes](https://github.com/padrino/padrino-recipes)
help you saving time by not reinventing the wheel.  Thank's to [@arthur_chiu](http://twitter.com/#!/arthur_chiu "@arthur_chiu"), we use his [bootstrap-plugin](https://github.com/padrino/padrino-recipes/blob/master/plugins/bootstrap_plugin.rb) by executing:


{: lang="bash" }
    $ padrino-gen plugin bootstrap

      apply  https://github.com/padrino/padrino-recipes/raw/master/plugins/bootstrap_plugin.rb
      create    public/stylesheets/bootstrap.css
      create    public/stylesheets/bootstrap-responsive.css
      create    public/javascripts/bootstrap.js
      create    public/javascripts/bootstrap.min.js
      create    public/images/glyphicons-halflings.png
      create    public/images/glyphicons-halflings-white.png


Next we need to include the style sheet in our app template for the whole app:


{: lang="bash" }
    <!DOCTYPE html>
    <html lang="en-US">
      <head>
        <title>Job Vacancy - find the best jobs</title>
        <%= stylesheet_link_tag 'bootstrap', 'bootstrap-responsive' %>
        <%= javascript_include_tag 'bootstrap.min', 'jquery', 'jquery-ujs' %>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>


The `stylesheet_link_tag` points to the *bootstrap.min.css* in you app *public/stylesheets* directory and will
automatically create a link to this stylesheet. The `javascript_include_tag` does the same as `stylesheet_link_tag` for
your JavaScript files in the *public/javascript* directory.


TBD Add section how to integrate asset pipeline


### Navigation

Next we want to create the top-navigation for our app. So we already implemented the *page* controller with the
relevant actions. All we need is to put links to them in a navigation header for our basic layout.


{: lang="html" }
    <!DOCTYPE html>
    <html lang="en-US">
      <head>
        <title>Job Vacancy - find the best jobs</title>
        <%= stylesheet_link_tag '../assets/application' %>
        <%= javascript_include_tag '../assets/application' %>
    </head>
    <body>
      <div class=="container">
        <div class="row">
          <div class="span12 offset3">
            <span id="header">Job Vacancy Board</span>
          </div>
          <div class="row">
            <nav id="navigation">
              <div class="span2 offset4">
                <%= link_to 'Home', url_for(:page, :home) %>
              </div>
              <div class="span2">
                <%= link_to 'About', url_for(:page, :about) %>
              </div>
              <div class="span2">
                <%= link_to 'Contact', url_for(:page, :contact) %>
              </div>
            </nav>
          </div>
          <div class="row">
            <div class="span9 offset3 site">
              <%= yield %>
            </div>
          </div>
        </div>
      </div>
    </body>


Explanation of the new parts:


- `link_to` - Is a helper for creating links. The first argument to this function is the name for the link and the
  second is for the URL (href) to which the link points to.
- `url_for` - This helper return the link which can be used as the second parameter for the `link-to`. It specifies
   the `<:controller>, <:action>` which will be executed. You can use in your s helper in your whole app to
   create clean and encapsulated URLs.


Now that the we provide links to other parts of the app, lets add some sugar-candy styling to the file
`app/assets/stylesheets/site.css`:


{: lang="css" }
    # app/assets/stylesheets/site.css

    body {
      font: 18.5px Palatino, 'Palatino Linotype', Helvetica, Arial, Verdana, sans-serif;
      text-align: justify;
    }

    #header {
      font-family: Lato;
      font-size: 40px;
      font-weight: bold;
    }

    #navigation {
      padding-top: 20px;
    }

    h1 {
      font-family: Lato;
      font-size: 30px;
      margin-bottom: 20px;
    }

    .site {
      padding: 20px;
      line-height: 1.8em;
    }


I will not explain anything at this point about CSS. If you still don't know how to use it, please go through [w3c
school css](http://www.w3schools.com/css/default.asp "w3c CSS") tutorial. Since we are using the asset pipeline, we
don't need to register our new CSS file in `views/application.erb` - now you will understand why we did this.


### Writing First Tests


Our site does not list static entries of job offers that you write, but other users will be allowed to post job offers
from the internet to our site. We need to add this behavior to our site. To be on the sure side, we will implement this
behavior by writing tests first, then the code. We use the [RSpec](http://rspec.info/ "RSpec") testing framework for this.


Remember when we created the *page-controller* with `padrino g controller page`? Thereby, Padrino created a corresponding
spec file *spec/app/controller/page_controller_spec.rb* which has the following content:


{: lang="ruby" }
    require 'spec_helper'

    describe "PageController" do

      describe "GET #about" do

        it "renders the :about view" do
          get '/about'
          last_response.should be_ok
        end
      end

      describe "GET #contact" do

        it "renders the :contact view" do
          get '/contact'
          last_response.should be_ok
        end
      end

      describe "GET #home" do
        it "renders :home view" do
          get '/'
          last_response.should be_ok
        end
      end

    end


Let's explain the interesting parts:


- `spec_helper` - Is a file to load commonly used functions to setup the tests.
- `describe block` - This block describes the context for our tests. Think of it as way to group related tests.
- `get ...` - This command executes a HTTTP GET to the provided address.
- `last_response` - The response object returns the header and body of the HTTP request.


Now let's run the tests with `rspec spec/page_controller_spec.rb` and see what's going on:


{: lang="bash" }
    PageController
      GET #about
        renders the :about view
      GET #contact
        renders the :contact view
      GET #home
        renders :home view

    Finished in 0.21769 seconds
    3 examples, 0 failures


Cool, all tests passed! We didn't exactly use behavior-driven development until now, but  will do so in the next parts.


**Red-Green Cycle**


In behavior driven development (BDD) it is important to write a failing test first and then the code that satisfies the
test. The red-green cycle represents the colors that you will see when executing these test: Red first, and then
beautiful green. But once your code passes the tests, take yet a little more time to refactor your code. This little
mind shift helps you a lot to think more about the problem and how to solve it. The test suite is a nice byproduct too.


## Creation Of The Models


### User Model

There are many different ways how to develop a user entity for your system. A user in our system will have an *unique*
identification number **id** , a **name**, and an **email**. You can use commands on the command-line to create models
too:


{: lang="bash" }
    $ padrino g model user name:string email:string

       apply  orms/activerecord
       apply  tests/rspec
      create  models/user.rb
      create  spec/models/user_spec.rb
      create  db/migrate/001_create_users.rb


Wow, it created a quite a bunch of files for us. Let's examine each of them:


**user.rb**


{: lang="ruby" }
    # models/user.rb

    class User < ActiveRecord::Base
    end


All we have is an empty class which inherits from
[ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html). `ActvieRecord` provides a simple
object-relational-mapper from our models to corresponding database tables. You can also define relations between
models through associations.


**spec/models/user_spec.rb**


{: lang="ruby" }
    # models/user.rb

    require 'spec_helper'

    describe "User Model" do
      let(:user) { User.new }
      it 'can be created' do
        user.should_not be_nil
      end
    end


As you can see, the generator created already a test for us, which basically checks if the model can be created. What
would happen if you run the tests for this model? Let the code speak of it's own and run the tests, that's what they are
made for after all:


{: lang="bash" }
    $ rspec spec/models

    User Model
      can be created (FAILED - 1)

    Failures:

      1) User Model can be created
         Failure/Error: let(:user) { User.new }
         ActiveRecord::StatementInvalid:
           Could not find table 'users'
         # ./spec/models/user_spec.rb:4:in `new'
         # ./spec/models/user_spec.rb:4:in `block (2 levels) in <top (required)>'
         # ./spec/models/user_spec.rb:6:in `block (2 levels) in <top (required)>'

    Finished in 0.041 seconds
    1 example, 1 failure

    Failed examples:


Executing the test resulted in an error. However, it very explicitly told us the reason: The *user* table does not exist
yet. And how do we create one? Here, migrations enter the stage.


Migrations helps you to change the database in an ordered manner. Let's have a look at our first migration:


{: lang="ruby" }
    db/migrate/001_create_users.rb

    class CreateUsers < ActiveRecord::Migration
      def self.up
        create_table :users do |t|
          t.string :name
          t.string :email
          t.timestamps
        end
      end

      def self.down
        drop_table :users
      end
    end


This code will create a `users` table with the `name` and `email` attributes. The `id` attribute will be created automatically
unless you specify to use a different attribute as the unique key to a database entry. By the way, the convention to name
tables of models in the plural form comes from [Ruby On Rails](http://rubyonrails.org/). Now we need to run this migration:


{: lang="bash" }
    $ padrino rake ar:migrate

    => Executing Rake ar:migrate ...
      DEBUG -  (0.1ms)  select sqlite_version(*)
      DEBUG -  (143.0ms)  CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL)
      DEBUG -  (125.2ms)  CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version")
      DEBUG -  (0.2ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"
       INFO - Migrating to CreateUsers (1)
      DEBUG -  (0.1ms)  begin transaction
      ...


Since we are working in the development environment, Padrino automatically created the development database for us:


{: lang="bash" }
    $ ls db/
      job_vacancy_development.db  job_vacancy_test.db  migrate  schema.rb


Now let's start [sqlite3](http://www.sqlite.org/), connect to the database, and see if the users table was created
properly:


{: lang="bash" }
    $ sqlite3 db/job_vacanvy_development.db

    SQLite version 3.7.13 2012-06-11 02:05:22
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> .tables
    schema_migrations  users
    sqlite> .schema users
    CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "email" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
    sqlite> .exit


Let's have a look on the `config/database.rb` file to understand more about the different databases:


{: lang="ruby" }
    ActiveRecord::Base.configurations[:development] = {
      :adapter => 'sqlite3',
      :database => Padrino.root('db', 'job_vacancy_development.db')
    }

    ActiveRecord::Base.configurations[:production] = {
      :adapter => 'sqlite3',
      :database => Padrino.root('db', 'job_vacancy_production.db')
    }

    ActiveRecord::Base.configurations[:test] = {
      :adapter => 'sqlite3',
      :database => Padrino.root('db', 'job_vacancy_test.db')
    }


As you can see, each of the different environments  *development*, *production*, and *test* have their own database.
Lets's be sure that all databases are created:


{: lang="bash" }
    $ padrino rake ar:create:all

    bundle exec padrino rake ar:create:all
    => Executing Rake ar:create:all ...
    /home/elex/Dropbox/git-repositorie/job-vacancy/db/job_vacancy_development.db already exists
    /home/helex/Dropbox/git-repositorie/job-vacancy/db/job_vacancy_development.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_production.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_test.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_test.db already exists


Alright, now we are ready to re-execute the tests again.


{: lang="bash" }
    $ rspec spec/models

    User Model
      can be created (FAILED - 1)

    Failures:

      1) User Model can be created
         Failure/Error: let(:user) { User.new }
         ActiveRecord::StatementInvalid:
           Could not find table 'users'
         # ./spec/models/user_spec.rb:4:in `new'
         # ./spec/models/user_spec.rb:4:in `block (2 levels) in <top (required)>'
         # ./spec/models/user_spec.rb:6:in `block (2 levels) in <top (required)>'

    Finished in 0.04847 seconds
    1 example, 1 failure

    Failed examples:

    rspec ./spec/models/user_spec.rb:5 # User Model can be created


But why are the tests still failing? Because the migration for the *user* table was not executed for the test
environment. Let's fix this with the following command:



{: lang="bash" }
    $ padrino rake ar:migrate -e test
    => Executing Rake ar:migrate ...
    ==  CreateUsers: migrating ====================================================
    -- create_table(:users)
       -> 0.0030s
    ==  CreateUsers: migrated (0.0032s) ===========================================


Finally the test passes:


{: lang="bash" }
    $ rspec spec/models

    User Model
      can be created

    Finished in 0.05492 seconds
    1 example, 0 failures


How can we run all the tests in our application and see if everything is working? Just execute `padrino rake spec`
to run all tests in the `spec/` folder:


{: lang="bash" }
    $ padrino rake spec
    => Executing Rake spec ...
    /home/helex/.rbenv/versions/1.9.3-p286/bin/ruby -S rspec ./spec/models/user_spec.rb -fs --color

    User Model
      can be created

    Finished in 0.05589 seconds
    1 example, 0 failures
    /home/helex/.rbenv/versions/1.9.3-p286/bin/ruby -S rspec ./spec/app/controllers/page_controller_spec.rb -fs --color

    PageController
      GET #about
        renders the :about view
      GET #contact
        renders the :contact view
      GET #home
        renders the :home view

    Finished in 0.20325 seconds
    3 examples, 0 failures


This is very handy to make sure that you didn't broke anything in the existing codebase when you are working on a next
feature. Run these regression tests frequently and enjoy it to see your app growing feature by feature.


### Job Offer Model

Since we now know how to create the basic model of our users, it's time to create a model for presenting a job offer.
A job offer consists of the following attributes:


- title: The name of the job position.
- location: The geographical location of the job.
- description: Details about the position.
- contact: An email address of the contact person.
- time-start: The earliest entry date for this position.
- time-end: A job offer isn't valid forever.


Let's run the Padrino command to create the model for us:


{: lang="bash" }
    $ padrino g model job_offer title:string location:string description:text contact:string time_start:date time_end:date
       apply  orms/activerecord
       apply  tests/rspec
       create  models/job_offer.rb
       create  spec/models/job_offer_spec.rb
       create  db/migrate/002_create_job_offers.rb


Next, we need to run our new database migration so that our database has the right scheme:


{: lang="bash" }
    bundle exec padrino rake ar:migrate
    => Executing Rake ar:migrate ...
      DEBUG -  (0.4ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"
       INFO - Migrating to CreateUsers (1)
       INFO - Migrating to CreateJobOffers (2)
      DEBUG -  (0.3ms)  select sqlite_version(*)
      DEBUG -  (0.2ms)  begin transaction
    ==  CreateJobOffers: migrating ================================================
    -- create_table(:job_offers)
    ...


In order to run our tests, we also need to run our migrations for the test environment:


{: lang="bash" }
    $ padrino rake ar:migrate -e test
    => Executing Rake ar:migrate ...
    ==  CreateJobOffers: migrating ================================================
    -- create_table(:job_offers)
       -> 0.0302s
    ==  CreateJobOffers: migrated (0.0316s) =======================================


TBD: Find a way to run ar:migrate for all environments (mainly production and test)


If you run your tests with `padrino rake spec`, everything should be fine.


### Creating Connection Between User And Job Offer Model

Since we now have created our two main models, it's time to define associations between. Associations make common
operations like deleting or updating data in our relational database easier. Just imagine that we have a user
in our app that added many job offers in our system. Now this customers decides that he wants to cancel
his account. We decide that all his job offers should also disappear in the system. One solution would be to delete
the user, remember his id, and delete all job offers entries that originate from this id. This manual effort
disappears when associations are used: It becomes as easy as "If I delete this user from the system, delete
automatically all corresponding job for this user".


We will quickly browse through the associations.


**has_many**


This association is the most commonly used one. It does exactly as it tells us: One object has many other objects.
We define the association between the user and the job offers as shown in the following expression:


{: lang="ruby" }
    # models/user.rb

    class User < ActiveRecord::Base
      has_many :job_offers
    end


**belongs_to**


The receiving object of the *has_many* relationship defines that it belongs to exactly one object, and therefore:


{: lang="ruby" }
    # models/job_offer.rb

    class JobOffer < ActiveRecord::Base
      belongs_to :user
    end


**Migrate after associate**


Whenever you modify your models, remember that you need to run migrations too. Because we added the associations
manually, we also need to write the migrations. Luckily, Padrino helps us with this task a bit. We know that the
job offer is linked to an user via the user's id. This foreign key relationship results in adding an extra
column `user_id` to the User. For this change, we can use the following command to create a migration:


{: lang="bash" }
    $ padrino g migration AddUserIdToJobOffers user_id:integer
    apply  orms/activerecord
    create  db/migrate/003_add_user_id_to_job_offers.rb


Let's take a look at the created migration:


{: lang="ruby" }
    class AddUserIdToJobOffers < ActiveRecord::Migration
      def self.up
        change_table :joboffers do |t|
          t.integer :user_id
        end
      end

      def self.down
        change_table :joboffers do |t|
          t.remove :user_id
        end
      end
    end


Can you see the small bug? This migration won't work, you have to change `joboffers` to `job_offers`. For the time
being, generators can help you to write code, but not prevent you from thinking.


Finally let's run our migrations:


{: lang="bash" }
   $ padrino rake ar:migrate
   $ padrino rake ar:migrate -e test


#### Testing our associations in the console


To see whether the migrations were executed, we connected to the sqlite3 database via the command line. Let's use a
different approach and use the Padrino console this time.  All you have to do is to run the following command:


{: lang="bash" }
    $ padrino c
    => Loading development console (Padrino v.0.10.7)
    => Loading Application JobVacancy
    >>


Now you are in an environment which acts like [IRB](http://en.wikipedia.org/wiki/Interactive_Ruby_Shell), the
*Interactive Ruby* shell. This allows you to execute Ruby commands and immediately see it's response.


Let's run the shell to create a user with job offers:


{: lang="bash" }
    User.new(:name => 'Matthias Günther', :email => 'matthias.guenther')
    => #<User id: nil, name: "Matthias Günther", email: "matthias.guenther", created_at: nil, updated_at: nil>
    >> user.name
    => "Matthias Günther"


This creates a user object in our session. If we want to add an entry permanently into the database, you have to use
*create* method:


{: lang="bash" }
    User.create(:name => 'Matthias Günther', :email => 'matthias.guenther')
    DEBUG -  (0.2ms)  begin transaction
      DEBUG - SQL (114.6ms)  INSERT INTO "users" ("created_at", "email", "name", "updated_at") VALUES (?, ?, ?, ?)
      [["created_at", 2012-12-26 08:32:51 +0100], ["email", "matthias.guenther"], ["name", "Matthias Günther"],
      ["updated_at", 2012-12-26 08:32:51 +0100]]
        DEBUG -  (342.0ms)  commit transaction
        => #<User id: 1, name: "Matthias Günther", email: "matthias.guenther", created_at: "2012-12-26 08:32:51",
        updated_at: "2012-12-26 08:32:51">
      >>


Please note that now you have an entry in your development database `db/job_vacancy_development.db`. To see this,
connect to the database and execute a 'SELECT' statement::


{: lang="bash" }
    $ sqlite3 db/job_vacancy_development.db
    SQLite version 3.7.13 2012-06-11 02:05:22
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> SELECT * FROM users;
    1|Matthias Günther|matthias.guenther|2012-12-26 08:32:51.323349|2012-12-26 08:32:51.323349
    sqlite>


Since we have an user, it's time to some job offers too:


{: lang="bash" }
     $ padrino c
     => Loading development console (Padrino v.0.10.7)
     => Loading Application JobVacancy
      JobOffer.create(:title => 'Padrino Engineer',
        :location => 'Berlin',
        :description => 'Come to this great place',
        :contact => 'recruter@padrino-company.org',
        :time_start => '2013/01/01',
        :time_end => 2013/03/01',
        :user_id => 1)
      ...
        => #<JobOffer id: 1, title: "Padrino Engineer", location: "Berlin", description: "Come to this great place",
        contact: "recruter@padrino-firm.org", time_start: "2013-01-01", time_end: "2013-03-01", created_at: "2012-12-26
        10:12:07", updated_at: "2012-12-26 10:12:07", user_id: 1>


And now let's create a second one for our first user:


{: lang="bash" }
     >> JobOffer.create(:title => 'Padrino Engineer 2',
         :location => 'Berlin',
         :description => 'Come to this great place',
         :contact => 'recruter@padrino-company.org',
         :time_start => '2013/01/01',
         :time_end => '2013/03/01',
         :user_id => 1)
       ...
         => #<JobOffer id: 2, title: "Padrino Engineer 2", location: "Berlin", description: "Come to this great place",
         contact: "recruter@padrino-firm.org", time_start: "2013-01-01", time_end: "2013-03-01", created_at: "2012-12-26
         10:41:29", updated_at: "2012-12-26 10:41:29", user_id: 1>


Now it's time to test our association between the user and the job-offer model. We will use the `find_by_id` method
to get the user from our database, and the `job_offers` method to get all the job-offers from the user.


{: lang="bash" }
    >> user = User.find_by_id(1)
      DEBUG - User Load (0.6ms)  SELECT "users".* FROM "users" WHERE "users"."id" = 1 LIMIT 1
      => #<User id: 1, name: "Matthias Günther", email: "matthias.guenther", created_at: "2012-12-26 08:32:51", updated_at:
      "2012-12-26 08:32:51">
    >> user.job_offers
      DEBUG - JobOffer Load (0.6ms)  SELECT "job_offers".* FROM "job_offers" WHERE "job_offers"."user_id" = 1
      => [#<JobOffer id: 1, title: "Padrino Engineer", location: "Berlin", description: "Come to this great place",
      contact: "recruter@padrino-firm.org", time_start: "2013-01-01", time_end: "2013-03-01", created_at: "2012-12-26
      10:12:07", updated_at: "2012-12-26 10:12:07", user_id: 1>, #<JobOffer id: 2, title: "Padrino Engineer 2", location:
      "Berlin", description: "Come to this great place", contact: "recruter@padrino-firm.org", time_start: "2013-01-01",
      time_end: "2013-03-01", created_at: "2012-12-26 10:41:29", updated_at: "2012-12-26 10:41:29", user_id: 1>]


Here you can see the advantage of using associations: When you declare them, you automatically get methods for accessing
the data you want.


Ok, we are doing great so far. With users and post in place, let's add some tests to create and associate these objects.


#### Testing our app with RSpec + Factory Girl


When you use data for the tests, you need to decide how to create them. You could, of course, define a set of test data
with pure SQL and add it to your app. A more convenient solution instead is to use factories and fixtures. Think
of factories as producers for you data. You are telling the factory that you need 10 users that should have different
names and emails. This kind of mass object creation. which are called fixtures in testing, can easily be done with
[Factory Girl](https://github.com/thoughtbot/factory_girl). Factory Girl defines it's own language to create fixtures in
a `ActiveRecord`-like way, but with a much cleaner syntax.


What do we need to use Factory Girl in our app? Right, we first we need to add a gem to our `Gemfile`:


{: lang="ruby" }
    # Gemfile
    ...
    gem 'factory_girl', '~> 4.1.0', :group => test


If you pay a closer look into the `Gemfile`, you can see that we have several gems with the `:group` option:


{: lang="ruby" }
    # Gemfile
    ...
    gem 'rspec' , '~> 2.12.0', :group => 'test'
    gem 'factory_girl', '~> 4.1.0', :group => 'test'
    gem 'rack-test', '~> 0.6.2', :require => 'rack/test', :group => 'test'


Luckily we can use the `:group <name> do ... end` syntax to cleanup  to get rid of several `:group => 'test'` lines in
our `Gemfile`:


{: lang="ruby" }
    # Gemfile

    group :test do
      gem 'rspec' , '~> 2.12.0'
      gem 'factory_girl', '~> 4.1.0'
      gem 'rack-test', '~> 0.6.2', :require => 'rack/test'
    end


Execute `bundle` and the new gem will be installed.


Next we need to define a *factory* to include all the fixtures of our models:


{: lang="ruby" }
    # spec/factories.rb

    # encoding: utf-8
    FactoryGirl.define do |u|

      factory :user do
        name "Matthias Günther"
        email "matthias.guenther@wikimatze.de"
      end

    end


I want to add myself as a test user. Since I'm German, I want to use special symbols, called umlauts, from my language.
To make Ruby aware of this, I'm putting `# encoding: utf-8` at the header of the file. The symbol `:user` stands for
the definition for user model. To make our factory available in all our tests, we just have to *require* our factory
in the `spec_helper.rb`:


{: lang="ruby" }
    # spec/spec_helper.rb

    PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
    require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
    require File.dirname(__FILE__) + "/factories"
    ...


Now we have everything at hand to create a user with the factory while testing our app:


{: lang="ruby" }
    # spec/models/user_spec.rb

    require 'spec_helper'

    describe "User Model" do
      let(:user) { FactoryGirl.build(:user) }
      let(:job_offer) { {:title => 'Padrino Engineer', :location => 'Berlin', :description => 'Come to this great place'} }
      it 'can be created' do
        user.should_not be_nil
      end

      it 'fresh user should have no offers' do
        user.job_offers.size.should == 0
      end

      it 'have job-offers' do
        user.job_offers.build(job_offer)
        user.job_offers.size.should == 1
      end

    end


The basic philosophy behind testing with fixtures is that you create objects as you need them with convenient expressions.
Instead of using `User.create`, we are using `FactoryGirl.build(:user)` to temporarily create  a  `user` fixture. The
job offer that we are adding for the tests is defined as an attribute hash - you map the attributes (keys) to their values.
If you run the tests, they will pass.


The `build` method that we use to create the user will only add the test object in memory. If you want to permanently add
fixtures to the database, you have to use `create` instead. Play with it, and see that the same test using `create` instead
of `build` takes much longer because it hits the database.


We can improve our test by creating a factory for our job odder too and cleaning the `user_spec.rb` file:


{: lang="ruby" }
    # spec/factories.rb

    ...
    factory :user do
      name "Matthias Günther"
      email "matthias.guenther@wikimatze.de"
    end

    factory :job_offer do
      title "Padrino Engineer"
      location "Berlin"
      text "We want you ..."
      contact "recruter@awesome.de"
      time_start "0/01/2013"
      time_end "01/03/2013"
    end
    ...


And now we modify our `user_spec`:


{: lang="ruby" }
    # spec/user_spec.rb

    require 'spec_helper'

    describe "User Model" do
      let(:user) { FactoryGirl.build(:user) }
      it 'can be created' do
        user.should_not be_nil
      end

      it 'fresh user should have no offers' do
        user.job_offers.size.should == 0
      end

      it 'have job-offers' do
        user.job_offers.build(FactoryGirl.attributes_for(:job_offer))
        user.job_offers.size.should == 1
      end

    end


As you see, the job fixtures us created with FactoryGirls' `attributes_for` method. This method  takes a symbol as an
input and returns the attributes of the fixture as a hash.

Now, our tests are looking fine and they are still green. But we can do even better. We can remove the `FactoryGirl`
expressions if we add make the following change to our `spec_helper.rb`:


{: lang="ruby" }
    # spec/spec_helper.rb

    RSpec.configure do |conf|
      conf.include Rack::Test::Methods
      conf.include FactoryGirl::Syntax::Methods
    end


Now we can change our test to:


{: lang="ruby" }
    # spec/models/user_spec.rb

    require 'spec_helper'

    describe "User Model" do
      let(:user) { build(:user) }
      it 'can be created' do
        user.should_not be_nil
      end

      it 'fresh user should have no offers' do
        user.job_offers.size.should == 0
      end

      it 'have job-offers' do
        user.job_offers.build(attributes_for(:job_offer))
        user.job_offers.size.should == 1
      end

    end


%%/* vim: set ts=2 sw=2 textwidth=120: */
