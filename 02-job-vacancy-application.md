# Job Vacancy Application

There are more IT jobs out there than there are skilled people available. It would be great if we could have the
possibility to offer a platform where users can easily post new jobs vacancies to recruit people for their company.
Now our job is to build this software using Padrino. We will apply **K.I.S.S**[^KISS] principle to obtain a very easy 
and extensible design.


First, we are going to create the applications file and folder strucutre. Then we are adding feature by feature until 
the application is complete. First, we will take a look at the basic design of our application. Afterwards, we will
implement one feature at a time.


[^KISS]: Is an acronym for *Keep it simple, stupid*.

## Creating a new application

start with generating a new project with the canonical `padrino` command. In contrast to our "Hello World!" app before, 
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


Later, when *the time comes*, we will add extra gems, for now though we'll grab the current gems usingh
Bundler[^bundler] by running at the command line:


{: lang="bash" }
    $ bundle install


[^bundler]: recall that bundler is a service to install all the required gems for a certain project.


### Basic Layout Template

Lets design our first version of the *index.html* page which is the starter page our our application. An early design
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
dynamic layout. During this chapter, we will se how to add more and more dynamic parts to our application.


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


You may have thought it a little odd that we had to manually request the index.html in the URL when viewing our start page.
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
application. Let's change this and define the *about*, *contact*, and *home* actions:


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


- `JobVacancy.controller :page` - Define the namespace *page* for our JobVacancy application. Typically, the controller
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


To see what routes you have defined for your application just call `padrino rake routes`:


{: lang="bash" }
    $ padrino rake routes
    => Executing Rake routes ...


{: lang="bash" }
    Application: JobVacancy
    URL                  REQUEST  PATH
    (:page, :about)        GET    /about
    (:page, :contact)      GET    /contact
    (:page, :home)         GET    /


This command crawls through your application looking for delicious routes and gives you a nice overview about **URL,
REQUEST**, and **PATH**.


### Application Template With ERB

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
indicators that you want to execute Ruby code to fetch data that is put into the themplate. Here, the `yield` command will 
put the content of th called page, like *about.erb* or *contact.erb*,  into the template.


### CSS design using Twitter bootstrap


