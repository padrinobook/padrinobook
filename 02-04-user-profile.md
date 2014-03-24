## User Profile

To update a user profile we need the `edit` and `update` action. Let's beginning with writing tests for the `edit`
section:


{: lang="ruby" }
    # spec/app/controller/users_controller_spec.rb
    ...
    describe "GET edit" do
      let(:user) { build(:user) }

      it "redirects if wrong id" do
        get "/users/-1/edit"
        last_response.should be_redirect
      end

      it "render the view for editing a user" do
        User.should_receive(:find_by_id).twice.and_return(user)
        get "/users/#{user.id}/edit"
        last_response.should be_ok
      end
    end


The interesting part above is the `.twice` call. We need to use this because when want to edit a user we need to load this profile and load it again if we are having an input error.


As you can see in the test above we are using namespaced routes an alias for the action.


{: lang="ruby" }
    # app/controllers/user.rb

    # using namespaced route alias
    get :edit, :map => '/users/:id/edit' do
      @user = User.find_by_id(params[:id])
      unless @user
        redirect('/')
      end
      render 'edit'
    end


And the tests for the put action:


{: lang="ruby" }
    # spec/app/controller/users_controller_spec.rb
    ...

    describe "PUT update" do
      let(:user) { build(:user) }

      it "redirects and update attributes" do
        name_before = user.name
        id = user.id
        user.save
        put "users/#{user.id}", :user => user_params
        last_response.should be_redirect
        user = User.find(id)
        user.name.should_not be_eql(name_before)
      end

      it "stays on the page if the user has made input errors" do
        User.should_receive(:find_by_id).and_return(user)
        put "users/#{user_params["id"]}", :user => user_params.merge({"name" => ''})
        last_response.should be_ok
      end
    end

    private
    def user_params
      user.attributes.merge({"name" => "Octocat", "created_at" => Time.now, "updated_at" => Time.now})
    end


Making this test pass took me a while. The HTTP specification only understands GET and POST in the `<form>`' method attribute. How can we solve this? We need to use a hidden form with the form input called `_method` with a `put` value. You will see this right after the controller code.


{: lang="ruby" }
    # app/controllers/users.rb
    ...
    put :update, :map => '/users/:id' do
      @user = User.find_by_id(params[:id])

      unless @user
        flash[:error] = "User is not registered in our platform."
        render 'edit'
      end

      if @user.update_attributes(params[:user])
        flash[:notice] = "You have updated your profile."
        redirect('/')
      else
        flash[:error] = "Your profile was not updated."
        render 'edit'
      end
    end


Please note that The `update_attributes` method is making a `user.valid?` call before saving. During writing the tests I
had huge problems with them and the fixtures. It might occur that they are failing for you too. If this is the case
don't spend too much time on it and mark the tests as pending.


And finally the edit form:


{: lang="erb" }
    # app/views/users/edit.erb

    <% form_for(@user, "/users/#{@user.id}") do |f| %>
      <h2>Edit your profile</h2>

      <input name="_method" type="hidden" value="put" />
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
      <%= f.submit "Save changes", class: "btn btn-large btn-primary" %>
      </p>
    <% end %>


If you now open the browser at http://jobvacancy.de:3000/users/<some-existing-id>/edit you can edit the user even if you
are not logged into the application. Ups, this is huge security issue.


### Authorization

We want our user to be logged in and edit only his profile. In the previous parts of the book we wrote a lot of
functions for our `sessions_helper.rb` without any tests. Before going on, let's how you can test helpers:


{: lang="ruby" }
    # app/helpers/page_helper.rb

    # Helper methods defined here can be accessed in any controller or view in the application

    JobVacancy::App.helpers do
      # def simple_helper_method
      #  ...
      # end
    end


This syntax is a shortcut for:


{: lang="ruby" }
    helpers = Module.new do
      # def simple_helper_method
      #  ...
      # end
    end

    JobVacancy::App.helpers helpers


