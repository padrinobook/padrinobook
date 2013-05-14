## Creation Of The Models

### User Model

There are many different ways how to develop a user entity for your system. A user in our system will have an *unique*
identification number **id**, a **name**, and an **email**. You can use commands on the command-line to create models
too:


{: lang="bash" }
    $ padrino g model user name:string email:string -a app

       apply  orms/activerecord
       apply  tests/rspec
      create  app/models/user.rb
      create  app/spec/models/user_spec.rb
      create  db/migrate/001_create_users.rb


Wow, it created a quite a bunch of files for us. Let's examine each of them:


**user.rb**


{: lang="ruby" }
    # app/models/user.rb

    class User < ActiveRecord::Base
    end


All we have is an empty class which inherits from
[ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html). `ActvieRecord` provides a simple
object-relational-mapper from our models to corresponding database tables. You can also define relations between
models through associations.


{: lang="ruby" }
    # app/spec/models/user_spec.rb

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
    $ rspec spec/app/models

    User Model
      can be created (FAILED - 1)

    Failures:

      1) User Model can be created
         Failure/Error: let(:user) { User.new }
         ActiveRecord::StatementInvalid:
           Could not find table 'users'
         # ./spec/app/models/user_spec.rb:4:in `new'
         # ./spec/app/models/user_spec.rb:4:in `block (2 levels) in <top (required)>'
         # ./spec/app/models/user_spec.rb:6:in `block (2 levels) in <top (required)>'

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


This code will create a `users` table with the `name` and `email` attributes. The `id` attribute will be created
automatically unless you specify to use a different attribute as the unique key to a database entry. By the way, the
convention to name tables of models in the plural form comes from [Ruby On Rails](http://rubyonrails.org/). Now we need
to run this migration:


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
    $ sqlite3 db/job_vacancy_development.db

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
    $ rspec spec/app/models

    User Model
      can be created (FAILED - 1)

    Failures:

      1) User Model can be created
         Failure/Error: let(:user) { User.new }
         ActiveRecord::StatementInvalid:
           Could not find table 'users'
         # ./spec/app/models/user_spec.rb:4:in `new'
         # ./spec/app/models/user_spec.rb:4:in `block (2 levels) in <top (required)>'
         # ./spec/app/models/user_spec.rb:6:in `block (2 levels) in <top (required)>'

    Finished in 0.04847 seconds
    1 example, 1 failure

    Failed examples:

    rspec ./spec/app/models/user_spec.rb:5 # User Model can be created


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
    $ rspec spec/app/models

    User Model
      can be created

    Finished in 0.05492 seconds
    1 example, 0 failures


How can we run all the tests in our application and see if everything is working? Just execute `padrino rake spec`
to run all tests in the `spec/` folder:


{: lang="bash" }
    $ padrino rake spec
    => Executing Rake spec ...
    /home/helex/.rbenv/versions/1.9.3-p392/bin/ruby -S rspec ./spec/app/models/user_spec.rb -fs --color

    User Model
      can be created

    Finished in 0.05589 seconds
    1 example, 0 failures
    /home/helex/.rbenv/versions/1.9.3-p392/bin/ruby -S rspec ./spec/app/controllers/page_controller_spec.rb -fs --color

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
    $ padrino g model job_offer title:string location:string description:text contact:string time_start:date time_end:date -a app
       apply  orms/activerecord
       apply  tests/rspec
       create  app/models/job_offer.rb
       create  app/spec/models/job_offer_spec.rb
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

Since we now have created our two main models, it's time to define associations between them. Associations make common
operations like deleting or updating data in our relational database easier. Just imagine that we have a user
in our app that added many job offers in our system. Now this customer decides that he wants to cancel
his account. We decide that all his job offers should also disappear in the system. One solution would be to delete
the user, remember his id, and delete all job offers entries that originate from this id. This manual effort
disappears when associations are used: It becomes as easy as "If I delete this user from the system, delete
automatically all corresponding jobs for this user".


We will quickly browse through the associations.


**has_many**


This association is the most commonly used one. It does exactly as it tells us: One object has many other objects.
We define the association between the user and the job offers as shown in the following expression:


{: lang="ruby" }
    # app/models/user.rb

    class User < ActiveRecord::Base
      has_many :job_offers
    end


