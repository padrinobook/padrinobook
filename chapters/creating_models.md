## Creating Models

### User Model
\label{sec:user_model}


There are many different ways how to develop a user entity for your system. A user in our system will have an *unique* identification number **id**, a **name**, and an **email**. We can specify the location of the model by appending the end of the generate command with `-a app` as follows:


```sh
$ padrino-gen model user name:string email:string -a app
     apply  orms/activerecord
     apply  tests/rspec
    create  app/models/user.rb
    create  spec/app/models/user_spec.rb
    create  db/migrate/001_create_users.rb
```

(If we don't use the `-a` option, the models will be added in the root `models` folder).


Wow, it created a quite a bunch of files for us. Let's examine each of them:


**user.rb**:


```ruby
# app/models/user.rb

class User < ActiveRecord::Base
end
```


All we have is an empty class which inherits from [ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html "ActiveRecord::Base"). `ActvieRecord` provides a simple object-relational-mapper from our models to corresponding database tables. You can also define relations between models through associations.


**user_spec.rb**:


```ruby
# spec/app/models/user_spec.rb

require 'spec_helper'

RSpec.describe User do
  pending "add some examples to (or delete) #{__FILE__}"
end
```


As you can see, the generator created already a test for us, which is actually pending. What would happen if you run the tests for this model? Let the code speak of it's own and run the test:


```sh
$ rspec spec/app/models/user_spec.rb


User
  add some examples to (or delete)
    (PENDING: Not yet implemented)

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) User add some examples to (or delete)
     # Not yet implemented
     # ./spec/models/matze_spec.rb:4


Finished in 0.00033 seconds (files took 1.09 seconds to load)
1 example, 0 failures, 1 pending
```


Executing the test resulted in an error. It explicitly told us the reason: The *user* table does not exist yet. And how do we create one? Here, migrations enter the stage.


**001_create_users.rb**:

Migrations helps you to change the database in an ordered manner. Let's have a look at our first migration:

```ruby
# db/migrate/001_create_users.rb

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :users
  end
end
```


This code will create a `users` table with the `name` and `email` attributes. The `timestamps` attribute is added automatically because it's most common sense that to record the last change of the property. The value `null: false` says that the `timestamp` column can have no `null` values. If you want to get an overview you can visit [column modifier page](http://guides.rubyonrails.org/active_record_migrations.html#column-modifiers "column modifier page").


By the way, the convention to name tables of models in the plural form comes from [Rails](http://rubyonrails.org "Rails"). Now we need to run this migration:


```sh
$ padrino rake ar:migrate

=> Executing Rake ar:migrate ...
  DEBUG -  (0.1ms)  select sqlite_version(*)
  DEBUG -  (143.0ms)  CREATE TABLE "schema_migrations" ("version" varchar(255)
    NOT NULL)
  DEBUG -  (125.2ms)  CREATE UNIQUE INDEX "unique_schema_migrations"
    ON "schema_migrations" ("version")
  DEBUG -  (0.2ms)  SELECT "schema_migrations"."version"
    FROM "schema_migrations"
   INFO - Migrating to CreateUsers (1)
  DEBUG -  (0.1ms)  begin transaction
  ...
```


Since we are working in the development environment, Padrino automatically created the development database for us:


```sh
$ ls db/
  job_vacancy_development.db  job_vacancy_test.db  migrate  schema.rb
```


Now let's start [sqlite3](https://www.sqlite.org "sqlite3"), connect to the database, and see if the users table was created properly:


```sh
$ sqlite3 db/job_vacancy_development.db

SQLite version 3.7.13 2012-06-11 02:05:22
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .tables
schema_migrations  users
sqlite> .schema users
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name"
  varchar(255), "email" varchar(255), "created_at" datetime NOT NULL,
  "updated_at" datetime NOT NULL);
sqlite> .exit
```


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


As you can see, each of the different environments  *development*, *production*, and *test* have their own database.  Lets's be sure that all databases are created:


```sh
$ padrino rake ar:create:all

bundle exec padrino rake ar:create:all
=> Executing Rake ar:create:all ...
/home/elex/Dropbox/git-repositorie/job-vacancy/db/job_vacancy_development.db
  already exists
```


Now the databases for *production* and *test* have been generated. Time to run the tests again:


```sh
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
```


But why are the tests still failing? Because the migration for the *user* table was not executed for the test environment. Let's fix this with the following command:


```sh
$ padrino rake ar:migrate -e test
=> Executing Rake ar:migrate ...
==  CreateUsers: migrating ====================================================
-- create_table(:users)
   -> 0.0030s
==  CreateUsers: migrated (0.0032s) ===========================================
```


Finally the test passes:


```sh
$ rspec spec/app/models

User Model
  can be created

Finished in 0.05492 seconds
1 example, 0 failures
```


How can we run all the tests in our application and see if everything is working? `padrino rake spec` will run all tests in the `spec/` folder:


```sh
$ padrino rake spec
=> Executing Rake spec ...

User Model
  can be created

Finished in 0.05589 seconds
1 example, 0 failures

PageController
  GET #about
    renders the :about view
  GET #contact
    renders the :contact view
  GET #home
    renders the :home view

Finished in 0.20325 seconds
3 examples, 0 failures
```


This is very handy to make sure that you didn't break anything in the existing codebase when you are working on a new feature. Run these regression tests frequently and enjoy it to see your app growing feature by feature.


### Job Offer Model

Since we now know how to create the basic model of our users, it's time to create a model for presenting a job offer.  A job offer consists of the following attributes:


- title: The name of the job position.
- location: The geographical location of the job.
- description: Details about the position.
- contact: An email address of the contact person.
- time-start: The earliest entry date for this position.
- time-end: A job offer isn't valid forever.


Let's run the Padrino command to create the model for us. As you see, we once again run `-a app` at the end of our generation.


```sh
$ padrino-gen model job_offer title:string location:string \
  description:text contact:string time_start:date time_end:date -a app
   apply  orms/activerecord
   apply  tests/rspec
   create  app/models/job_offer.rb
   create  spec/app/models/job_offer_spec.rb
   create  db/migrate/002_create_job_offers.rb
```

Next, we need to run our new database migration so that our database has the right scheme:


```sh
$ padrino rake ar:migrate
  => Executing Rake ar:migrate ...
    DEBUG -  (0.4ms)  SELECT "schema_migrations"."version"
      FROM "schema_migrations"
     INFO - Migrating to CreateUsers (1)
     INFO - Migrating to CreateJobOffers (2)
    DEBUG -  (0.3ms)  select sqlite_version(*)
    DEBUG -  (0.2ms)  begin transaction
  ==  CreateJobOffers: migrating ==============================================
  -- create_table(:job_offers)
  ...
```


Don't forget to run the migrations also for the test environment with `padrino rake ar:migrate -e test`


### Creating Connection Between User And Job Offer Model

It's time to define associations between the user and job offer model. But why should you take care of them? Associations make common operations like deleting or updating data our relational databases easier. Imagine that we have a user in our app that added many job offers in our system. Now this customer decides that he wants to cancel his account. We decide that all his job offers should also disappear in the system. One solution would be to delete the user, remember his id, and delete all job offers entries that originate from this id. This manual effort disappears when associations are used: It becomes as easy as "If I delete this user from the system, delete automatically all corresponding jobs for this user".



We will quickly browse through the associations.


**has_many**:


It does exactly as it tells us: One object has many other objects.


```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  has_many :job_offers
end
```


**belongs_to**


The receiving object of the *has_many* relationship defines that it belongs to exactly one object:


```ruby
# app/models/job_offer.rb

class JobOffer < ActiveRecord::Base
  belongs_to :user
end
```


**Migrations after association**:


Whenever you modify your models, remember that you need to run migrations too. Because we added the associations manually, we also need to write the migrations. Luckily, Padrino helps us with this task. We know that the job offer is linked to a user via the user's id. This foreign key relationship results in adding an extra column `user_id` to the `job_offers table`. For this change, we can use the following command to create a migration:


```sh
$ padrino-gen migration AddUserIdToJobOffers user_id:integer
    apply  orms/activerecord
    create  db/migrate/003_add_user_id_to_job_offers.rb
```


Let's take a look at the created migration:


```ruby
# db/migrate/003_add_user_id_to_job_offers.rb

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
```


Can you see the small bug? This migration won't work, you have to change `joboffers` to `job_offers`. For the time being, generators can help you to write code, but not prevent you from thinking. Run the migrations now!



### Testing Associations in the console

To see whether the migrations were executed, we connected to the sqlite3 database via the command line. Let's use a different approach and use the Padrino console this time. All you have to do is to run the following command:


```sh
$ padrino c
  => Loading Application JobVacancy
  >>
```


Now you are in an environment which acts like [IRB](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell "Interactive Ruby Shell") (Interactive Ruby Shell). This allows you to execute Ruby commands and immediately see it's response.


Let's run the shell to create a user:


```sh
user = User.new(:name => 'Matthias Günther', :email => 'matthias.guenther')
  => #<User id: nil, name: "Matthias Günther", email: "matthias.guenther",
     #created_at: nil, updated_at: nil>
```


This creates a user object in our session. If we want to add an entry permanently into the database, you can either use
[save method](https://apidock.com/rails/ActiveRecord/Base/save "save method") on the `user` object to persist
it to the databasue or use
[create method](https://apidock.com/rails/ActiveRecord/Base/create/class "create method") to persist a model during it's
creation:


```sh
User.create(:name => 'Matthias Günther', :email => 'matthias.guenther')
DEBUG -  (0.2ms)  begin transaction
  DEBUG - SQL (114.6ms)  INSERT INTO "users" ("created_at",
  "email", "name", "updated_at") VALUES (?, ?, ?, ?)
  [["created_at", 2012-12-26 08:32:51 +0100], ["email", "matthias.guenther"],
  ["name", "Matthias Günther"], ["updated_at", 2012-12-26 08:32:51 +0100]]
  DEBUG -  (342.0ms)  commit transaction
=> #<User id: 1, name: "Matthias Günther", email: "matthias.guenther",
   # created_at: "2012-12-26 08:32:51",
    updated_at: "2012-12-26 08:32:51">
```


Please note that now you have an entry in your `db/job_vacancy_development.db` database.


Since we have an user, it's time to add a job offer:


```sh
$ padrino c
=> Loading Application JobVacancy
 JobOffer.create(:title => 'Padrino Engineer',
   :location => 'Berlin',
   :description => 'Come to this great place',
   :contact => 'recruter@padrino-company.org',
   :time_start => '2013/01/01',
   :time_end => '2013/03/01',
   :user_id => 1)
```


Now it's time to test our association between the user and the job-offer model. We will use the `find_by_id`[^find_by_id] method to get the user from our database, and the `job_offers` method to get all the job-offers from the user.


There is one last thing we forget: Say you are logged in and wants to edit a user with a wrong id, like <http://localhost:3000/users/padrino/edit>. You'll get a `ActiveRecord::RecordNotFound` exception because we are using the Active Record's plain `find` method in the users controller. Let's catch the exception and return a `nil` user instead:


[^find_by_id]: This method returns `nil` if the entry cannot be found. A normal `find` method will return a `ActiveRecord::RecordNotFound` for which we then have to write a `begin` ... `rescue` construct.


```sh
>> user = User.find_by_id(1)
  DEBUG - User Load (0.6ms)  SELECT "users".* FROM "users" WHERE
  "users"."id" = 1 LIMIT 1
  => #<User id: 1, name: "Matthias Günther", email: "matthias.guenther",
     # created_at: "2012-12-26 08:32:51", updated_at: "2012-12-26 08:32:51">
>> user.job_offers
  DEBUG - JobOffer Load (0.6ms)  SELECT "job_offers".* FROM "job_offers" WHERE
  "job_offers"."user_id" = 1
  => [#<JobOffer id: 1, title: "Padrino Engineer", location: "Berlin",
  ...]
```


Here you can see the advantage of using associations: When you declare them, you automatically get methods for accessing the data you want.


Ok, we are doing great so far. With users and job offers in place, let's add some tests to create and associate these objects.


### Testing With RSpec + Factory Bot

When you use data for the tests, you need to decide how to create them. You could define a set of test data with pure SQL and add it to your app. A more convenient solution instead is to use factories and fixtures. Think of factories as producers for you data. You are telling the factory that you need 10 users that should have different names and emails. This kind of mass object creation which are called fixtures in testing, can easily be done with [Factory Bot](https://github.com/thoughtbot/factory_bot "Factory Bot")[^factory_bot]. Factory Bot defines it's own language to create fixtures in an `ActiveRecord`-like way, but with a much cleaner syntax.


[^factory_bot]: Another alternative to `factory_bot` is [fabrication](https://www.fabricationgem.org/ "Fabrication"), which has similar features as Factory Bot but only around 1.7 Millions downloads in comparison to over 35 Millions downloads of `factory_bot`. A benchmark comparison between both of them generated by [Kevin Sylvestre](https://ksylvest.com/posts/2017-08-12/fabrication-vs-factorygirl "Kevin Sylvestre") showed that there is at least only a small speed difference between both. Since `factory_bot` has the bigger community I've decided for this tool.

What do we need to use Factory Bot in our app? Right, we first we need to add a gem to our `Gemfile`:


```ruby
# Gemfile
...
gem 'factory_bot', '4.8.2', :group => 'test'
...
```


If you pay a closer look into the `Gemfile`, you can see that we have several gems with the `:group` option:


```ruby
# Gemfile
...
gem 'rspec' , '3.5.0',      :group => 'test'
gem 'factory_bot', '4.8.2', :group => 'test'
gem 'rack-test', '0.6.3',    :require  => 'rack/test', :group => 'test'
...
```


Luckily we can use the `:group <name> do ... end` syntax to cleanup to get rid of several `:group => 'test'` lines in our `Gemfile`:


```ruby
# Gemfile
...
group :test do
  gem 'rspec' , '3.5.0'
  gem 'factory_bot', '4.8.2'
  gem 'rack-test', '0.6.3', :require => 'rack/test'
end
...
```


Execute `bundle` and the new gem will be installed.


Next we need to define a [factory](http://www.rubydoc.info/gems/factory_bot/file/GETTING_STARTED.md#Defining_factories "factory") to
include all the fixtures of our models:


```ruby
# spec/factories.rb

# encoding: utf-8
FactoryBot.define do

  factory :user do
    name "Matthias Günther"
    email "matthias.guenther@wikimatze.de"
  end
end
```


I want to add myself as a test user. Since I'm German, I want to use special symbols, called mutated vowel[^vowel] from the German language.
To make Ruby aware of this, I'm putting `# encoding: utf-8` at the header of the file. The symbol `:user` stands for the definition of a user model.


[^vowel]: Their name is "Umlaut" in the German language


To make our factory available in all our tests, we have to *require* our factory in the `spec_helper.rb`:



```ruby
# spec/spec_helper.rb

RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require File.dirname(__FILE__) + "/factories"
...
```


Now we have everything at hand to create a user with the factory while testing our app:


```ruby
# spec/app/models/user_spec.rb

require 'spec_helper'

describe "User Model" do
  let(:user) { FactoryBot.build(:user) }
  let(:job_offer) { {:title => 'Padrino Engineer', :location => 'Berlin',
    :description => 'Come to this great place'} }

  it 'can be created' do
    expect(user).not_to be_nil
  end

  it 'fresh user should have no offers' do
    expect(user.job_offers.size).to eq 0
  end

  it 'have job-offers' do
    user.job_offers.build(job_offer)
    expect(user.job_offers.size).to eq 1
  end
end
```


The basic philosophy behind testing with fixtures is that you create objects as you need them with convenient expressions. Instead of using
`User.create`, we are using [FactoryBot.build](http://www.rubydoc.info/gems/factory_bot/FactoryBot/Syntax/Methods#build-instance_method "build method of FactoryBot") method to temporarily create a `user` fixture. The job offer that we are adding for the tests is defined as an attribute hash
- you map the attributes (keys) to their values.


\begin{aside}
\heading{Don't repeat yourself (DRY)}

It'a principle in software development with the goal to reduce repetition of all kinds. The principle was mentioned by Andy Hunt and Dave Thomas
in their book [The Pragmatic Programmer](https://pragprog.com/book/tpp/the-pragmatic-programmer "The Pragmatic Programmer").

For example we are using the `let(:user)` before each context in specs above so that we don't have to create the variable in each step. Or when we
are creating a new controller in Padrino by running the code generator will create the necessary files for us so that we
don't have to write them on our own.

You can apply this principle in all different areas: `documention`, `configuration`, `database schemas`, `test`, ...
\end{aside}


The `build` method that we use to create the user will only add the test object in memory[^memory]. If you want to permanently add fixtures to the database, you have to use [create](http://www.rubydoc.info/gems/factory_bot/FactoryBot/Syntax/Methods#create-instance_method "create method of FactoryBot") method instead. Play with it, and see that the same test using `create` instead of `build` takes much longer because it hits the database.


[^memory]: but only if the model has no associations, otherwise build will acts like create.


We can improve our test by creating a factory for our job offer too and cleaning the `user_spec.rb` file:


```ruby
# spec/factories.rb

...
factory :user do
  name "Matthias Günther"
  email "matthias@padrinobook.com"
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
```


And now we modify our `user_spec`:


```ruby
# spec/user_spec.rb

require 'spec_helper'

describe "User Model" do
  ...

  it 'has job-offers' do
    user.job_offers.build(FactoryBot.attributes_for(:job_offer))
    expect(user.job_offers.size).to eq 1
  end
end
```


As you see, the job fixtures are created with
[attributes_for](http://www.rubydoc.info/gems/factory_bot/FactoryBot/Syntax/Methods#attributes_for-instance_method "Factory Bots attributes_for") method. This method takes a symbol as an input and returns the attributes of the fixture as a hash.


Now, our tests are looking fine and they are still green. But we can do even better. We can remove the `FactoryBot` expressions if we add make the following change to our `spec_helper.rb`:


```ruby
# spec/spec_helper.rb

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include FactoryBot::Syntax::Methods
end
```


Now we can change our test to:


```ruby
# spec/app/models/user_spec.rb

require 'spec_helper'

describe "User Model" do
  ...

  it 'has job-offers' do
    user.job_offers.build(attributes_for(:job_offer))
    expect(user.job_offers.size).to eq 1
  end
end
```

