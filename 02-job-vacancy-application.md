/* vim: set ts=2 sw=2 textwidth=120: */

# Job Vacancy Application

There are more IT jobs out there than there are skilled people available. It would be great if we could have the
possibility to offer a platform where users can easily post new jobs vacancies to recruit people for their company. This
example job vacancy board is the software we will be building with Padrino. We will apply **K.I.S.S**[^KISS] principle,
so we will keep maintain a very easy and extensible design.

First, we will take a look at the basic design of our application, afterwards we are going to implement our ideas using
the Padrino framework.

[^KISS]: Is an acronym for *Keep it simple and stupid*.


## Basic Crafting Of The Application

In our first attempt we will start with generating a new project with the canonical `padrino` command (see section
\ref{section 'Hello world'}) but this time it has a bunch of new options:


    $ cd ~/padrino_projects
    $ padrino g project job-vacancy -d activerecord -t rspec -s jquery -e erb -a sqlite


Explanation of the fields for generating a new Padrino project:

- **g**: Is shortcut for `generate` (who doesn't love shortcuts to save time).
- **-d activerecord**: We are using [activerecord](https://rubygems.org/gems/activerecord "activerecord") as the
  orm[^orm].
- **-t rspec**: We are using the [RSpec](https://github.com/dchelimsky/rspec/wiki/get-in-touch "RSpec") testing
  framework.
- **-s jquery**: Defining the JavaScript library we are using - for this app will be using the ubiquitous
  [jQuery](http://jquery.com/ "jQuery") library.
- **-e erb**: We are using [ERB](http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html "ERB")[^erb] markup as a
  *renderer* to describe HTML in cleaner and faster way. We won't take [Haml](http://haml.info/ "Haml") or
  [Slim](http://slim-lang.com/ "Slim") to keep the project as simple as possible. Feel free to use them if you like to.
- **-a sqlite**: We are specifying the ORMorm[^orm] database adapter is [sqlite](http://www.sqlite.org/ "SQLite") -
  easiest database to install / configure and is ideal for beginning development plus it doesn't consume much system
  resources on you development machine.

Since we are using rspec for testing, we will use its build in mock extensions
[rspec-mocks](https://github.com/rspec/rspec-mocks "rspec mocks") for writing tests later. In case you want to use
another mocking library like [rr](https://rubygems.org/gems/rr "rr") or [mocha](http://gofreerange.com/mocha/docs/
"mocha"), feel free to add it with the **-m** option.


[^erb]: stands for *Embedded Ruby*
[^orm]: stands for *Object Relational Mapper*

You can use a vast array of other options when generating your new Padrino app, this table shows the currently available
options:


Component     Default     Aliases     Options
---------     -------     -------     ------------------------------------------------------------------------------
orm           none        -d          mongoid, activerecord, datamapper, couchrest, mongomatic, ohm, ripple, sequel
test          none        -t          bacon, shoulda, cucumber, testspec, riot, rspec, minitest
script        none        -s          prototype, rightjs, jquery, mootools, extcore, dojo
renderer      haml        -e          erb, haml, slim, liquid
stylesheet    none        -c          sass, less, scss, compass
mock          none        -m          rr, mocha


Besides the `project` option for generating new Padrino apps, the following table illustrates the other generators
available:


<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>project</td>
    <td>Generates a completely new app from the scratch.</td>
  </tr>
  <tr>
    <td>app</td>
    <td>You can define other apps to be mounted in your main app.</td>
  </tr>
  <tr>
    <td>mailer</td>
    <td>Creating new mailers within your app.</td>
  </tr>
  <tr>
    <td>controller</td>
    <td>A controller is between your views and models - it makes the model data available for displaying that data to
    the user.</td>
  </tr>
  <tr>
    <td>model</td>
    <td>Models are all about data. They help you to describe the abstractions of your data.</td>
  </tr>
  <tr>
    <td>migration</td>
    <td>Migration make it easy for changing the database schema.</td>
  </tr>
  <tr>
    <td>plugin</td>
    <td>Creating new Padrino projects based on a template file - it's like a list of commands which create your new
    app.</td>
  </tr>
  <tr>
    <td>admin</td>
    <td>A very nice built-in-admin dashboard.</td>
  </tr>
  <tr>
    <td>admin_page</td>
    <td>Have to figure this out ...</td>
  </tr>
</table>


Later, when *the time comes*, we will add extra gems, for now though we'll grab the current gems using with
Bundler[^bundler] by running at the command line:


    $ bundle install


[^bundler]: recall that bundler is a service to install all the required gems for a certain project.


### Basic Layout Template

Lets craft our first version of the *index.html* page which is somekind of starter page our our application. We are
presented early with a question; where will be my *index.html* page? Because we are not working with controllers, the
easiest thing is to put the *index.html* directly under the public folder in the project.

Of course, we want to be up-to-date with the current standards of webdevelopment, so we use the standards of
[HTML5](http://en.wikipedia.org/wiki/HTML5 "HTML5").  Add the following code into `public/index.html`:


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

This used to be the way websites were created in the beginning of the web - plain static content. Today things are a
dynamic, so our static app won't last long but for the beginning it gives a success feeling.

We can take a look at our new page by firing up our app by running the following at the command line:


    $ bundle exec padrino start


You should see a message telling you that Padrino has taken the stage, you should now be able to view the freshly
created index page by visiting [http://localhost:3000/index.html](http://localhost:3000/index.html "index.html") in your
browser. What you see will be a white page with the textline `Hello, Padrino!`.

Why using the `bundle exec`command ? Whenever you use this command, you are using gem version mentioned in the Gemfile.
Instead of using `start` you can also use `s` (we all love shortcuts, don't we?). Further on in this book I will leave
the `bundle exec` away in front of each Padrino related command for better readability of the code.

You may have though it a little odd that we had to manually use index.html in the URL when viewing our start page, this
is because our app currently has now idea about **routing**. A router recognize URLs and distributes them to actions of
controllers. With other words: A router is like a like vending machine where you put in money to get a coke. In this
case the machine is the *router* which *routes* your input "Want a coke" to the action "Print out a coke".


### First Controller And Routing

Lets add some basic routes for displaying our home-, about-, and contact-page. How can we do this? With the help of a
basic routing controller. A controller makes data from you app (in our case job offers) available to the view (seeing
the details of a job offer). Now let's create a controller in Padrino names page:


    $ padrino g controller page


The output of this command is:


    create  app/controllers/page.rb
    create  app/helpers/page_helper.rb
    create  app/views/page
     apply  tests/rspec
    create  spec/app/controllers/page_controller_spec.rb


(If you have questions about the output above, please drop me a line - I think it is so clear that it doesn't need any
explanation about it.)

Lets take a closer look at our page-controller:


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
application. Let's change this and define the *about*, *contact*, and *home* actions:


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

- `JobVacancy.controller :page` - Define the namespace *page* for our JobVacancy application.
- `do ... end` - Define a block in ruby. A block defines a space for a method without a name (called anonymous
  functions) which can be used to pass it to a function as an argument.
- `get :about, :map => '/about'` - The HTTP command *get* starts the declaration of the route followed by the
  *about* action (in the form of a Ruby *symbol*), and is finally mapped under the explicit URL */about*. When you start
  your server with `bundle exec padrino s` and visit the URL `http.//localhost:3000/about`, you can see the rendered
  output of this request.
- `render :erb, 'page/about'` - Define the path where the template for rendering should be. In our case it is the
  `app/views/page/about.erb` file. Normally the views are placed under
  *app/views/<controller-name>/<action-name>.<ending>*The `:erb` tells the renderer to look after ERB templates. You
  could also use `:haml` to indicate that you are using this template language. If you are lazy, you can leave the
  option for the rendering option completely out and leave the matching completely for Padrino.

To get an confused about what routes you have defined for your application just call `padrino rake routes`:


    $ padrino rake routes
    => Executing Rake routes ...


    Application: JobVacancy
    URL                  REQUEST  PATH
    (:page, :about)        GET    /about
    (:page, :contact)      GET    /contact
    (:page, :home)         GET    /


This command hunts through your application looking for delicious routes and gives you a nice overview about **URL,
REQUEST**, and **PATH**.


### Application Template With ERB

Although we are now able to put content (albeit static) on our site, it would be nice to have some sort of basic styling
on our web page. First we need to generate a basic template for all pages we want to create. Lets create
*app/views/application.erb*:


    <!DOCTYPE html>
    <html lang="en-US">
      <head>
        <title>Job Vacancy - find the best jobs</title>
      </head>
      <body>
        <%= yield %>
      </body>
    </html>


Let's see what is going with the `<%= yield %>` line? At first you may ask what does the `<>` symbols mean? They are
indicators for determining tags in the provided templates in which predefined variables like `yield` or istance
variables from your application will be evaluated and converted to HTML. The `yield` part is responsible for putting
the content of each page (like *about.erb* or *contact.erb*) into the layout.


### Integrating Twitter Bootstrap

The guys at Twitter were kind enough to make their CSS framework **Twitter Bootstrap** available for everyone to use by
licensing it as an open Source Project, it is available from Github at:
[public repository on Github](https://github.com/twitter/bootstrap/ "repository on Github"). Padrino uses
[padrino-recipes](https://github.com/padrino/padrino-recipes) to give templates to common task to plug in automatically
in your application without reinventing the wheel and do unnecessary tasks.  Thank's to
[@arthur_chiu](http://twitter.com/#!/arthur_chiu "@arthur_chiu"), we use his
[bootstrap-plugin](https://github.com/padrino/padrino-recipes/blob/master/plugins/bootstrap_plugin.rb).


    $ padrino-gen plugin bootstrap

      apply  https://github.com/padrino/padrino-recipes/raw/master/plugins/bootstrap_plugin.rb
      create    public/stylesheets/bootstrap.css
      create    public/stylesheets/bootstrap-responsive.css
      create    public/javascripts/bootstrap.js
      create    public/javascripts/bootstrap.min.js
      create    public/images/glyphicons-halflings.png
      create    public/images/glyphicons-halflings-white.png


Next we need to include the style sheet in our application template for the whole application:


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

Next we want to create the top-navigation for our application. So we already implemented the *page* controller with the
relevant actions. All we need is to put them in the front of our application.


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

- `link_to` - Is a helper for creating links. The first argument of this function is the name for the link and the
  second is for the URL (href) on which the names points to.
- `url_for` - This helper return the link which can be used as the second parameter for the `link-tag`. For example uses
  `url_for(:page, :about)` **named parameters** which were specified in our *page-controller*.  The scheme
  for this is `<:controller>, <:action>` - you can use these settings in your whole application to create clean and
  encapsulated URLs.


The structure is ready and now we need to add some sugar-candy styling for our application:


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

Now it is time to begin developing our code with tests. As mentioned in the introduction, we will *describing the
behavior of code*[^bdd] with the testing framework [RSpec](http://rspec.info/ "RSpec").

As we created our *page-controller* with `padrino g controller page`, Padrino created a spec file under *spec/app* for
us automatically. So let's examine our allready written *spec/app/controller/page_controller_spec.rb* which passes all
tests:


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


- `spec_helper` - Is a file to load commonly used functions so that they can reused in other specs.
- `describe block` - This block describes the context for our tests.
- `get ...` - Run the specified
- `last_response` - Is a response object of the fully request against you application performed by the `get` method.


Now let's run our tests with `rspec spec/page_controller_spec.rb` and see what's going on:


    PageController
      GET #about
        renders the :about view
      GET #contact
        renders the :contact view
      GET #home
        renders :home view

    Finished in 0.21769 seconds
    3 examples, 0 failures


Cool, all tests passed, but we didn't do test-driven development. Don't worry, we will do it in other parts of this
book.


**Red-Green Cycle**

In Behavior Driven (as well as in Test Driven) Development it is important to write a failing test (so that you get a
**red** color when running the test) first so that you know you really are testing something meaningful. Next we change
our code base to make it pass (you get a **green** when running the test). The scheme for this approach is test first,
then the implementation. But this little shift in mind set when working on production code helps you to think more about
the problem and how to solve it.

Once you have green code, you are in the position to refactor your code where you can remove duplication and enhance
design without changing the behavior of our code.


## Creation Of The Models


### User Data Model

There are many different ways how to develop a user entity for your system. A user in our system will have an *unique*
identification number **id** which is an integer (also useful for indexing our database), a **name**, and an **email**
both of which are strings.

Since there are generators for creating controllers, there is also a command-line tool for this


    $ padrino g model user name:string email:string

       apply  orms/activerecord
       apply  tests/rspec
      create  models/user.rb
      create  spec/models/user_spec.rb
      create  db/migrate/001_create_users.rb


Wow, it created a bunch of files for us. Let's examine each of them:


**user.rb**


    # models/user.rb

    class User < ActiveRecord::Base
    end

All we have is an empty class which inherits from
[ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html). The `ActvieRecord` maps classes to
relational database tables to establish the basic implementaton of the object-relational-mapper (ORM). Classes like the
User-class are refered to models. You can also define relations between models through associations. Associations are a
way to express how models are connected to each other.


**spec/models/user_spec.rb**


    # models/user.rb

    require 'spec_helper'

    describe "User Model" do
      let(:user) { User.new }
      it 'can be created' do
        user.should_not be_nil
      end
    end


As you can see, the generator created alreay a test for us, which basically checks if the model can be created. What
would happen if you run the tests for this model? Let the code speak of it's own and run the tests, that what they are
made for:


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


It says exactly what happened. It wasn't able to create a new user for use because the *user* table is not present. This
leads us to the next part: Migrations.

Migrations helps you to change the database in an ordered manner. Let's have a look on our first migration:


```ruby
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
```


We create a table called **users**. The convention to name tables of models in the plural form comes from
[Ruby On Rails](http://rubyonrails.org/). Now we need to run this migration:


    $ padrino rake ar:migrate

    => Executing Rake ar:migrate ...
      DEBUG -  (0.1ms)  select sqlite_version(*)
      DEBUG -  (143.0ms)  CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL)
      DEBUG -  (125.2ms)  CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version")
      DEBUG -  (0.2ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"
       INFO - Migrating to CreateUsers (1)
      DEBUG -  (0.1ms)  begin transaction
    ==  CreateUsers: migrating ====================================================
    -- create_table(:users)
      DEBUG -  (1.0ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "email" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
       -> 0.0030s
    ==  CreateUsers: migrated (0.0032s) ===========================================

      DEBUG -  (0.3ms)  INSERT INTO "schema_migrations" ("version") VALUES ('1')
      DEBUG -  (145.8ms)  commit transaction
      DEBUG -  (0.2ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"


Since we are working in development, Padrino recognized that we are working on our first migration it automatically
create the development database for us:


    $ ls db/
      job_vacancy_development.db  job_vacancy_test.db  migrate  schema.rb


Now we can run [sqlite3](http://www.sqlite.org/) to see, if the users table is in our development database:


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


```ruby
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
```


As you can see we are creating for each different environment (*development*, *production* , and *test*) it's own
database. Now let's create the last missing database *production *with the following command:


    $ padrino rake ar:create:all

    bundle exec padrino rake ar:create:all
    => Executing Rake ar:create:all ...
    /home/elex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_development.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_development.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_production.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_test.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_test.db already exists


Now we have all databases created


    $ ls db
    job_vacancy_development.db  job_vacancy_production.db  job_vacancy_test.db  migrate  schema.rb


If we now run our tests again, we should assume that they pass:

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


Why? Because the migration we created weren't created for our test-database.


    $ padrino rake ar:migrate -e test
    => Executing Rake ar:migrate ...
    ==  CreateUsers: migrating ====================================================
    -- create_table(:users)
       -> 0.0030s
    ==  CreateUsers: migrated (0.0032s) ===========================================


If we now run our tests again, we will see that they pass:


    $ rspec spec/models

    User Model
      can be created

    Finished in 0.05492 seconds
    1 example, 0 failures


Since we are feeling confident that everything in our application works, how can we run all the tests in our application
and see if everything is working? For this case exists the case `padrino rake spec` command, which run all the complete
tests in the `spec/` folder:


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
feature.


### Job Offer Model

Since we now know how to create the basic model of our users, it's time to create a model for presenting a job offer.
A job offer consists of the following attributes:


- title: The name of the job position.
- location: Where the job geographical location of the job.
- description: Details about the position.
- contact: An Email address of the contact person.
- time-start: What is the earliest date when you can start.
- time-end: A job offer isn't valid forever - define a scope when Nothing lives forever - even a job vacancy.


Let's run the Padrino command to create the model for us:


    $ padrino g model job_offer title:string location:string description:text contact:string time_start:date time_end:date
       apply  orms/activerecord
       apply  tests/rspec
       create  models/job_offer.rb
       create  spec/models/job_offer_spec.rb
       create  db/migrate/002_create_job_offers.rb


Next, we need to run our new database migration so that our database has the right scheme:

    bundle exec padrino rake ar:migrate
    => Executing Rake ar:migrate ...
      DEBUG -  (0.4ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"
       INFO - Migrating to CreateUsers (1)
       INFO - Migrating to CreateJobOffers (2)
      DEBUG -  (0.3ms)  select sqlite_version(*)
      DEBUG -  (0.2ms)  begin transaction
    ==  CreateJobOffers: migrating ================================================
    -- create_table(:job_offers)
      DEBUG -  (1.5ms)  CREATE TABLE "job_offers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "location" varchar(255), "description" text, "contact" varchar(255), "time_start" date, "time_end" date, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL)
       -> 0.0955s
    ==  CreateJobOffers: migrated (0.0960s) =======================================

      DEBUG -  (0.6ms)  INSERT INTO "schema_migrations" ("version") VALUES ('2')
      DEBUG -  (285.9ms)  commit transaction
      DEBUG -  (0.6ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"


In order to run our tests, we also need to run our migrations for the test environment:


    $ padrino rake ar:migrate -e test
    => Executing Rake ar:migrate ...
    ==  CreateJobOffers: migrating ================================================
    -- create_table(:job_offers)
       -> 0.0302s
    ==  CreateJobOffers: migrated (0.0316s) =======================================


TBD: Find a way to run ar:migrate for all environments (mainly production and test)


If you run your tests with `padrino rake spec` everything should be fine.