**belongs_to**


The receiving object of the *has_many* relationship defines that it belongs to exactly one object, and therefore:


{: lang="ruby" }
    # app/models/job_offer.rb

    class JobOffer < ActiveRecord::Base
      belongs_to :user
    end


**Migrate after associate**


Whenever you modify your models, remember that you need to run migrations too. Because we added the associations
manually, we also need to write the migrations. Luckily, Padrino helps us with this task a bit. We know that the
job offer is linked to a user via the user's id. This foreign key relationship results in adding an extra
column `user_id` to the `job_offers table`. For this change, we can use the following command to create a migration:


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
    => Loading development console (Padrino v.0.11.1)
    => Loading Application JobVacancy
    >>


Now you are in an environment which acts like [IRB](http://en.wikipedia.org/wiki/Interactive_Ruby_Shell), the
*Interactive Ruby* shell. This allows you to execute Ruby commands and immediately see it's response.


Let's run the shell to create a user with job offers:


{: lang="bash" }
    user = User.new(:name => 'Matthias Günther', :email => 'matthias.guenther')
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
    sqlite>.exit


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
        :time_end => '2013/03/01',
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


Ok, we are doing great so far. With users and job offers in place, let's add some tests to create and associate these
objects.


#### Testing our app with RSpec + Factory Girl

When you use data for the tests, you need to decide how to create them. You could, of course, define a set of test data
with pure SQL and add it to your app. A more convenient solution instead is to use factories and fixtures. Think
of factories as producers for you data. You are telling the factory that you need 10 users that should have different
names and emails. This kind of mass object creation which are called fixtures in testing, can easily be done with
[Factory Girl](https://github.com/thoughtbot/factory_girl). Factory Girl defines it's own language to create fixtures in
an `ActiveRecord`-like way, but with a much cleaner syntax.


What do we need to use Factory Girl in our app? Right, we first we need to add a gem to our `Gemfile`:


{: lang="ruby" }
    # Gemfile
    ...
    gem 'factory_girl', '4.2.0', :group => 'test'


If you pay a closer look into the `Gemfile`, you can see that we have several gems with the `:group` option:


{: lang="ruby" }
    # Gemfile
    ...
    gem 'rspec' , '2.13.0', :group => 'test'
    gem 'factory_girl', '4.2.0', :group => 'test'
    gem 'rack-test', '0.6.2', :require => 'rack/test', :group => 'test'


Luckily we can use the `:group <name> do ... end` syntax to cleanup  to get rid of several `:group => 'test'` lines in
our `Gemfile`:


{: lang="ruby" }
    # Gemfile

    group :test do
      gem 'rspec' , '2.13.0'
      gem 'factory_girl', '4.2.0'
      gem 'rack-test', '0.6.2', :require => 'rack/test'
    end


Execute `bundle` and the new gem will be installed.


Next we need to define a *factory* to include all the fixtures of our models:


{: lang="ruby" }
    # spec/factories.rb

    # encoding: utf-8
    FactoryGirl.define do

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
    # spec/app/models/user_spec.rb

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


The basic philosophy behind testing with fixtures is that you create objects as you need them with convenient
expressions. Instead of using `User.create`, we are using `FactoryGirl.build(:user)` to temporarily create a `user`
fixture. The job offer that we are adding for the tests is defined as an attribute hash - you map the attributes (keys)
to their values. If you run the tests, they will pass.


The `build` method that we use to create the user will only add the test object in memory. If you want to permanently
add fixtures to the database, you have to use `create` instead. Play with it, and see that the same test using `create`
instead of `build` takes much longer because it hits the database.


We can improve our test by creating a factory for our job offer too and cleaning the `user_spec.rb` file:


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
      description "We want you ..."
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

      it 'has job-offers' do
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
    # spec/app/models/user_spec.rb

    require 'spec_helper'

    describe "User Model" do
      let(:user) { build(:user) }
      it 'can be created' do
        user.should_not be_nil
      end

      it 'fresh user should have no offers' do
        user.job_offers.size.should == 0
      end

      it 'has job-offers' do
        user.job_offers.build(attributes_for(:job_offer))
        user.job_offers.size.should == 1
      end

    end


%%/* vim: set ts=2 sw=2 textwidth=120: */