The guys at Twitter were kind enough to make their CSS framework **Twitter Bootstrap** available for everyone to use. It is
available from Github at [public repository on Github](https://github.com/twitter/bootstrap/ "repository on Github"). 


Padrino itself also provides built-in templates for common tasks done on web applictions. These [padrino-recipes](https://github.com/padrino/padrino-recipes) 
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


Next we need to include the style sheet in our application template for the whole application:


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

Next we want to create the top-navigation for our application. So we already implemented the *page* controller with the
relevant actions. All we need is to put them in the front of our application.


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


- `link_to` - Is a helper for creating links. The first argument of this function is the name for the link and the
  second is for the URL (href) on which the names points to.
- `url_for` - This helper return the link which can be used as the second parameter for the `link-tag`. For example uses
  `url_for(:page, :about)` **named parameters** which were specified in our *page-controller*.  The scheme
  for this is `<:controller>, <:action>` - you can use these settings in your whole application to create clean and
  encapsulated URLs.


The structure is ready and now we need to add some sugar-candy styling for our application:


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

Now it is time to begin developing our code with tests. As mentioned in the introduction, we will *describing the
behavior of code*[^bdd] with the testing framework [RSpec](http://rspec.info/ "RSpec").


As we created our *page-controller* with `padrino g controller page`, Padrino created a spec file under *spec/app* for
us automatically. So let's examine our allready written *spec/app/controller/page_controller_spec.rb* which passes all
tests:


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


- `spec_helper` - Is a file to load commonly used functions so that they can reused in other specs.
- `describe block` - This block describes the context for our tests.
- `get ...` - Run the specified
- `last_response` - Is a response object of the fully request against you application performed by the `get` method.


Now let's run our tests with `rspec spec/page_controller_spec.rb` and see what's going on:


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


### User Model

There are many different ways how to develop a user entity for your system. A user in our system will have an *unique*
identification number **id** which is an integer (also useful for indexing our database), a **name**, and an **email**
both of which are strings.


Since there are generators for creating controllers, there is also a command-line tool for this


{: lang="bash" }
    $ padrino g model user name:string email:string

       apply  orms/activerecord
       apply  tests/rspec
      create  models/user.rb
      create  spec/models/user_spec.rb
      create  db/migrate/001_create_users.rb


Wow, it created a bunch of files for us. Let's examine each of them:


**user.rb**


{: lang="ruby" }
    # models/user.rb

    class User < ActiveRecord::Base
    end


All we have is an empty class which inherits from
[ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html). The `ActvieRecord` maps classes to
relational database tables to establish the basic implementaton of the object-relational-mapper (ORM). Classes like the
User-class are refered to models. You can also define relations between models through associations. Associations are a
way to express how models are connected to each other.


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


As you can see, the generator created alreay a test for us, which basically checks if the model can be created. What
would happen if you run the tests for this model? Let the code speak of it's own and run the tests, that what they are
made for:


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


It says exactly what happened. It wasn't able to create a new user for use because the *user* table is not present. This
leads us to the next part: Migrations.


Migrations helps you to change the database in an ordered manner. Let's have a look on our first migration:


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


We create a table called **users**. The convention to name tables of models in the plural form comes from
[Ruby On Rails](http://rubyonrails.org/). Now we need to run this migration:


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


Since we are working in development, Padrino recognized that we are working on our first migration it automatically
create the development database for us:


{: lang="bash" }
    $ ls db/
      job_vacancy_development.db  job_vacancy_test.db  migrate  schema.rb


Now we can run [sqlite3](http://www.sqlite.org/) to see, if the users table is in our development database:


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


As you can see we are creating for each different environment (*development*, *production* , and *test*) it's own
database. Now let's create the last missing database *production *with the following command:


{: lang="bash" }
    $ padrino rake ar:create:all

    bundle exec padrino rake ar:create:all
    => Executing Rake ar:create:all ...
    /home/elex/Dropbox/git-repositorie/job-vacancy/db/job_vacancy_development.db already exists
    /home/helex/Dropbox/git-repositorie/job-vacancy/db/job_vacancy_development.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_production.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_test.db already exists
    /home/helex/Dropbox/git-repositories/job-vacancy/db/job_vacancy_test.db already exists


Now we have all databases created


{: lang="bash" }
    $ ls db
    job_vacancy_development.db  job_vacancy_production.db  job_vacancy_test.db  migrate  schema.rb


If we now run our tests again, we should assume that they pass:


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


Why? Because the migration we created weren't created for our test-database.


{: lang="bash" }
    $ padrino rake ar:migrate -e test
    => Executing Rake ar:migrate ...
    ==  CreateUsers: migrating ====================================================
    -- create_table(:users)
       -> 0.0030s
    ==  CreateUsers: migrated (0.0032s) ===========================================


If we now run our tests again, we will see that they pass:


{: lang="bash" }
    $ rspec spec/models

    User Model
      can be created

    Finished in 0.05492 seconds
    1 example, 0 failures


Since we are feeling confident that everything in our application works, how can we run all the tests in our application
and see if everything is working? For this case exists the case `padrino rake spec` command, which run all the complete
tests in the `spec/` folder:


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


If you run your tests with `padrino rake spec` everything should be fine.


### Creating Connection Between User And Job Offer Model

Since we now have created our two main models, it's time to define associations between our models. A associations
makes common operations like deleting or updating data in our relational database easier. A nice side effect is that
your code becomes much easier to maintain and easy to change. Just imagine that we have a user in our application that
has many job offers in our system. Now this customers decides that he wants wants to cancel his account. Of course, all
his job offers should also disappear in the system. One solution would be to delete the user by id and delete all
entries in the job offer by the id of the user. If we are using associations between our models we can set up rules
that says: "If I delete this user from the system, delete automatically all corresponding job for this user".


**has_many**:

This ass ...


{: lang="ruby" }
    # models/user.rb

    class User < ActiveRecord::Base
      has_many :job_offers
    end


**belongs_to**:


{: lang="ruby" }
    # models/job_offer.rb

    class JobOffer < ActiveRecord::Base
      belongs_to :user
    end


Now we need to write our own migration and add for each of our job offer model the foreign key of a User. We will call
this extra column `user_id`. To create a custom migratuin we can use Padrino's migration generator:


{: lang="bash" }
    $ padrino g migration AddUserIdToJobOffers user_id:integer
    apply  orms/activerecord
    create  db/migrate/003_add_user_id_to_job_offers.rb


Now we need to change our migration:


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


This migration won't work, you have to change `joboffers` to `job_offers`. As you can, generators can help you to write
code but not prevent you from thinking.


Of course we need to run our migrations


{: lang="bash" }
   $ padrino rake ar:migrate
   $ padrino rake ar:migrate -e test


#### Testing Our Associations In The Console

The Padrino console makes it easy to interact with your application from the command line. All you have to do is to run
the following command:


{: lang="bash" }
    $ padrino c
    => Loading development console (Padrino v.0.10.7)
    => Loading Application JobVacancy
    >>


Now you are in an environment which acts like [IRB](http://en.wikipedia.org/wiki/Interactive_Ruby_Shell). IRB stand for
*Interactive Ruby Bash* and allows you the execution of Ruby commands with direct response for commands you type in.


Let's run the shell and create a user with job offers:


{: lang="bash" }
    User.new(:name => 'Matthias Günther', :email => 'matthias.guenther')
    => #<User id: nil, name: "Matthias Günther", email: "matthias.guenther", created_at: nil, updated_at: nil>
    >> user.name
    => "Matthias Günther"


This creates a user object in our session. If we want to add an entry permanten into the database, you have to use
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


Please note, that you now have an entry in your development database `db/job_vacancy_development.db`. To see this,
please perform the follow command:


{: lang="bash" }
    $ sqlite3 db/job_vacancy_development.db
    SQLite version 3.7.13 2012-06-11 02:05:22
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> SELECT * FROM users;
    1|Matthias Günther|matthias.guenther|2012-12-26 08:32:51.323349|2012-12-26 08:32:51.323349
    sqlite>


Since we are now having an user it's time to create some job offers for our first user:


{: lang="bash" }
     $ padrino c
     => Loading development console (Padrino v.0.10.7)
     => Loading Application JobVacancy
      JobOffer.create(:title => 'Padrino Engineer',
        :location => 'Berlin',
        :description => 'Come to this great place',
        :contact => 'recruter@padrino-firm.org',
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
         :contact => 'recruter@padrino-firm.org',
         :time_start => '2013/01/01',
         :time_end => '2013/03/01',
         :user_id => 1)
       ...
         => #<JobOffer id: 2, title: "Padrino Engineer 2", location: "Berlin", description: "Come to this great place",
         contact: "recruter@padrino-firm.org", time_start: "2013-01-01", time_end: "2013-03-01", created_at: "2012-12-26
         10:41:29", updated_at: "2012-12-26 10:41:29", user_id: 1>


Now it's time to test our association between the user and and the job-offer model. We will use the `find_by_id` method
to get the user from our database and the `job_offers` method to get all the job-offers from the user.


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


Here you can see the advantage of using associations: When you declare them you get automatically methods for accessing
the data you want.


Let's write tests for it:


#### Testing Our Application With RSpec + Factory Girl

We could use `ActiveRecord` for the tests but factories to create fixtures for our models are a more convenient way to
do it. A handy gem for our mission is [Factory Girl](https://github.com/thoughtbot/factory_girl). Factory Girl defines
it's own language to create fixtures in a `ActiveRecord`-way but with a much cleaner syntax.


What do we need to use it for our app? Right, first we need to add it into our `Gemfile`:


{: lang="ruby" }
    # Gemfile
    ...
    gem 'factory_girl', '~> 4.1.0', :group => test


If you pay a closer look into the `Gemfile` you can see that we have several gems with the `:group` option:


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


I'm a German and I want to use symbols from my language. To make ruby aware of this I'm putting `# encoding: utf-8` at
the header of the file. The symbol `:user` stands for the definition for user model. To made our factory available in
all our tests we just have to *require* our factory in the `spec_helper.rb`:


{: lang="ruby" }
    # spec/spec_helper.rb

    PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
    require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
    require File.dirname(__FILE__) + "/factories"
    ...


Now we have everything at hand to make user of our factories in our test:


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


Instead of using `User.create` we are using `FactoryGirl.build(:user)` to build our `user` fixture. The `:job_offer`
symbol is an attribute hash that is used as an input to build an job offer for our user - see the code in
`user.job_offers.build(job_offer)`. If you run your tests, they pass.


The `build` method will create the test object in memory. If you want to save your fixtures in the database you have to
use `create` instead. Play with it around and see that the same test using `create` instead of `build` takes much longer
because it hits the database.


Our test above doesn't look quite well. So let's create a factory for our job offer and clean up the `user_spec.rb`
afterwards:


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


And now our `user_spec`:


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


We are using now the `attributes_for` method takes a symbol as an input and will return the attributes of the fixture
model as a hash. Looks fine, and our tests are still green. But we can do even better. We can leave the verbose
`FactoryGirl` clutter word away, if we add make the following change to our `spec_helper.rb`:


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