The helpers are an anonymous module and its hard to reference something that is anonymous. The solution is easy: make
the module explicit. This is something I learned from [Florian Gilcher](https://twitter.com/Argorak) in his
[comment on GitHub](https://github.com/padrino/padrino-framework/issues/930#issuecomment-8448579). Let's transform the
`page_helper.rb`:


{: lang="ruby" }
    # app/helpers/page_helper.rb

    module PageHelper
      # def simple_helper_method
      #  ...
      # end
    end

    JobVacancy::App.helpers UsersHelper


Now you can include this module in some of your spec and finally test them. Let's apply the learned lesson to our
`sessions_helper.rb`:


{: lang="ruby" }
    # app/helpers/session_helper.rb

    module SessionsHelper
      def current_user=(user)
        @current_user = user
      end
      ...
    end

    JobVacancy::App.helpers SessionsHelper


Padrino isn't requiring helper to be tested automatically. Since we are planing to be consistence with the folder
structure of our app within the tests folder, we need to add all helpers files in `app/helpers/*.rb` in our
`spec_helper.rb`:


{: lang="ruby" }
    # spec/spec_helper.rb

    PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
    ...
    Dir[File.dirname(__FILE__) + '/../app/helpers/**.rb'].each { |file| require file }
    ...


Here is the outline of the `sessions_helper_spec.rb`:


{: lang="ruby" }
    # spec/app/helpers/sessions_helper_spec.rb

    require 'spec_helper'

    describe SessionsHelper do
      before do
        class SessionsHelperKlass
          include SessionsHelper
        end

        @session_helper = SessionsHelperKlass.new
      end

      context "#current_user" do
        it "output the current user if current user is already set"
        it "find the user by id from the current session"
      end

      context "#current_user?" do
        it "returns true if current user is logged in"
        it "returns false if user is not logged in"
      end

      context "#sign_in" do
        it "it sets the current user to the signed in user"
      end

      context "#signed_in?" do
        it "return false if user is not logged in"
        it "return true if user is logged in"
      end
    end


Let's go through the new parts:


- `before do`: This block contains the `SessionsHelperKlass` class which includes the `SessionsHelper` module. Through
  this all the methods defined in the `session_helper.rb` file are available for the `@session_helper` instance variable
- `context`: According to [rspec code](https://github.com/rspec/rspec-core/blob/master/lib/rspec/core/example_group.rb#L232)
  `context` is an alias for `describe`. I'm using `describe` to specify the part of the functionality I'm going to test
  and `context` to test smaller parts of the bigger function.
- `#current_user`: Methods I'm going to test have always the # in front of their names.


I'm not testing the a) `current_user=(user)` and b) `sign_out` method because a) is a setter method and b) is deleting a
key in the session hash.


The most interesting part of the test is the  *"find the user by id from the current session"*. Padrino has access
to the session of your variable. We emulate this access in our tests with the `session` method of our `spec_helper.rb`
which looks like the following:


{: lang="ruby" }
    # spec/spec_helper.rb

    def session
      last_request.env['rack.session']
    end


What we need to do now for our test is to to mock a request and set the user id of some of our test user in the
session hash. To create a new session we will use
[Rack::Test::Session](https://github.com/brynary/rack-test/blob/master/lib/rack/test.rb#L25) and mock the `last_request`
method call of the `session` method of our `spec_helper`:


{: lang="ruby" }
    # spec/app/helpers/sessions_helper_spec.rb
    require 'spec_helper'

    describe SessionsHelper do
      ...
      context "#current_user" do

        it "find the user by id from the current session" do
          user = User.first
          browser = Rack::Test::Session.new(JobVacancy::App)
          browser.get '/', {}, 'rack.session' => { :current_user => user.id }
          @session_helper.should_receive(:last_request).and_return(browser.last_request)
          @session_helper.current_user.should == user
        end
      end
      ...
    end


You can write the other tests as an exercise on your own. In case you have problems with writing them, please check the
[spec on GitHub](https://github.com/matthias-guenther/job-vacancy/blob/user-update/spec/app/helpers/sessions_helper_spec.rb).


We will limit the access of the `edit` and `update` action of the users controller only to users who are logged and if the logged in user is going to edit With the help of a `before .. do` block:


{: lang="ruby" }
    # app/controllers/users.rb

    JobVacancy::App.controllers :users do
      before :edit, :update  do
        redirect('/login') unless signed_in?
        @user = User.find(params[:id])
        redirect('/login') unless current_user?(@user)
      end
    ...
    end


Since we are now having our authorization logic in the before block we don't need the unless test in the edit action
anymore:


{: lang="ruby" }
    # app/controllers/users.rb

    JobVacancy::App.controllers :users do
      ...
      get :edit, :map => '/users/:id/edit' do
        @user = User.find_by_id(params[:id])
        render 'edit'
      end
      ...
    end


Finally, we need to provider the edit link in the header navigation:


{: lang="erb" }
    # app/views/application.erb

    <nav id="navigation">
      ...
      <% if signed_in? %>
        <div class="span2">
          <%= link_to 'Logout', url_for(:sessions, :destroy) %>
        </div>
        <div class="span2">
          <%= link_to 'Edit Profile', url_for(:users, :edit, :id => session[:current_user]) %>
        </div>
      <% else %>
        <div class="span3">
          <%= link_to 'Login', url_for(:sessions, :new) %>
        </div>
      <% end %>
      ...
      </div>
    </nav>


There is one last thing we forget: Say you are logged in and wants to edit a user with a wrong id, like
http://localhost:3000/users/padrino/edit. You'll get a `ActiveRecord::RecordNotFound` exception because we are using
the Active Record's plain `find` method in the users controller. Let's catch the exception and return a `nil` user
instead:


{: lang="ruby" }
    # app/controllers/user.rb

    JobVacancy::App.controllers :users do
      before :edit, :update  do
        redirect('/login') unless signed_in?
        begin
          @user = User.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          @user = nil
        end

        redirect('/login') unless current_user?(@user)
      end
      ...
    end


Do we really need to throw an exception? No there is a better way to handle this issue. The `find_by_*` method will always return `nil` if an entry was not found. So we can refactor the code above in the following way:


{: lang="ruby" }
    # app/controllers/user.rb

    JobVacancy::App.controllers :users do
      before :edit, :update  do
        redirect('/login') unless signed_in?
        @user = User.find_by_id(params[:id])
        redirect('/login') unless current_user?(@user)
      end
      ...
    end


You have now reach a point where you still don't know, which parts of your application is tested and which not. This is
a good point to find the right tool to measure the code coverage of your Padrino application.


### Excursion: Code Coverage

We have the following options:


- [simplecov](https://github.com/colszowka/simplecov): It will automatically detect the tests you are using Rubies 1.9's [built-in Coverage library](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/coverage/rdoc/Coverage.html) to gather code coverage data.
- [metric_fu](https://github.com/metricfu/metric_fu/): Create churn, code smells and other coverage tools generate
  reports about your code.
- [codeclimate.com](https://codeclimate.com/): Online tool for measuring quality and security for your application.


Since we are only interested in our code coverage for tests, we will use the lightweight `simplecov` method.


Add the gem to your `Gemfile`:

{% highlight ruby %}

gem 'simplecov', '~> 0.7.1'

{% endhighlight %}


Next, we want to start the code coverage generation every time when the tests are going to run. All you have to do is to add the following line to
the `spec_helper.rb`:


{% highlight ruby %}

require 'simplecov'
SimpleCov.start

{% endhighlight %}


And that's all. Next time when you run the tests you can detect lines with the following output:


{% highlight bash %}

Coverage report generated for RSpec to git-repositories/job-vacancy/coverage. 209 / 252 LOC (82.94%) covered.
/

{% endhighlight %}


After all tests passed, you can see the output in the `coverage` directory in the root of your directory:


IMG: simplecov_overview.png


Clicking on a single class will give you a brief overview which lines are not tested:


IMG: simplecov_detailed_view.png


It is also possible to group the parts of your application into several parts. All you need to do is to add options to
the `Simplecov.start` block:


{% highlight ruby %}

SimpleCov.start do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
end

{% endhighlight %}

IMG: simplecov_grouped.png


## Remember Me Function

We are currently using the `sign_in` method from the session helper to login a user. But this is only valid for a
session. What we need is something permanent. Cookies are the perfect choice for this. We could use the `user_id` from
the user as a unique token, but this can be changed too easily. Creating an unique long secure hash would be the
perfect choice to do so. When we have created token, we need to save it for each user.


Let's create and run the migration:


{: lang="bash" }
  $ padrino g migration add_authentity_token_to_user authentity_token:string
       apply  orms/activerecord
      create  db/migrate/006_add_authentity_token_to_user.rb

  $ padrino rake ar:migrate
  => Executing Rake ar:migrate ...
  Environment variable PADRINO_ENV is deprecated. Please, use RACK_ENV.
    DEBUG -   (0.1ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"
     INFO -  Migrating to CreateUsers (1)
     INFO -  Migrating to CreateJobOffers (2)
     INFO -  Migrating to AddUserIdToJobOffers (3)
     INFO -  Migrating to AddRegistrationFieldsToUsers (4)
     INFO -  Migrating to AddConfirmationCodeAndConfirmationToUsers (5)
     INFO -  Migrating to AddAuthentityTokenFieldToUsers (6)
    DEBUG -   (0.0ms)  select sqlite_version(*)
    DEBUG -   (0.0ms)  begin transaction
  ==  AddAuthentityTokenFieldToUsers: migrating =================================
  -- change_table(:users)
    DEBUG -   (0.3ms)  ALTER TABLE "users" ADD "authentity_token" varchar(255)
     -> 0.0050s
  ==  AddAuthentityTokenFieldToUsers: migrated (0.0051s) ========================

    DEBUG -   (0.1ms)  INSERT INTO "schema_migrations" ("version") VALUES ('7')
    DEBUG -   (10.0ms)  commit transaction
    DEBUG -   (0.1ms)  SELECT "schema_migrations"."version" FROM "schema_migrations"


A way to create random strings in Ruby is to use the [securerandom gem](http://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html). By using the `before_create` callback, we create a token for each fresh registered user (if you are in a situation where you already have a bunch of users, you have to create a rake task and generate the tokens for each user):


{: lang="ruby" }
  class User < ActiveRecord::Base
    ...
    before_create :generate_authentity_token

    private
    def generate_authentity_token
      require 'securerandom'
      self.authentity_token = SecureRandom.base64(64)
      SecureRandom
    end
  end


To test the callback, we can use the `send` method to send our `generate_authentity_token` callback (thanks to [Geoffrey Grosenbach](http://www.oreillynet.com/ruby/blog/2006/10/test_tidbits.html)):


{: lang="ruby" }

    require 'spec_helper'

    describe "User Model" do
      ...

      describe "generate_auth_token" do
        let(:user_confirmation) { build(:user) }

        it 'generate_auth_token generate token if user is saved' do
          user.should_receive(:save).and_return(true)
          user.send(:generate_authentity_token)
          user.save
          user.authentity_token.should_not be_empty
        end
      end
    end


INFOBOX about cookies


- View/Checkbox
- Set a cookie in
- generate tooken
- explain set_cookie function
- add screenshot about the cookie in firefox




## Reset Password

