## Registration and Login

In traditional frameworks you would generate a user with a `user` model and a `users_controller` with the actions
`new`, `create`, `update`, and `delete`. And you can't forget about security these days it would be nice to to have
something at hand to save atemail the end we would need to find a method of safely storing the password for the user.


We could use you don't have to reinvent the wheel you can use Padrino's beautiful
[Admin interface](http://www.padrinorb.com/guides/padrino-admin) for your user authentication to prevent us from
reinventing the wheel. But with that we won't learn the basics and as you will see in this chapter you can make a lot of mistakes. So step into the part of creating user, sending confirmation mails, and understanding how sessions are
managed in Padrino.


### Extending the User Model

Before we are going to build the controller and the sign-up form for our application we need to specify the data each
user has.


{: lang="bash" }
    Name: String
    Email: String
    Password: String


Recording from chapter "???" we only need to add the `Password` fields to the user table:


Let's create the migration:


{: lang="bash" }
    $ padrino g migration AddRegistrationFieldsToUsers

    apply  orms/activerecord
    create  db/migrate/004_add_registration_fields_to_users.rb


And write the fields into the migration file:


{: lang="ruby" }
    # db/migrate/004_add_registration_fields_to_users.rb

    class AddRegistrationFieldsToUsers < ActiveRecord::Migration

      @fields = [:password]

      def self.up
        change_table :users do |t|
          @fields.each { |field| t.string field}
        end
      end

      def self.down
        change_table :users do |t|
          @fields.each { |field| remove_column field}
        end
      end
    end


Ok, run the migrations:


      $ padrino rake ar:migrate


### Validating attributes

Before we are going to implement what we think, we are going to write **pending** specs:


{: lang="ruby" }
    # spec/app/models/user_spec.rb

    require 'spec_helper'

    describe "User Model" do
      ...

      pending('no blank name')
      pending('no blank email')

      describe "passwords" do
        pending('no blank password')
        pending('no blank password_confirmation')
      end

      describe "when name is already used" do
        pending('should not be saved')
      end

      describe "email address" do
        pending('valid')
        pending('not valid')
      end
    end


(The *pending* word is optional. It is enough to write pending tests only in the form `it "test this"` and leaving the
do/end block away).


Before writing code to pass these specs, we need to add the `password` field to our factory:


{: lang="ruby" }
    # spec/factories.rb
    # encoding: utf-8
    FactoryGirl.define do
    ...
      factory :user do
        name  "Matthias Günther"
        email "matthias.guenther@wikimatze.de"
        password "octocat"
      end
    end


Use the encoding property to allow special symbols from Germany - you have to add them in your files where they may
occur. Let's implement the first pending test that a user can't have an empty name:


{: lang="ruby" }
    # spec/app/models/user_spec.rb
    ...

    it 'have no blank name' do
      user.name = ""
      user.save.should be_false
    end


If we run the test we get the following error:


{: lang="bash" }
    $ rspec spec

    Failures:

      1) User Model have no blank name
         Failure/Error: user.save.should be_false
           expected: false value
                got: true
         # ./spec/app/models/user_spec.rb:20:in `block (2 levels) in <top (required)>'

    Finished in 0.42945 seconds
    10 examples, 1 failure, 5 pending

    Failed examples:

    rspec ./spec/app/models/user_spec.rb:18 # User Model have no blank name


To make this test pass we need to validate the `email` property in our user model with the help of the
[presence option](http://guides.rubyonrails.org/active_record_validations_callbacks.html#presence):


{: lang="ruby" }
    # app/models/user.rb
    class User < ActiveRecord::Base
      validates :name, :presence => true

      has_many :job_offers
    end


As an exercise, Please write the validates for `email` and `password` on your own. Please consider that the
`password_confirmation` attribute can be create with the `:confirmation => true` option to the `validates :password`
setting.


We don't want to have duplicated names in our application. To simply test this we need as second user with the same
name. In order to create a second user with we need to have another mail address. In order to write the test for it, we
need to extend or factory with the [sequence function](https://github.com/thoughtbot/factory_girl/wiki/Usage#sequences-and-associations):


{: lang="ruby" }
    # spec/factories
    FactoryGirl.define do
      sequence(:email){ |n| "matthias.guenther#{n}@wikimatze.de"}

      factory :user do
        name  "Matthias Günther"
        email
        password "foo"
      end
      ...
    end


Whenever you build a new `user` fixture the value `email_number` is incremented and gives you so a fresh user
with a unique email address. You can write a test for this ability in the following way:


{: lang="ruby" }
    # spec/app/models/user_spec.rb
    describe "when name is already used" do
      let(:user_second) { build(:user) }

      it 'should not be saved' do
         user_second.save.should be_false
      end
    end


To make the test green you have to use the [uniqueness validation](http://guides.rubyonrails.org/active_record_validations_callbacks.html#uniqueness).
All what it does is to validates that the attribute's value is unique before it gets saved.


{: lang="ruby" }
    # app/models/user.rb
    class User < ActiveRecord::Base
      validates :name, :email, :password, :presence => true
      validates :name, :uniqueness => true

      has_many :job_offers
    end


Now this test is fixed. Next we are going to implement the validation for the email field:


{: lang="ruby" }
    # spec/app/models/user_spec.rb
    ...

    describe "email address" do
      it 'valid' do
        addresses = %w[thor@marvel.de hero@movie.com]
        addresses.each do |email|
          user_second.email = email
          user_second.name= email
          user_second.should be_valid
        end
      end

      it 'not valid' do
        addresses = %w[spamspamspam.de heman,test.com]
        addresses.each do |email|
          user_second.email= email
          user_second.should_not be_valid
        end
      end
    end
    ...


We can test the correctness of the `email` field with a regular expression. First we are going to define a regular
expression and use the [format validation](http://guides.rubyonrails.org/active_record_validations_callbacks.html#format) which takes our regular expression against which the field will be tested.


{: lang="ruby" }
    # app/models/user.rb
    class User < ActiveRecord::Base
    ...
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      validates :email, format: { with: VALID_EMAIL_REGEX }
    ...
    end


I> ## Regular Expressions
I>
I> [Regular expressions](http://en.wikipedia.org/wiki/Regular_expression) are your first tool when you
I> need to match certain parts (or whole) strings against a predefined pattern. The drawback of using them is that
I> you have to learn a formal language to define your patterns. I can highly
I> recommend you the [Rubular tool](http://rubular.com/) for training and trying out the expression you
I> want to use. It make it very easy to build and test your patterns against test data.


### Users Controller

Since we already have a model for potential users of our platform, it's time to create a controller for them. We are
creating in a first step our users controller four our sign up form with only one action:


{: lang="bash" }
    $ padrino g controller Users get:new
      create  app/controllers/users.rb
      create  app/helpers/users_helper.rb
      create  app/views/users
       apply  tests/rspec
      create  spec/app/controllers/users_controller_spec.rb


The new thing about the controller command above is the `get:new` option. This will create an URL route `:new` to
`users/new`.


#### Sign Up Form

The stage is set: We have the model with the tested constraints, and a controller for the user which handles the action.
Time to create a sign up form for getting new users on our platform. For this case we can use the `form_for` helper.
This method takes an object as its input and creates a form using the attributes of the object. We need this to
save/edit the attributes of the model in our controller. Create a new erb file under the users view:


{: lang="ruby" }
    # app/views/users/new.erb
    <h1>Registration</h1>

    <% form_for(@user, '/users/create') do |f| %>
      <%= f.label :name %>
      <%= f.text_field :name %>
      <%= f.label :email %>
      <%= f.text_field :email %>
      <%= f.label :password %>
      <%= f.password_field :password %>
      <%= f.label :password_confirmation %>
      <%= f.password_field :password_confirmation %>
      <p>
      <%= f.submit "Create", :class => "btn btn-primary" %>
      </p>
    <% end %>


There is a lot of stuff going on -- let's break it down:


- `form_for`: Is part of [Padrino's Form Builder](http://www.padrinorb.com/guides/application-helpers#formbuilders) and
  allows you to create standard input fields based on a model. The first argument to the function is an object (mostly a
  model), the second argument is an string (the action to which the form should be sent after a submit), and the third
  parameter are settings in form of an hash which aren't used in this example. The part `action="/users/create"` says,
  that we want to use the `create` action to the `users` controller with the `create` action.
- `f.label` and `f.text`: Will a label and text field for the attributes of your model.
- `f.password_field`: Constructs a password input, where the input is marked with stars, from the given attribute of
  the form.
- `f.submit`: Take an string as an caption for the submit button and options as hashes for additional parameter (for
  example `:class => 'long'`).


This form above will be rendered in the following HTML:


{: lang="html" }
    <form method="post" action="/users/create" accept-charset="UTF-8">  <label for="user_name">Name: </label>
      <input id="user_name" name="user[name]" type="text" />

      <label for="user_email">Email: </label>
      <input id="user_email" name="user[email]" type="text" />

      <label for="user_password">Password: </label>
      <input id="user_password" name="user[password]" type="password" />

      <label for="user_password_confirmation">Password confirmation: </label>
      <input id="user_password_confirmation" name="user[password_confirmation]" type="password" />

      <p>
      <input class="btn btn-primary" value="Create" type="submit" />
      </p>
    </form>


#### User Controller Signup Actions

We need to make sure to have the right mappings for the `/login` route in the actions in our controller:


{: lang="ruby" }
    # app/controllers/users.rb

    JobVacancy::App.controllers :users do

      get :new, :map => "/login" do
        @user = User.new
        render 'new'
      end

    end


So far so good, feel free to visit [http://localhost:3000/login](http://localhost:3000/login). Until now we are not
saving the inputs of the user. And what about the mistakes a user makes during his input? How can we display any
mistakes a user is making and preserve the things he already typed in?


If you remember of section [TBD HAVE TO LOOK UP WHERE USER CREATE/VALIDATE WAS CALLED] we can use this method for validation
before we are going to save it. Before doing two steps at a time let's code the `create` action which saves the new
registered user without going into error validation.


{: lang="ruby" }
    # app/controllers/users.rb

    post :create do
      @user = User.new(params[:user])
      @user.save
      redirect('/')
    end


Let's go through the new parts:


- `User.new(params[:users])`: Will create a new user object based on the information of the form attributes of the
  `@user` model which which were part of the form from the `views/users/new.erb` page.
- `@user.save`: Will save the user in the database.
- `redirect`: Will redirect the user to the root directory of our app.


If you send the form without any inputs, you will see that you are redirected into the root of your app. You can't
figure out what's wrong, but luckily we have logs:


{: lang="bash" }
    DEBUG -  (0.1ms)  begin transaction
    DEBUG - User Exists (0.3ms)  SELECT 1 AS one FROM "users" WHERE "users"."name" = '' LIMIT 1
    DEBUG - User Exists (0.2ms)  SELECT 1 AS one FROM "users" WHERE "users"."email" = '' LIMIT 1
    DEBUG -  (0.2ms)  rollback transaction
    DEBUG -     POST (0.0162ms) /users/create - 303 See Other
    DEBUG - TEMPLATE (0.0004ms) /page/home
    DEBUG - TEMPLATE (0.0002ms) /application
    DEBUG -      GET (0.0057ms) / - 200 OK
    DEBUG -      GET (0.0005ms) application.css?1365616902 - 200 OK
    DEBUG -      GET (0.0003ms) application.js?1365616902 - 200 OK
    DEBUG -      GET (0.0017ms) /favicon.ico - 404 Not Found


The part with the `rollback transaction` means, that user was not saved. Why? Because he violated the validation of our
user model. Try to create an `User.new` model in the console and call the `.errors` method on. You should see something
like:


{: lang="ruby" }
    => #<ActiveModel::Errors:0x9dea518 @base=#<User id: nil, name: nil, email: nil, created_at: nil,
        updated_at: nil, password: nil>, messages{:name=>["can't be blank"],
        :password=>["is too short (minimum is 5 characters)", "can't be blank"],
        :email=>["can't be blank", "is invalid"]}


We can use this information to display the errors in our form for the user to let him know what they did wrong. If you
want a dirty and quick solution, you can use the `form.error_messages`, which simply can be put at the front of our
form:


{: lang="erb" }
    # views/users/new.erb

    <% form_for(@user, '/users/create') do |f| %>
      ...
      <%= f.error_messages %>
      ...
    <% end %>


It counts the number of errors (`@user.errors.count`) and is looping through all field with their error messages.
But this will result in a big box with a bunch of error messages like the following one:


{: lang="bash" }
    5 errors prohibited this User from being saved
    There were problems with the following fields:

    Name can't be blank
    Password is too short (minimum is 5 characters)
    Password can't be blank
    Email can't be blank
    Email is invalid


This isn't something we want to ship to our customers.


Let's change this by using
[error\_message\_on method](http://www.padrinorb.com/api/Padrino/Helpers/FormHelpers.html#error_message_on-instance_method)
which returns a string containing the error message attached to the method on the object:


{: lang="erb" }
    # views/users/new.erb

    <% form_for(@user, '/users/create') do |f| %> <%= f.label :name %>
      <%= f.text_field :name %>
      <%= error_message_on @user, :name %>
      <%= f.label :email %>
      <%= f.text_field :email %>
      <%= error_message_on @user, :email %>
      <%= f.label :password %>
      <%= f.password_field :password %>
      <%= error_message_on @user, :password %>
      <%= f.label :password_confirmation %>
      <%= f.password_field :password_confirmation %>
      <%= error_message_on @user, :password_confirmation %>
      <p>
      <%= f.submit "Create", :class => "btn btn-primary" %>
      </p>
    <% end %>


We can do better and make the error text red. Let's add the `:class` at the of the `error_message_on` method with the
help of the [text-error class from bootstrap](http://twitter.github.io/bootstrap/base-css.html#forms) and using the
`:prepend` option which add text to before displaying the field error:


{: lang="erb" }
    # views/users/new.erb

    <% form_for(@user, '/users/create') do |f| %>
      <%= f.label :name %>
      <%= f.text_field :name %>
      <%= error_message_on @user, :name, :class => "text-error", :prepend => "The name " %>
      <%= f.label :email %>
      <%= f.text_field :email %>
      <%= error_message_on @user, :email, :class => "text-error", :prepend => "The email " %>
      <%= f.label :password %>
      <%= f.password_field :password %>
      <%= error_message_on @user, :password, :class => "text-error", :prepend => "The password "%>
      <%= f.label :password_confirmation %>
      <%= f.password_field :password_confirmation %>
      <%= error_message_on @user, :password_confirmation, :class => "text-error" %>
      <p>
      <%= f.submit "Create", :class => "btn btn-primary" %>
      </p>
    <% end %>


If you fill out the form with complete valid parameters and watch your log again, you can see the following log:


{: lang="bash" }
    DEBUG -  (0.2ms)  begin transaction
    DEBUG - User Exists (0.3ms)  SELECT 1 AS one FROM "users" WHERE "users"."name" = 'Testuser' LIMIT 1
    DEBUG - User Exists (0.2ms)  SELECT 1 AS one FROM "users" WHERE "users"."email" = 'admin@job-vacancy.de' LIMIT 1
    DEBUG - SQL (0.2ms)  INSERT INTO "users" ("created_at", "email", "name", "password", "updated_at") VALUES
    (?, ?, ?, ?, ?)  [["created_at", 2013-04-10 20:09:10 +0200], ["email", "admin@job-vacancy.de"],
    ["name", "Testuser"], ["password", "example"], ["updated_at", 2013-04-10 20:09:10 +0200]]
    DEBUG -  (174.1ms)  commit transaction
    DEBUG -     POST (0.1854ms) /users/create - 303 See Other
    DEBUG - TEMPLATE (0.0004ms) /page/home
    DEBUG - TEMPLATE (0.0002ms) /application
    DEBUG -      GET (0.0058ms) / - 200 OK
    DEBUG -      GET (0.0006ms) application.css?1365617350 - 200 OK
    DEBUG -      GET (0.0002ms) application.js?1365617350 - 200 OK
    DEBUG -      GET (0.0018ms) /favicon.ico - 404 Not Found


Remember that have an eye on your logs can help you to see what's going on in your back-end when you can't see it in the
front-end of your app.


I> ## What are VALUES (?, ?, ?, ?, ?) in a SQL insert query?
I>
I> These form of inserting data in your database is known as parameterized queries. A parameterized query is a query
I> in which placeholders are used for parameters and the
I> parameter values are supplied at execution time. The most important reason to use parameterized queries is to avoid
I> [SQL injection](http://en.wikipedia.org/wiki/SQL_injection) attacks. SQL injection means that SQL statements are
I> injected into input fields in order to drop tables or getting access on user related data.


### Emails

Padrino uses the [Padrino Mail gem](https://rubygems.org/gems/padrino-mailer) for sending mail. For simplification, we
are using SMTP with Gmail. First of all we need to give our application the settings for setting mails in the main
configuration file of our application `app.rb`:


{: lang="ruby" }
    # app/app.rb

    module JobVacancy
      class App < Padrino::Application
        ...
        set :delivery_method, :smtp => {
          :address => 'smtp.gmail.com',
          :port => 587,
          :user_name => '<your-gmail-account-address>',
          :password => '<secret>',
          :authentication => :plain,
        }
      end
    end


Let's get through all the different options:


- `:delivery_method`: Defines the delivery method. Possible values are [:smtp](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) (default), [:sendmail](http://en.wikipedia.org/wiki/Sendmail), `:test` (no mails will be send), and
  [:file](http://edgeguides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration) (will write the contents of the email in a file).
- `:address`: The SMTP mail address.
- `:port`: The port of the mail address.
- `:user_name`: The name of the SMTP address.
- `:password`: The password of your SMTP address.
- `:authentication`: Specify if your mail server requires authentication. The default setting is plain meaning that
   the password is not encrypted. `:login` will send the password [Base64 encoded](https://en.wikipedia.org/wiki/Base64),  [:cram_md5](http://en.wikipedia.org/wiki/CRAM-MD5) is a challenge/response authentication mechanism .
- `:domain`: This key is set up for [HELO checking](http://en.wikipedia.org/wiki/Anti-spam_techniques#HELO.2FEHLO_checking).


Prior Padrino 0.10.7 the `:enable_starttls_auto => true` was changeable. This is option is now always on true in Padrino
>= 0.11.1.


This is now the default delivery address unless it is overwritten in an individual mail definition.  We won't test the
email functionality to this point because the *Mailer gem* is already tested.


#### Quick Mail Usage

To send a first simple "Hallo" message we create an [email block](https://github.com/padrino/padrino-framework/blob/master/padrino-mailer/lib/padrino-mailer/base.rb#L86) directly in our user controller:


{: lang="ruby" }
    # app/controllers/users.rb

    post :create do
      @user = User.new(params[:user])
      if @user.save
        email do
          from "admin@job-vacancy.de"
          to "lordmatze@gmail.com"
          subject "Welcome!"
          body "hallo"
        end
        redirect('/')
      else
        render 'new'
      end
    end


Now start the app, go to the URL `http://localhost:3000/login`, and register a fresh user. You can
check the log if the mail was send or you just "feel" a slow down in your application because it takes a while before
the mail is send::


{: lang="bash" }
    DEBUG - Sending email to: lordmatze@gmail.com
    Date: Sun, 14 Apr 2013 09:17:38 +0200
    From: admin@job-vacancy.de
    To: lordmatze@gmail.com
    Message-ID: <516a581243fb3_498a446f81c295e3@mg.mail>
    Subject: Welcome!
    Mime-Version: 1.0
    Content-Type: text/plain;
     charset=UTF-8
    Content-Transfer-Encoding: 7bit

    Hallo


#### Mailer

We could go on and parametrized our email example above, but this would mean that we have email code directly into our
controller code. We can do better by wrapping up the logic into an object and let it handle the action.


[Padrino mailer](http://www.padrinorb.com/api/Padrino/Mailer.html) has the `mailer` command to create customized mailer
for every purpose we want to use. Let's create the registration mailer:


{: lang="bash" }
    $ padrino g mailer Registration registration_email
      create  app/mailers/registration.rb
      create  app/views/mailers/registration


Let's break it down:


- `mailer`: The command to create a custom mailer. Inside a mailer you can define the name of your mailer object and
  it's different templates. The name of our first email is `registration_email`.
- `Registration`: Name of the mailer.


Now we let's look into the `registration.rb` file:


{: lang="ruby" }
    # app/mailers/registration.rb

    JobVacancy:App.mailer :registration do
      email :registration_email do
        # Your mailer goes here
      end
    end


The generated comment `# Your mailer goes here` says what you have to do. So let's remove the code from our `users`
controller and move it to this place.


{: lang="ruby" }
    # app/mailers/registration.rb

    JobVacancy::App.mailer :registration do
      email :registration_email do
        from "admin@job-vacancy.de"
        to "lordmatze@gmail.com"
        subject "Welcome!"
        body "Hallo"
      end
    end


Now we can use the *deliver* method to call our `:registration` mailer with it's template `:registration_email`:


{: lang="ruby" }
    # app/controller/users.rb

    ...
    post :create do
      @user = User.new(params[:user])
      if @user.save
        deliver(:registration, :registration_email)
        redirect('/')
      else
        render 'new'
      end
    end
    ...


I> Difference between Padrino's Mailer methods email and deliver
I>
I> The [email](http://www.padrinorb.com/api/Padrino/Mailer/Helpers/ClassMethods.html#email-instance_method) method is
I> has the parameters `mail_attributes = {}, &block`. That means the you write emails directly
I> `JobVacancy.email(:to => '...', :from => '...', :subject => '...', :body => '...')` or use the block syntax
I> `JobVacancy.email do ... end`. In comparison to this is the
I> [deliver](http://www.padrinorb.com/api/Padrino/Mailer/Helpers/ClassMethods.html#deliver-instance_method) method.
I> It has `mailer_name, message_name, *attributes` as attributes. In order to use this you always to create a Mailer
I> for them. If you want to use very simple mails in your application, prefer to use the email method. But if you
I> have templates with a much more complex layout in different formats (plain, HTML), the deliver method is the
I> best fit.


Instead of writing only a simple "Hallo" in our email we would like to give more input. First we need to write an
template and then use the `render` method in our registration mailer. Let's define the registration template:


{: lang="bash" }
    # app/views/mailers/registration/registration_email.plain.erb

    Hi ...,

    we are glad to have you on our platform. Feel free to post jobs and find the right people for your application.

    Your Job Vacancy!


And now we make sure that we are rendering this template in our registration mailer:


{: lang="ruby" }
    # app/mailers/registration.rb

    JobVacancy::App.mailer :registration do
      email :registration_email do
        from "admin@job-vacancy.de"
        to "lordmatze@gmail.com"
        subject "Welcome!"
        render 'registration_email'
        content_type :plain
      end
    end


If you are sure that you only want to send plain text mail, you can leave the `plain` extension away but making it
explicit will make it clear what you want to do.


To make our email more personal we want to add the name of our freshly registered user to our email template. In order
to do this we need to use enable the `locals` option.


{: lang="ruby" }
    # app/mailers/registration.rb

    JobVacancy::App.mailer :registration do
      email :registration_email do |name, email|
        from "admin@job-vacancy.de"
        to email
        subject "Welcome!"
        locals :name => name
        render 'registration_email'
        content_type :plain
      end
    end


This options enables a hash which we be used in the email template. Now we need to pass the name to the call of our
method in our `users` controller:


{: lang="ruby" }
    # app/controllers/users.rb
    ...

    post :create do
      @user = User.new(params[:user])

      if @user.save
        deliver(:registration, :registration_email, @user.name)
        redirect('/')
      else
        render 'new'
      end
    end


And update our template with the name variable:


{: lang="erb" }
    # app/views/mailers/registration/registration_email.plain.erb

    Hi <%= name %>,

    we are glad to have you on our platform. Feel free to post jobs and find the right people for your application.

    Your Job Vacancy!


Next we want to add a PDF which explains the main business needs to our page. For this purpose we create add the
`welcome.pdf` into the `/app/assets/pdf` folder. We can attach files (images, PDF, video) with the
[add_file method](https://github.com/mikel/mail/blob/master/lib/mail/message.rb#L1678) which takes a filename and the
content as hash elements as arguments.


{: lang="ruby" }
    # app/mailers/registration.rb
    ...

    email :registration_email do |name, email|
      from "admin@job-vacancy.de"
      to email
      subject "Welcome!"
      locals :name => name, :email=> email
      render 'registration_email'
      add_file :filename => 'welcome.pdf', :content => File.open("#{Padrino.root}/app/assets/pdf/welcome.pdf") { |f| f.read}
    end


Please correct me if there is a better way to get to the asset folder but that is all of what I've found.


During writing this chapter I experiment with the `content_type` option. If you set the `content_type` to plain you will
get the attachment based as binary code directly into your mail. Please put the `content_type :plain` into the
`registration` mailer. If the mail will be send you can see something like this in your logs:


{: lang="bash" }
        DEBUG - Sending email to: lordmatze@gmail.com
      Date: Thu, 18 Apr 2013 18:34:15 +0200
      From: admin@job-vacancy.de
      To: lordmatze@gmail.com
      Message-ID: <5170208754967_70f748e80108323a@mg.mail>
      Subject: Welcome!
      Mime-Version: 1.0
      Content-Type: text/plain
      Content-Transfer-Encoding: 7bit

      ----==_mimepart_517020874676e_70f748e8010829d8
      Date: Thu, 18 Apr 2013 18:34:15 +0200
      Mime-Version: 1.0
      Content-Type: text/plain;
       charset=UTF-8
      Content-Transfer-Encoding: 7bit
      Content-ID: <5170208753fd5_70f748e8010831c1@mg.mail>

      Hi Bob,

      we are glad to have you on our platform. Feel free to post jobs and find the right people for your application.

      Your Job Vacancy!

      ----==_mimepart_517020874676e_70f748e8010829d8
      Date: Thu, 18 Apr 2013 18:34:15 +0200
      Mime-Version: 1.0
      Content-Type: application/pdf;
       charset=UTF-8;
       filename=welcome2.pdf
      Content-Transfer-Encoding: base64
      Content-Disposition: attachment;
       filename=welcome2.pdf
      Content-ID: <517020874ba76_70f748e80108301@mg.mail>

      JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp
      bHRlci9GbGF0ZURlY29kZT4+CnN0cmVhbQp4nDPQM1Qo5ypUMABCM0MjBXNL
      ...
      # You don't want to read four pages of strange characters ...
      ...

      ----==_mimepart_517020874676e_70f748e8010829d8--


I> ## MIME?
I>
I> MIME stands for "Multipurpose Internet Mail Extensions" and they specify additional attributes to email headers like
I> the content type and define transfer encodings which can be used to present a higher encoded file (e.g. 8-bit)
I> with the 7-bit ASCII character set. This makes it possible to put non-English characters in the message header like
I> the subject. The goal of the MIME definition was that existing email servers had nothing to change in order to use
I> MIME types. This means that MIME headers are optional for plain text emails and so even none MIME messages can be
I> read correctly by a clients being able to read MIME encoded messages.


#### Sending Email with Confirmation Link

The basic steps for implementing the logic of email confirmation are the following:


- we need to add the *confirmation_code* and *confirmation* attributes in our user model.
- create a controller method for our user model that expects a user id and confirmation code, looks up the user, checks
  the code in the parameter matches the code saved in our database and clears the code after confirmation.
- create an action that maps to our new controller method (e.g. `/confirm/<user-id>/<code>`).
- create an mailer template which takes the user as a parameter and use the *confirmation code* of the user to send
  a mail containing a link to the new route in our controller.
- create an **observer** for our user model. if the email of the user needs to be modified or a record is created we
  need to create a confirmation code, set it in the model and clear the confirmation flag. after that we need to
  trigger our mailer.
- create a helper method which allows views to check if the current user is confirmed.
- protect our controller methods and views to prevent security issues.


I> ## Why Confirmation Mail
I>
I> Check that the user actually signed up for the account and actually wants it. This also helps you from spamming your
I> platform is going to be floated with billions of users. Another usage of this information is to give your users a
I> chance to change their password and/or stay in contact with them to inform them about updates.


### Add Confirmation Code and Confirmation Attributes to the User Model

Create a good migration which fits to the task we want to do:


{: lang="bash" }
    padrino g migration add_confirmation_code_and_confirmation_to_users
       apply  orms/activerecord
      create  db/migrate/005_add_confirmation_code_and_confirmation_to_users.rb


Now let's add the fields to a migration:


{: lang="ruby" }
    # db/migrate/005_add_confirmation_code_and_confirmation_to_users.rb

    class addconfirmationcodeandconfirmationtousers < activerecord::migration
      def self.up
        change_table :users do
          t.string :confirmation_code
          t.boolean :confirmation, :default => false
        end
      end

      def self.down
        change_table :users do
          remove_column :confirmation_code, :confirmation
        end
      end
    end


We added the `:default` option which sets the confirmation for every user to false if a new one is registered. now
let's migrate our production and test database to this new event:


{: lang="bash" }
    $ padrino ar:migrate
    $ padrino ar:migrate -e test


#### My Tests are Slow ...

During writing this book I discovered various strange behavior for my tests because I was writing data into my test
database. So the tests weren't really reliable because some worked only when the database is fresh with no preexisting
entries. One solution would be to clean up the database before each run:


{: lang="bash" }
    $ sqlite3 db/job_vacancy_test.db
      SQLite version 3.7.13 2012-06-11 02:05:22
      Enter ".help" for instructions
      Enter SQL statements terminated with a ";"
      sqlite> DELETE FROM users;
      sqlite> .quit


But after this my tests were running very slow:


{: lang="bash" }
    $ rspec spec
    ...

    Finished in 1.61 seconds
    25 examples, 0 failures


Running them again make them a little bit faster:



{: lang="bash" }
    $ rspec spec
    ...

    Finished in 0.77209 seconds
    25 examples, 0 failures


Why? Because we are hitting the database and our tests slow. Please consider code like the following:


{: lang="ruby" }
    # spec/app/models/user_spec.rb

    describe "when name is already used" do
      it 'should not be saved' do
        user.save
        user_second.name = user.name
        user_second.should_not be_valid
      end
    end

    describe "when email address is already used" do
      it 'should not save an user with an existing address' do
        user.save
        user_second.email = user.email
        user_second.save.should be_false
      end
    end


We can use mocks the saving operation away. The benefit of mocks are that you create the environment you want to test
and don't care about all the preconditions to make this test possible.


Consider the following code example:


{: lang="ruby" }

  post :create do
    user = User.find_by_email(params[:email])

    if user && user.confirmation && user.password == params[:password]
      redirect '/'
    else
      render 'new'
    end
  end


In order to test the condition `if user && user.confirmation && user.password == params[:password]` to return the
redirect we need find a User by email out of our database. A normal test would be in need to
create a user, save it and giving the object the right attributes to pass it. We can use mocks to simulate this
environment by creating a user out of our users factory, setting the attributes of this object and cheating our
`find-by-email` method to return our factory user with the right params without actually saving our object to the
database:


{: lang="ruby" }
    it "should redirect if user is correct" do
      user.confirmation = true
      User.should_receive(:find_by_email).and_return(user)
      post "sessions/create", user.attributes

      last_response.should be_redirect
    end


The magic behind mocking is to use the [should_receive](https://github.com/rspec/rspec-mocks#message-expectations) and
[and_return](https://github.com/rspec/rspec-mocks#consecutive-return-values) flow. `Should_receive` says which method
should be called and `and_return` what should be returned when the specified method is called. The line size of our
tests will remain the same - you only have to write more characters :) but this will speed up your tests in the long
term. With the help of mocks you keep your tests fast and robust.


Even if this will be the first application you write, when you've learned something new and this will make your life
easier, go back and take your time to enhance the style and design of your application.


### Controller Method and Action For Password Confirmation

When we are going to register a new user, we need to create a confirmation code like in the example above. Since this is
business logic, we will put this method inside our users model. First we will write a failing test:


{: lang="ruby" }
    # spec/app/models/user_spec.rb
    ...

      describe "confirmation code" do
        let(:user_confirmation) { build(:user) }

        it 'should not be blank' do
          user_confirmation.confirmation_code = ""
          user_confirmation.valid?.should be_false
        end
      end


To make this test pass we add the validates presence of ability in our user model:


{: lang="ruby" }
    # app/models/user.rb

    class User < ActiveRecord::Base
      ...
      validates :confirmation_code, :presence => true
      ...
    end


Next we need think of how we can set the `confirmation_code` information to our freshly created user. Instead of
creating a confirmation code on our own, we want to encrypt the password by some mechanism. Luckily, we
can use [bcrypt gem](https://github.com/codahale/bcrypt-ruby/) to create our confirmation code. It is
a Ruby binding for the [OpenBSD bcrypt](http://en.wikipedia.org/wiki/OpenBSD_security_features) password hashing
algorithm. In order to use this in our app we need to add it to our `Gemfile`:


{: lang="ruby" }
    # Gemfile
    ...

    # Security
    gem 'bcrypt-ruby', '3.0.1', :require => 'bcrypt'


Now let's open the console and play around with this Gem:


{: lang="bash" }
    $ padrino c
    => Loading development console (Padrino v.0.11.1)
    => Loading Application JobVacancy
    >> password = "Test11111134543"
    => "Test11111134543"
    >> salt = "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
    => "$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW"
    >> BCrypt::Engine.hash_secret(password, salt)
    => "$2a$05$CCCCCCCCCCCCCCCCCCCCC.9APD.dklRtXYdki/E3XrHiCWd/rfAFu"


I> ## What is a Salt?
I> Salts are used in cryptography as random data to be put as addition to normal password to create a encrypted with the
I> help of a one-way function. A one-way function output by some input string very easily but the other way round is
I> very difficult for the computer to compute the original string from the output.
I> Salts make it more difficult for hackers to get the password via rainbow tables attacks. Rainbow tables are a huge
I> list of precomputed hashes for widely used password. If a hacker gets access to a password hash he then just
I> compare this hash with the entries. If he finds after which he was searching he got the password for the user.


We could add these methods in the users controller but that isn't something a controller should do. We better use a
[callback](http://guides.rubyonrails.org/active_record_validations_callbacks.html#callbacks-overview).
**Callbacks** are methods to run on a certain stage or life cycle of an object. Perfect, that's what we want
let's create code for it:


{: lang="ruby" }
    # app/models/user.rb

    class User < ActiveRecord::Base
      ... # The other validations

      before_save :encrypt_confirmation_code, :if => :registered? # our callback with if condition

      private
      def encrypt_confirmation_code
        self.confirmation_code = set_confirmation_code
      end

      def set_confirmation_code
        require 'bcrypt'
        salt = BCrypt::Engine.generate_salt
        confirmation_code = BCrypt::Engine.hash_secret(self.password, salt)
        normalize_confirmation_code(confirmation_code)
      end

      def normalize_confirmation_code(confirmation_code)
        confirmation_code.gsub("/", "")
      end

      def registered?
        self.new_record?
      end
    end


We won't test the methods under the private keyword, there is no customized business logic inside these methods.  We
will even not test the difficult looking `set_confirmation_code` method because there is no customized business logic
inside, and BCrypt is well tested.


I> ## Why making callbacks private?
I>
I> It is good practice to make your callbacks private so that they can called only from inside the model and no other
I> object can use these methods. Our `confirmation_code` method is public available but that is no problem, because it
I> just generates an random string.


After creating the confirmation code mechanism for our user, we need to implement a authenticate which takes the
confirmation code as an input and mark our user as *confirmed*. As always, let's begin with failing tests first:


{: lang="ruby" }
    # spec/app/models/user_spec.rb
    ...

    describe "confirmation code" do
      let(:user_confirmation) { build(:user) }

      it 'should not be blank' do
        user_confirmation.confirmation_code = ""
        user_confirmation.valid?.should be_false
      end

      it 'should authenticate user with correct confirmation code' do
        user_confirmation.save
        confirmation_of_saved_user = User.find_by_id(user_confirmation.id)
        user_confirmation.confirmation_code = confirmation_of_saved_user.confirmation_code
        user_confirmation.authenticate(user_confirmation.confirmation_code).should be_true
      end

      it 'confirmation should be set true after a user is authenticated' do
        user_confirmation.save
        confirmation_of_saved_user = User.find_by_id(user_confirmation.id)
        user_confirmation.confirmation_code = confirmation_of_saved_user.confirmation_code
        user_confirmation.authenticate(user_confirmation.confirmation_code).should be_true
        user_confirmation.confirmation.should be_true
      end

      it 'should not authenticate user with incorrect confirmation code' do
        user_confirmation.authenticate("wrong").should be_false
      end
    end


I> ## Take care of your names!?
I>
I> During writing this chapter I lost a whole hour because I had method with the same name as the `confirmation_code`
I> field. When I wanted to check `@user.confirmation_code` it always called the `confirmation_code` method which return
I> a new confirmation code. I was thinking for a long time that it returned the attribute and was wondering what's going
I> on. A couple of [pry](http://pryrepl.org/) sessions showed me nothing since I'm expected to be right. After I went
I> to the toilet I started another pry session and out of sudden I discovered my naming problem.
I>
I> Lesson learned: Breaks are great!


Before going on we need to update our `factory` for the test with the confirmation code field::


{: lang="ruby" }
    # spec/factories.rb

    # encoding: utf-8
    FactoryGirl.define do
      ...
      sequence(:confirmation_code){ "1" }
      sequence(:id){ |n| n }

      factory :user do
        id
        name
        email
        password "octocat"
        confirmation_code
      end
      ...
    end


We are making the `confirmation_code` with the value of 1 static because this make it easier for us to test the code.
Here is now the code that makes our tests green:


{: lang="ruby" }
    # app/models/user.rb

    class User < ActiveRecord::Base
      ...

      def authenticate(confirmation_code)
        return false unless @user = User.find_by_id(self.id)

        if @user.confirmation_code == self.confirmation_code
          self.confirmation = true
          self.save
          true
        else
          false
        end
      end
      ...
    end


Since our tests of our user model are now green, let's write tests for our /confirm route:


{: lang="ruby" }
    # spec/app/controllers/users_controller.rb

    describe "GET confirm" do
    let(:user) { build(:user) }
      it "render the 'users/confirm' page if user has confirmation code" do
        user.save
        get "/confirm/#{user.id}/#{user.confirmation_code.to_s}"
        last_response.should be_ok
      end

      it "redirect the :confirm if user id is wrong" do
        get "/confirm/test/#{user.confirmation_code.to_s}"
        last_response.should be_redirect
      end

      it "redirect to :confirm if confirmation id is wrong" do
        get "/confirm/#{user.id}/test"
        last_response.should be_redirect
      end
    end


To make this pass, we implement the following code:


{: lang="ruby" }
    # app/controllers/users.rb
    ...

  get :confirm, :map => "/confirm/:id/:code" do
    redirect('/') unless @user = User.find_by_id(params[:id])
    redirect('/') unless @user.authenticate(params[:code])
    render 'confirm'
  end


#### Mailer Template for Confirmation Email

If we are lazy we could add our confirmation email into the registration mailer. But if you think clearly, these are two
things that have nothing to do with each other. So let's train our memory and create another mailer:


{: lang="bash" }
    $ padrino g mailer Confirmation confirmation_email
      create  app/mailers/confirmation.rb
      create  app/views/mailers/confirmation


Now let's fill out the confirmation mailer:


{: lang="ruby" }
    # app/mailers/confirmation.rb

    JobVacancy::App.mailer :confirmation do
      CONFIRMATION_URL = "http://localhost:3000/confirm"

      email :confirmation_email do |name, email, id, link|
        from "admin@job-vacancy.de"
        subject "Please confirm your account"
        to email
        locals :name => name, :confirmation_link => "#{CONFIRMATION_URL}/#{id}/#{link}"
        render 'confirmation_email'
      end
    end


Fill the email template with "confirmation-link-life":


{: lang="erb" }
    # app/views/mailers/confirmation/confirmation_email.plain.erb

    Hi <%= name %>,

    to take fully advantage of our platform you have to follow the following link:

    <%= confirmation_link %>

    Enjoy the possibility to find the right people for your jobs.


And call this method to our users controller:


{: lang="ruby" }
    # app/controllers/users.rb

    post :create do
      @user = User.new(params[:user])

      if @user.save
        deliver(:registration, :registration_email, @user.name, @user.email)
        deliver(:confirmation, :confirmation_email, @user.name,
                @user.email,
                @user.id,
                @user.confirmation_code)
        redirect('/')
      else
        render 'new'
      end
    end


#### Observer

In the chapter[TBD done find out how to reference to other chapters] we used a callback to build the functionality with
the confirmation code generation and sending. If you think clearly we have flaws in our design:


1. The controller is sending mails but this is not the responsibility of it.
2. Our user model is blown up with authentication code.


I> ## Observers vs. Callbacks
I>
I> [Observers](http://en.wikipedia.org/wiki/Observer_pattern) are a design pattern where an object has a list of its
I> dependents called observers, and notifies them automatically if its state has changed by calling one of their methods.
I> Observers means to be decoupling responsibility. They can
I> serve as a connection point between your models and some other functionality of another subsystem. Observers "lives"
I> longer in your application and can be attached/detached at any time.
I> Callbacks life shorter - you pass it to a function to be called only once.
I> Rule of the thumb: When you use callbacks with code that isn't directly related to your model, you better put this
I> into an observer.


Here is a rough plan what we want to do:


- Create an observer in the models folder.
- Register the observer in app/app.rb.
- Attach the observer to the model so that the user model automatically calls the method of the observer.


Let's create the observer with the name `user_observer` in the models folder


{: lang="ruby" }
    # app/models/user_observer.rb

    class UserObserver < ActiveRecord::Observer
    ... # put in here the private methods of the users model
    end


(Sadly, Padrino hasn't a generate command for this but I'm having this on my list to create a pull request for this
feature.)

So we are defining our user observer with extends from the
[ActiveRecord::Observer](https://github.com/rails/rails-observers#active-record-observer). Inside this class we can
define any callbacks for each action we want to use. The most commons ones are `before_<action>` and `after_<action>`
where `<action>` is the ActiveRecord trigger method like save, update, delete, show, or get.
To see what we can move out of the user model let's have a look inside this model:


{: lang="ruby" }
    # app/models/user.rb

    class User < ActiveRecord::Base
      ... # The other validations

      before_save :encrypt_confirmation_code, :if => :registered?

      private
      def encrypt_confirmation_code
        self.confirmation_code = set_confirmation_code
      end

      def set_confirmation_code
        require 'bcrypt'
        salt = BCrypt::Engine.generate_salt
        confirmation_code = BCrypt::Engine.hash_secret(self.password, salt)
        normalize_confirmation_code(confirmation_code)
      end

      def registered?
        self.new_record?
      end

      def normalize_confirmation_code(confirmation_code)
        confirmation_code.gsub("/", "")
      end
    end


And refactor the code above into our observer:


{: lang="ruby" }
    # app/models/user_observer.rb

    class UserObserver < ActiveRecord::Observer

      private
      def encrypt_confirmation_code(user)
        user.confirmation_code = set_confirmation_code(user)
      end

      def set_confirmation_code(user)
        require 'bcrypt'
        salt = BCrypt::Engine.generate_salt
        confirmation_code = BCrypt::Engine.hash_secret(user.password, salt)
        normalize_confirmation_code(confirmation_code)
      end

      def normalize_confirmation_code(confirmation_code)
        confirmation_code.gsub("/", "")
      end
    end


So far so good, but we also need to remove the callback `before_save :encrypt_confirmation_code, :if => :registered?`
and we need also to transfer this logic:


{: lang="ruby" }
    # app/models/user_observer.rb

    class UserObserver < ActiveRecord::Observer
    ...
      def before_save(user)
        if user.new_record?
          encrypt_confirmation_code(user)
          JobVacancy.deliver(:registration, :registration_email, user.name, user.email)
        end
      end
    ...
    end


If we have a fresh registered user we create an confirmation code and send him an welcome mail. Hmm, but what about the
confirmation of our user? Right, we need to add an `after_save` method which send the confirmation code to the user:


{: lang="ruby" }
    # app/models/user_observer.rb
    ...

    def after_save(user)
      JobVacancy.deliver(:confirmation, :confirmation_email, user.name,
                         user.email,
                         user.id,
                         user.confirmation_code) unless user.confirmation
    end


We have cleaned up our design to this time. Before that if a user update his profile a new confirmation code will be
send. We fixed this is with the `unless user.confirmation` line which means as long as the user is not confirmed, send
him the confirmation code. We haven't any test for this kind and if you are curious how to do it, feel free to write
a test for this and modify the observer code. I haven't found a way to test this -  maybe you use the
[mock_model](https://www.relishapp.com/rspec/rspec-rails/v/2-4/docs/mocks/mock-model) for your tests!
We cleaned up our users controller from sending mail and this is the best solution, because in it's heart a controller
just talks to the model and passing the ball to the right direction after an event.


The last step we need to do is to register our observer in the `app.rb` and disable the observer for our specs


{: lang="ruby" }
    # app/app.rb.
    module JobVacancy
      class App < Padrino::Application
        ...
        # Activating the user_observer
        ActiveRecord::Base.add_observer UserObserver.instance
        ...
      end
    end

    # spec/spec_helper.rb

    RSpec.configure do |conf|
      ...
      ActiveRecord::Base.observers.disable :all # <-- Turn 'em all off!
      ...
    end


If you want to have an observer test[^test], you can use  the following one:


{: lang="ruby" }
    # spec/app/models/user_observer_spec.rb
    require 'spec_helper'

    describe "UserObserver" do
      let(:user) { build(:user)}
      before do
        @observer = UserObserver.instance
        @model = User
      end

      it 'creates Mail::Message object before save' do
        @observer.before_save(user).should be_instance_of(Mail::Message)
      end

      it 'do not create Mail::Message if user already exist' do
        @observer.before_save(@model.first).should be_nil
      end

      it 'creates Mail::Message object after save' do
        @observer.after_save(user).should be_instance_of(Mail::Message)
      end

    end


But during writing this book I became different testing results when using `bundle exec rake spec` and `bundle exec rspec spec`
and to go on with the book, I removed the test and disabled all observers for the application.

[^test]: Got the inspiration from [stackoverflow](http://stackoverflow.com/questions/33048/how-would-you-test-observers-with-rspec-in-a-ruby-on-rails-application)


### Sessions

Now that our users have the possibility to register and confirm on our page, we need to make it possible for our users
to sign in. For handling login, we need to create a session controller:


{: lang="bash" }
    $ padrino g controller Sessions new create destroy
      create  app/controllers/sessions.rb
      create  app/helpers/sessions_helper.rb
      create  app/views/sessions
       apply  tests/rspec
      create  spec/app/controllers/sessions_controller_spec.rb


We made a mistake during the generation - we forget to add the right action for our request. Before making the mistake
to delete the generated files by hand with a couple of `rm's`, you can run a generator to destroy a controller:


{: lang="bash" }
    $ padrino g controller Sessions -d
      remove  app/controllers/sessions.rb
      remove  app/helpers/sessions_helper.rb
      remove  app/views/sessions
       apply  tests/rspec
      remove  spec/app/controllers/sessions_controller_spec.rb


And run the generate command with the correct actions:


{: lang="bash" }
    $ padrino g controller Sessions get:new post:create delete:destroy
      create  app/controllers/sessions.rb
      create  app/helpers/sessions_helper.rb
      create  app/views/sessions
       apply  tests/rspec
      create  spec/app/controllers/sessions_controller_spec.rb


Our session controller is naked:


{: lang="ruby" }
    # app/controllers/sessions_controller.rb

    JobVacancy:App.controllers :sessions do

      get :new, :map => "/login" do
      end

      post :create do
      end

      delete :destroy do
      end
    end


So far so good before going on to write our tests first before we start with the implementation:


{: lang="ruby" }
    # spec/app/controllers/sessions_controller_spec.rb
    require 'spec_helper'

    describe "SessionsController" do
      describe "GET :new" do
        it "load the login page" do
        end
      end

      describe "POST :create" do
        it "stay on page if user is not found"
        it "stay on login page if user is not confirmed"
        it "stay on login page if user has wrong email"
        it "stay on login page if user has wrong password"
        it "redirect if user is correct"
      end

      describe "GET :logout" do
        it "empty the current session"
        it "redirect to homepage if user is logging out"
      end
    end


I>## Test-First development
I>
I> Is a term from [Extreme Programming (XP)](http://en.wikipedia.org/wiki/Extreme_programming) and means that you first
I> write down your tests before writing any code to solve it. This forces you to really think about what you are
I> going to do. These tests prevent you from over engineering a problem because you has to make these tests green.


Here are now the tests for the `GET :new` and `POST :create` actions of our session controller:


{: lang="ruby" }
    # spec/app/controllers/sessions_controller_spec.rb

    require 'spec_helper'

    describe "SessionsController" do

      describe "GET :new" do
        it "load the login page" do
          get "/login"
          last_response.should be_ok
        end
      end

      describe "POST :create" do
        let(:user) { build(:user)}
        let(:params) { attributes_for(:user)}

        it "stay on page if user is not found" do
          User.should_receive(:find_by_email).and_return(false)
          post_create(user.attributes)
          last_response.should be_ok
        end

        it "stay on login page if user is not confirmed" do
          user.confirmation = false
          User.should_receive(:find_by_email).and_return(user)
          post_create(user.attributes)
          last_response.should be_ok
        end

        it "stay on login page if user has wrong email" do
          user.email = "fake@google.de"
          User.should_receive(:find_by_email).and_return(user)
          post_create(user.attributes)
          last_response.should be_ok
        end

        it "stay on login page if user has wrong password" do
          user.password = "test"
          User.should_receive(:find_by_email).and_return(user)
          post_create(user.attributes)
          last_response.should be_ok
        end

        it "redirect if user is correct" do
          user.confirmation = true
          User.should_receive(:find_by_email).and_return(user)
          post_create(user.attributes)
          last_response.should be_redirect
        end
      end

      private
      def post_create(params)
        post "sessions/create", params
      end

    end


We are using **mocking** to make test what we want with the `User.should_receive(:find_by_email).and_return(user)`
method. I was thinking at the first that mocking is something very difficult but it isn't Read it the method out loud
ten times and you can guess whats going on. If our `User` object gets call from it's class method `find_by_email` it
should return our user object. This method will simulate from calling an actual find method in our application - yeah
we are mocking the actual call and preventing our tests from hitting the database and making it faster. Actual call and
preventing our tests from hitting the database and making it faster.


Here is the code for our session controller to make the test green:


{: lang="ruby" }
    # app/controllers/session.rb

    JobVacancy::App.controllers :sessions do

      get :new, :map => "/login" do
        render 'new'
      end

      post :create do
        user = User.find_by_email(params[:email])

        if user && user.confirmation && user.password == params[:password]
          sign_in(user)
          redirect '/'
        else
          render 'new'
        end
      end

      get :destroy, :map => '/logout' do
      end

    end


When I started the tests I got some weird error messages of calling a method on a nil object and spend one hour till I
found the issue. Do you remember the `UserObserver`? Exactly, this tiny piece of code is also activated for our tests
and since we disable sending mails with the `set :delivery_method, :test` settings in `app.rb` I never received an
mails. The simple to this problem was to add an option to in the `spec_helper.rb` to disable the observer:


{: lang="ruby" }
    # spec/spec_helper.rb
    ...
    RSpec.configure do |conf|
      conf.before do
        User.observers.disable :all # <-- turn of user observers for testing reasons, yeah
      end
      ...
    end


Running our tests:


{: lang="bash" }
    $ rspec spec/app/controllers/sessions_controller_spec.rb

    SessionsController
      GET :new
        load the login page
      POST :create
        stay on page if user is not found
        stay on login page if user is not confirmed
        stay on login page if user has wrong email
        stay on login page if user has wrong password
        redirect if user is correct
      GET :logout
        empty the current session (PENDING: Not yet implemented)
        redirect to homepage if user is logging out (PENDING: Not yet implemented)

    Pending:
      SessionsController GET :logout empty the current session
        # Not yet implemented
        # ./spec/app/controllers/sessions_controller_spec.rb:52
      SessionsController GET :logout redirect to homepage if user is logging out
        # Not yet implemented
        # ./spec/app/controllers/sessions_controller_spec.rb:53

    Finished in 0.62495 seconds
    8 examples, 0 failures, 2 pending


Before going on with implementing the logout action we need to think what happened after we login. We have to find a
mechanism to enable the information of the logged in user in all our controllers and views. Of course, we will do it
with sessions. When we created the session controller there was the line `create  app/helpers/sessions_helper.rb` --
let's look into this file:


{: lang="ruby" }
    # app/helpers/sessions_helper.rb

    # Helper methods defined here can be accessed in any controller or view in the application

    JobVacancy::App.helpers do
      # def simple_helper_method
      #  ...
      # end
    end


Yeah, Padrino is so friendly to print the purpose of this new file and it basically says what we want to do. Let's
implement the main features:


{: lang="ruby" }
    # app/helpers/session_helper.rb

    JobVacancy::App.helpers do
      def current_user=(user)
        @current_user = user
      end

      def current_user
        @current_user ||= User.find_by_id(session[:current_user])
      end

      def sign_in(user)
        session[:current_user] = user.id
        self.current_user = user
      end

      def sign_out
        session.delete(:current_user)
      end

      def signed_in?
        !current_user.nil?
      end
    end


There's a lot of stuff going on in this helper:


- `current_user`: Uses the `||=` notation. If the left hand-side isn't initialized, initialize the left hand-side with
  the right hand-side.
- `sign_in(user)`: Uses the global [session](http://www.sinatrarb.com/faq.html#sessions) method use the user Id as login
  information
- `sign_out`: Purges the `:current_user` field from our session.
- `signed_in?`: We will use this small method within our whole application to display special actions which should only
  be available for authenticated users.


I>## Why Sessions and how does sign_out work?
I>
I> When you request an URL in your browser you are using the HTTP/HTTPS protocol. This protocol is stateless that means
I> that it doesn't save the state in which you are in your application. Web applications implement states with one of
I> the following mechanisms: hidden variables in forms when sending data, cookies, or query strings (e.g.
I> http://localhost:3000/login?user=test&password=test).
I>
I> We are going to use cookies to save if a user is logged in and saving the user-Id in our session cookies under the
I> `:current_user` key.
I>
I> What the delete method does is the following: It will look into the last request in your application inside the
I> session information hash and delete the `current_user` key. And the sentence in code
I> `browser.last_request.env['rack.session'].delete(:current_user)`. If you want to explore more of the internal of an
I> application I highly recommend you the [Pry](https://github.com/pry/pry). You can throw in at any part of your
I> application `binding.pry` and have full access to all variables.



Now we are in a position to write tests for our `:destroy` action:


{: lang="ruby" }
    # spec/app/controller/sessions_spec.rb

    require 'spec_helper'

    describe "SessionsController" do
      ...
      describe "GET :logout" do
        it "empty the current session" do
          get_logout
          session[:current_user].should == nil
          last_response.should be_redirect
        end

        it "redirect to homepage if user is logging out" do
          get_logout
          last_response.should be_redirect
        end
      end

      private
      ...

      def get_logout
          # first arguments are params (like the ones out of an form), the second are environments variables
        get '/logout', { :name => 'Hans', :password => 'Test123' }, 'rack.session' => { :current_user => 1 }
      end


We use the our own `session` method in our tests to have access to the last response of our `rack.session`.
What we need to achieve is to have access to
[Rack's SessionHash](http://rubydoc.info/github/rack/rack/master/Rack/Session/Abstract/SessionHash). The
definition of this method is part of our `spec_helper.rb` method:


{: lang="ruby" }
    # spec/spec_helper.rb

    ...
    # have access to the session variables
    def session
      last_request.env['rack.session']
    end


And finally the implementation of the code that it make our tests green:


{: lang="ruby" }
    # app/controllers/session.rb

    JobVacancy::App.controllers :sessions do
      get :destroy, :map => '/logout' do
        sign_out
        redirect '/'
      end
    end


What we forget due to this point is to make use of the `sign_in(user)` method. Of course we need use this during our
session `:create` action:


{: lang="ruby" }
    # app/controller/session.rb

    JobVacancy::App.controllers :sessions do
      ...
      post :create do
        ...
        if user && user.confirmation && user.password == params[:password]
          sign_in(user)
          redirect '/'
        else
          ...
        end
      end

    end


Where can we test now our logic? The main application layout of our application should have a "Login" and "Logout" link
according to the status of the user:

{: lang="ruby" }
    # app/views/application.rb

    <!DOCTYPE html>
    <html lang="en-US">
      <%= stylesheet_link_tag '../assets/application' %>
      <%= javascript_include_tag '../assets/application' %>
    </head>
    <body>
      <div class=="container">
        <div class="row">
            <nav id="navigation">
            ...
            <% if signed_in? %>
              <%= link_to 'Logout', url_for(:sessions, :destroy) %>
            <% else %>
            <div class="span2">
              <%= link_to 'Login', url_for(:sessions, :new) %>
            </div>
            <% end %>
            </nav>
          </div>
          ...
        </div>
      </div>
    </body>


With the change above we changed the default "Registration" entry in our header navigation to "Login". We will add the
link to the registration form now in the 'session/new' view:


{: lang="ruby" }
    # app/views/sessions/new.erb

    <h1>Login</h1>

    <% form_tag '/sessions/create' do %>

      <%= label_tag :email %>
      <%= text_field_tag :email %>

      <%= label_tag :password %>
      <%= password_field_tag :password %>
      <p>
      <%= submit_tag "Sign up", :class => "btn btn-primary" %>
      </p>
    <% end %>

    New on this platform? <%= link_to 'Register', url_for(:users, :new) %>


Here we are using the [form_tag](http://www.padrinorb.com/guides/application-helpers#form-helpers) instead of the
`form_for` tag because we don't want to render information about a certain model. We want to use the information of the
session form to find a user in our database. We can use the submitted inputs with `params[:email]` and
`params[:password]` in the `:create` action in our action controller. My basic idea is to pass a variable to the
rendering of method which says if we have an error or not and display the message accordingly. To handle this we are
using the `:locals` option to create customized params for your views:


{: lang="ruby" }
    # app/controllers/sessions.rb

    JobVacancy::App.controllers :sessions do

      get :new, :map => "/login" do
        render 'new', :locals => { :error => false }
      end

      post :create do
        user = User.find_by_email(params[:email])

        if user && user.confirmation && user.password == params[:password]
          sign_in(user)
          redirect '/'
        else
          render 'new', :locals => { :error => true }
        end
      end
      ...

    end


Now we can simply use the `error` variable in our view:


{: lang="ruby" }
    # app/views/sessions/new.erb

    <h1>Login</h1>

    <% form_tag '/sessions/create' do %>
      <% if error %>
        <div class="alert alert-error">
          <h4>Error</h4>
          Your Email and/or Password is wrong!
        </div>
      <% end %>
    ...
    <% end %>

    New on this platform? <%= link_to 'Register', url_for(:users, :new) %>


The last thing we want to is to give the user feedback about what the action he was recently doing. Like that it would
be nice to give feedback of the success of the logged and logged out action. We can do this with short flash messages
above our application which will fade away after a certain amount of time. To do this we can use Padrino's flash
mechanism is build on
[Rails flash message implementation](http://guides.rubyonrails.org/action_controller_overview.html#the-flash).


And here is the implementation of the code:


{: lang="erb" }
    # app/views/application.erb

    <!DOCTYPE html>
    <html lang="en-US">
    <head>
      <title>Job Vacancy - find the best jobs</title>
      <%= stylesheet_link_tag '../assets/application' %>
      <%= javascript_include_tag '../assets/application' %>
    </head>
    <body>
      <div class="container">
        <% if flash[:notice] %>
          <div class="row" id="flash">
            <div class="span9 offset3 alert alert-success">
              <%= flash[:notice] %></p>
            </div>
          </div>
        <% end %>
      </div>
    </body>


Next we need implement the flash messages in our session controller:


{: lang="ruby" }
    # app/controllers/sessions.rb

    JobVacancy::App.controllers :sessions do
      ...
      post :create do
        user = User.find_by_email(params[:email])

        if user && user.confirmation && user.password == params[:password]
          flash[:notice] = "You have successfully logged out."
          sign_in(user)
          redirect '/'
        else
          render 'new', :locals => { :error => true }
        end
      end
      ...
    end


If you now login successfully you will see the message but it will stay there forever. But we don't want to have this
message displayed the whole time, so we will use jQuery's [fadeOut method](http://api.jquery.com/fadeOut/) to get rid of
the message. Since we are first writing our own customized JavaScript, let's create the file with the following content:


{: lang="erb" }
    # app/views/application.erb

    <!DOCTYPE html>
    <html lang="en-US">
    <head>
      <title>Job Vacancy - find the best jobs</title>
      <%= stylesheet_link_tag '../assets/application' %>
      <%= javascript_include_tag '../assets/application' %>
    </head>
    <body>
      <div class=="container">
        <% if flash[:notice] %>
          <div class="row" id="flash">
            <div class="span9 offset3 alert alert-success">
              <%= flash[:notice] %></p>
            </div>
            <script type="text/javascript">
              $(function(){
                  $("#flash").fadeOut(2000);
              });
            </script>
          </div>
        <% end %>
      </div>
    </body>


Feel free to add the `flash[:notice]` function when the user has registered and confirmed successfully on our platform.
If you have problems you can check
[my commit](https://github.com/matthias-guenther/job-vacancy/commit/f7233bf2edc7da89f02adf7f030a090fc74b3f2d).
