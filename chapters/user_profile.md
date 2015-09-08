## User Profile

To update a user profile we need the `edit` and `update` action. Let's beginning with writing tests for the `edit` action:


```ruby
# spec/app/controller/users_controller_spec.rb

...

describe "GET /users/:id/edit" do
  let(:user) { build(:user) }
  let(:user_second) { build(:user) }

  it "redirects if user is not signed in" do
    get "/users/-1/edit", {}, { 'rack.session' => { current_user: nil}}
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/login')
  end

  it "redirects if user is signed in and tries to call a different user" do
    expect(User).to receive(:find_by_id).and_return(user, user_second)
    get "/users/2/edit"
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/login')
  end

  it "render the view for editing a user" do
    expect(User).to receive(:find_by_id).and_return(user, user, user)
    get "/users/#{user.id}/edit", {}, { 'rack.session' => { current_user: user } }
    expect(last_response).to be_ok
    expect(last_response.body).to include('Edit your profile')
  end
end
```


The fist interesting part above is the `and_return(user, user_second)` call. This is the way to return different return
values when a method is called several times - the number of arguments is the number of the functions call. The second
thing is that we check the `last_response.header` and `last_response.body`. A typical
[Rack::MockResponse](http://www.rubydoc.info/github/rack/rack/Rack/MockResponse "Rack::MockResponse") looks like the
following:


```ruby
=> #<Rack::MockResponse:0xabd6f00
 @block=nil,
 @body=[],
 @body_string=nil,
 @chunked=false,
 @errors="",
 @header=
  {"Content-Type"=>"text/html;charset=utf-8",
   "Location"=>"http://example.org/login",
   "Content-Length"=>"0",
   "X-XSS-Protection"=>"1; mode=block",
   "X-Content-Type-Options"=>"nosniff",
   "X-Frame-Options"=>"SAMEORIGIN",
   "Set-Cookie"=>
    "rack.session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRTk3ZjI...; path=/; HttpOnly"},
 @length=0,
 @original_headers=
  {"Content-Type"=>"text/html;charset=utf-8",
   "Location"=>"http://example.org/login",
   "Content-Length"=>"0",
   "X-XSS-Protection"=>"1; mode=block",
   "X-Content-Type-Options"=>"nosniff",
   "X-Frame-Options"=>"SAMEORIGIN",
   "Set-Cookie"=>
    "rack.session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRTk3ZjI...; path=/; HttpOnly"},
 @status=302,
 @writer=
  #<Proc:0xabd6d0c@/home/wm/.rvm/gems/ruby-2.2.1/
  # gems/rack-1.5.5/lib/rack/response.rb:27 (lambda)>>
```


Let's look at the implementation:


```ruby
# app/controllers/users.rb

JobVacancy::App.controllers :users do
  before :edit, :update  do
    redirect('/login') unless signed_in?
    @user = User.find_by_id(params[:id])
    redirect('/login') unless current_user?(@user)
  end
  ...

  get :edit, :map => '/users/:id/edit' do
    @user = User.find_by_id(params[:id])
    render 'edit'
  end
end
```


We don't want that everybody can edit the profile for other users. Before we are going to call these actions we set a
[before route filter](http://www.padrinorb.com/guides/controllers#route-filters "before route filter"). They are
evaluated before each requests within the context of the requests and it is possible to define variables, change the
response and request. For the `get :edit` action we are using [namespaced route aliases](http://www.padrinorb.com/guides/controllers#namespaced-route-aliases "namespaced route aliases"). They have the advantage that you can refer to them with the `url_for` method - you can always reference to them and don't have change the actual string for the method.


Let's write the tests for the `update` action:


```ruby
# spec/app/controllers/users_controller_spec.rb

...
describe "PUT /users/:id" do
  let(:user) { build(:user) }
  let(:user_second) { build(:user) }

  it "redirects if user is not signed in", :current do
    put "/users/1", {}, { 'rack.session' => { current_user: nil}}
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/login')
  end

  it "redirects if user is signed in and tries to call a different user" do
    expect(User).to receive(:find_by_id).and_return(user, user_second)
    put "/users/1"
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/login')
  end

  it "redirects to /edit if user has valid account changes" do
    expect(User).to receive(:find_by_id).and_return(user, user, user)
    put "/users/1"
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/edit')
  end

  it "redirects to /edit if user has valid account changes" do
    expect(User).to receive(:find_by_id).and_return(user, user, user)
    put "/users/1"
    expect(last_response).to be_redirect
    expect(last_response.body).to eq 'You have updated your profile.'
    expect(last_response.header['Location']).to include('/edit')
  end

  it "redirects to /edit if user has not valid account changes" do
    user.password = 'real'
    user.password_confirmation = 'fake'
    expect(User).to receive(:find_by_id).and_return(user, user, user)
    put "/users/1"
    expect(last_response).to be_redirect
    expect(last_response.body).to eq 'Your profile was not updated.'
    expect(last_response.header['Location']).to include('/edit')
  end
end
...
```


And the implementation:


```ruby
# app/controllers/users.rb

put :update, :map => '/users/:id' do
  @user = User.find_by_id(params[:id])

  route = url(:users, :edit, :id => @user.id)
  if @user.update_attributes(params[:user])
    redirect route, flash[:notice] = "You have updated your profile."
  else
    redirect route, flash[:error] = "Your profile was not updated."
  end
end
```


Please note that the [update_attributes](http://www.rubydoc.info/docs/rails/2.3.8/ActiveRecord/Base:update_attributes "update_attributes") method is making a [valid?](http://www.rubydoc.info/docs/rails/2.3.8/ActiveResource%2FValidations%3Avalid%3F "valid?") method before the changes are saved.


Making this test pass took me a while. The HTTP specification only understands `GET` and `POST` in the `<form>` method attribute. How can we solve this? We need to use a hidden form with the `put` method:


```erb
<%# app/views/users/edit.erb %>

<h2>Edit your profile</h2>

<% form_for @user, url(:users, :update, :id => @user.id), method: :put do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
  <%= error_message_on @user, :name, :class => "text-error",
    :prepend => "The name " %>

  <%= f.label :email %>
  <%= f.text_field :email %>
  <%= error_message_on @user, :email, :class => "text-error",
    :prepend => "The email " %>

  <%= f.label :password %>
  <%= f.password_field :password %>
  <%= error_message_on @user, :password, :class => "text-error",
    :prepend => "The password "%>

  <%= f.label :password_confirmation %>
  <%= f.password_field :password_confirmation %>
  <%= error_message_on @user, :password_confirmation, :class => "text-error" %>

  <p>
    <%= f.submit "Save changes", class: "btn btn-large btn-primary" %>
  </p>
<% end %>
```


You can specify the [HTTP methods](http://www.w3schools.com/tags/ref_httpmethods.asp "HTTP methods") with `method: <action>`. So `method: :put` will be translated into:


```html
<input type="hidden" value="put" name="_method"</input>
```


### Authorization

The controller actions are ready and we used many method from the `session_helper.rb`. Before we add now the action for
signup and registration to the view, it's time to test the helper. A normal helper does look like the following:


```ruby
# app/helpers/page_helper.rb

JobVacancy::App.helpers do
end
```


This syntax is a shortcut for:


```ruby
helpers = Module.new do
end

JobVacancy::App.helpers helpers
```


The helpers are an anonymous module and its hard to reference something that is anonymous. The solution is to make the module explicit. This is something I learned from [Florian](https://twitter.com/Argorak "Florian Gilcher") in his [comment on GitHub](https://github.com/padrino/padrino-framework/issues/930#issuecomment-8448579 "comment on GitHub"). Let's transform the `spec_helper.rb` into this new form:


```ruby
# app/helpers/sessions_helper.rb

module SessionsHelper
  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:current_user])
  end

  def current_user?(user)
    user == current_user
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

JobVacancy::App.helpers SessionsHelper
```


Padrino isn't requiring helper to be tested automatically. Since we are planing to be consistence with the folder structure of our app within the tests folder, we need to add all helpers files in `app/helpers/*.rb`. Let's made all helper files availabe in our specs:


```ruby
# spec/spec_helper.rb

RACK_ENV = 'test' unless defined?(RACK_ENV)
...
Dir[File.dirname(__FILE__) + '/../app/helpers/**.rb'].each { |file| require file }
...
```


Here is the outline of the tests:


```ruby
# spec/app/helpers/sessions_helper_spec.rb

require 'spec_helper'

describe SessionsHelper do
  before do
    class SessionsHelperKlass
      include SessionsHelper
    end

    @session_helper = SessionsHelperKlass.new
  end

  describe "#current_user" do
    xit "returns the current user if user is set"
    xit "returns the current user from session"
  end

  describe "#current_user?" do
    xit "returns true if current user is logged in"
    xit "returns false if user is not logged in"
  end

  describe "#sign_in" do
    xit "sets the current user to the signed in user"
  end

  describe "#sign_out" do
    xit "clears the current_user from the session"
  end

  describe "#signed_in?" do
    xit "returns false if user is not logged in"
    xit "returns true if user is logged in"
  end
end
```


The `before do` block contains the `SessionsHelperKlass` class which includes the `SessionsHelper` So the instance variable `@session_helper` can use any methods defined in `session_helper.rb` and the descibe blocks now contains the names of the method which is tested. I'm not testing the `current_user=(user)` because it is a setter method.


What we need to do now for our test is to to mock a request and set the user id of some of our test user in the session hash. To create a new session we will use [Rack::Test::Session](https://github.com/brynary/rack-test/blob/master/lib/rack/test.rb "Rack::Test::Session") and mock the `last_request` method call:


```ruby
# spec/app/helpers/sessions_helper_spec.rb

require 'spec_helper'

describe SessionsHelper do
  ...
  describe "#current_user" do
    it "returns the current user if user is set" do
      user = User.new
      @session_helper.current_user = user
      expect(User).to receive(:find_by_id).never
      expect(@session_helper.current_user).to eq user
    end

    it "returns the current user from session" do
      user = User.first
      browser = Rack::Test::Session.new(JobVacancy::App)
      browser.get '/', {}, 'rack.session' => { :current_user => user.id }
      expect(User).to receive(:find_by_id).and_return(user)
      expect(@session_helper).to receive(:session).and_return(user)
      expect(@session_helper.current_user).to eq user
    end
  end
  ...
end
```


Instead of writing `JobVacancy::App` you can also pass `app` in the line `Rack::Test::Session.new(JobVacancy::App)`. The
`app` is defined in the `spec_helper`:


```ruby
# spec/spec_helper.rb
...

# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app JobVacancy::App
#   app JobVacancy::App.tap { |a| }
#   app(JobVacancy::App) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
```


You can write the other tests as an exercise on your own. In case you have problems with writing them, please check the [spec on GitHub](https://github.com/wikimatze/job-vacancy/blob/master/spec/app/controllers/sessions_controller_spec.rb "spec on GitHub").


Finally, we need to provider the edit link in the header navigation:


```erb
# app/views/application.erb

<nav id="navigation">
  ...
  <% if signed_in? %>
    <div class="span2">
      <%= link_to 'Logout', url(:sessions, :destroy) %>
    </div>
    <div class="span2">
      <%= link_to 'Edit Profile', url(:users, :edit,
        :id => session[:current_user]) %>
      <%= link_to 'Edit Profile', url(:users, :edit, :id => session[:current_user]) %>
    </div>
  <% else %>
    <div class="span3">
      <%= link_to 'Login', url(:sessions, :new) %>
    </div>
  <% end %>
  ...
</nav>
```


### Remember Me Function
\label{sec:remember_me_funcion}

We are currently using the `sign_in` method from the session helper to login a user. But this is only valid for a session. What we need is something permanent.
[Cookies](https://en.wikipedia.org/wiki/HTTP_cookie "Cookies") are the perfect choice for this. We could use the `user_id` from the user as a unique token,
but this can be changed too easily. Creating an unique long [secure hash](http://en.wikipedia.org/wiki/Secure_Hash_Algorithm "secure hash") is more secure.


Let's create and run the migration for the authentity token:


```sh
$ padrino-gen migration AddAuthentityTokenToUsers authentity_token:string
     apply  orms/activerecord
    create  db/migrate/006_add_authentity_token_to_users.rb
$ padrino rake ar:migrate
=> Executing Rake ar:migrate ...
  DEBUG -   (0.1ms)  SELECT "schema_migrations"."version"
    FROM "schema_migrations" ...
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
  DEBUG -   (0.1ms)  SELECT "schema_migrations"."version"
    FROM "schema_migrations"
```


\begin{aside}
\heading{Cookies}

HTTP is a [stateless protocol](http://en.wikipedia.org/wiki/Stateless_protocol "stateless protocol") and a cookie is a
way to save information sent from a website and store them in the browser. Each time the user visits the site again, the
browser sends the information back to server and notifies the server about the identity of the user. A cookies can
consists of the following components: name, value, expiry date, path (scope of the cookie), domain (valid for which
domain), needs the cookie be used for a secure connection or if (or not) the cookie can be accessed by other.ways (like
JavaScript to steal the cookie).
\end{aside}


A way to create random strings in Ruby is to use the [SecureRandom class](http://ruby-doc.org/stdlib-2.2.3/libdoc/securerandom/rdoc/SecureRandom.html "securerandom class").
By using the [before_create callback](http://www.rubydoc.info/docs/rails/ActiveRecord/Callbacks "before_create callback"),
we create a token for each registered user[^registered_user_note].


[^registered_user_note]: If you are in a situation where you already have a bunch of users and you now decide to create hashs for them, you have to create a migration script and migrate the existing user base.


```ruby
# models/user.rb

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
```


To test the private callback, we can use the [send method](http://ruby-doc.org/core-2.2.3/Object.html#method-i-send "send method") to create our `generate_authentity_token` callback:


```ruby
# spec/models/user_spec.rb

require 'spec_helper'


RSpec.describe "User Model" do
  ...
  describe "#generate_authentity_token" do
    let(:user_confirmation) { build(:user) }

    it 'generates the authentity_token before user is saved' do
      expect(user).to receive(:save).and_return(true)
      user.send(:generate_authentity_token)
      user.save
      expect(user.authentity_token).not_to be_empty
    end
  end
end
```


Next it's time to create the checkbox on the login page with help of the
[check_box_tag](http://www.padrinorb.com/api/Padrino/Helpers/FormHelpers.html#check_box_tag-instance_method "check_box_tag"):


```erb
<%# views/sessions/new.erb %>

<h1>Login</h1>

  ...
  <label class="checkbox">
    <%= check_box_tag :remember_me, :val %> Remember me
  </label>
```


If the user click on the *Remember me* checkbox, it's time for our session controller to create a cookie:


```ruby
# app/controllers/sessions.rb
JobVacancy::App.controllers :sessions do
  ...


  post :create do
    @user = User.find_by_email(params[:email])

    if @user && @user.confirmation && @user.password == params[:password]
      if (params[:remember_me] == "true")
        require 'securerandom'
        token = SecureRandom.hex
        @user.authentity_token = token
        thirty_days_in_seconds = 30*24*60*60
        response.set_cookie('permanent_cookie',
                            :value => { :domain => 'jobvacancy.de',
                                        :path => '/'} ,
                                        :max_age => "#{thirty_days_in_seconds}")
        @user.save
      end

      flash[:notice] = "You have successfully logged in!"
      sign_in(@user)
      redirect '/'
    else
      render 'new', :locals => { :error => true }
    end
  end
  ...
end
```


First, we create a secure random hex value and assign to the `authentity_token` attribute of the user.  We then use the
[set_cookie](http://www.rubydoc.info/github/rack/rack/Rack/Response#set_cookie-instance_method "set_cook") method to
generate a cookie which is valid for thirty days.


When you login the next time into the application, click the remember me you checkboxw. Stop and start the application
again, you will be logged in automatically for the next thirty days.


![Figure 2-2. Start page of the app](images/cookies.png)


If you want to see the cookie in your browser, you can install [Web Developer extension](https://addons.mozilla.org/en-US/firefox/addon/web-developer "Web Developer extension") for [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new "Mozilla Firefox") and open the *View cookie information* pane in the *Cookies* tab. The specs for the `post :create` action:

```ruby
# spec/app/controllers/sessions_controller_spec.rb

describe "POST :create" do
  let(:user) { build(:user)}
  let(:params) { attributes_for(:user)}

  it "stays on login page if user is not found" do
    expect(User).to receive(:find_by_email) {false}
    post 'sessions/create'
    expect(last_response).to be_ok
  end

  it "stays on login page if user is not confirmed" do
    user.confirmation = false
    expect(User).to receive(:find_by_email) {user}
    post 'sessions/create'
    expect(last_response).to be_ok
  end

  it "stays on login page if user has wrong password" do
    user.confirmation = true
    user.password = 'correct'
    expect(User).to receive(:find_by_email) {user}
    post 'sessions/create', {:password => 'wrong'}
    expect(last_response).to be_ok
  end

  it "redirects to home for confirmed user and correct password" do
    user.confirmation = true
    user.password = 'correct'
    expect(User).to receive(:find_by_email) {user}
    post 'sessions/create', {:password => 'correct', :remember_me => false}
    expect(last_response).to be_redirect
  end

  it "redirects if user is correct and has remember_me" do
    token = 'real'
    user = double("User")
    expect(user).to receive(:id) {1}
    expect(user).to receive(:password) {'real'}
    expect(user).to receive(:confirmation) {true}
    expect(user).to receive(:authentity_token=) {token}
    expect(user).to receive(:save)
    expect(User).to receive(:find_by_email) {user}
    expect(SecureRandom).to receive(:hex).at_least(:once) {token}

    post 'sessions/create', {:password => 'real', :remember_me => true}
    expect(last_response).to be_redirect
    cookie = last_response['Set-Cookie']
    expect(cookie).to include('permanent_cookie')
    expect(cookie).to include('path=/')
    expect(cookie).to include('domain%3D%3E%22jobvacancy.de')
    expect(cookie).to include('max-age=2592000')
  end
end
```


### Reset Password

This chapter will be a combination of all the things we have learned so far. Until now you should be familiar with the commands of creating new controllers, edit views as well as create migration and new mail templates. Because repetition is good, we will go through the whole procedure again.


We are going to create a new controller for the password forget feature:


```sh
$ padrino-gen controller PasswordForget get:new post:create get:edit post:update
    create  app/controllers/password_forget.rb
    create  app/views/password_forget
     apply  tests/rspec
    create  spec/app/controllers/password_forget_controller_spec.rb
    create  app/helpers/password_forget_helper.rb
     apply  tests/rspec
    create  spec/app/helpers/password_forget_helper_spec.rb
```


We have to create a GET and POST route for the `` route:


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do

  get :new, :map => 'password_forget'  do
    render 'new'
  end

  post :create do
    # have to think about this ...
  end
end
```


Since the routes are now defined, we can add the *password forget* link on the login page:


```erb
# app/views/sessions/new.erb

...
<label class="checkbox">
  <%= check_box_tag :remember_me %> Remember me
</label>
<p>
  <%= link_to 'forget password?', url(:password_forget, :new) %>
</p>
...

```

In the `new` action’s view we’ll create a form to allow a user to enter their email address and request that their password is reset. The form looks like this:


```erb
<h2>Forgot Password</h2>


<% form_tag url(:password_forget, :create) do %>
  <%= label_tag :email %>
  <%= text_field_tag :email %>

  <p>
    <%= submit_tag "Reset password", :class => "btn btn-primary" %>
  </p>
<% end %>
```

Since the template isn't using a model, the `form_tag` is enough for this. The POST information from the forget password form needs to be processed: We will send the instructions how to reset the password by the supplied email address. If the typed in email address is wrong, we don't say if it is valid or not, we don't want to have malicious user to check if a user exists or not.


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  ...

  post :create do
    user = User.find_by_email(params[:email])

    if user
      user.save_forget_password_token
      link = "http://localhost:3000" + url(:password_forget, :edit,
        :token => user.password_reset_token)
      deliver(:password_forget, :password_forget_email, user.email, link)
    end

    render 'success'
  end
end
```


The `save_forget_password_token` will create the `password_reset_token` for the requested password reset. The token should only valid for around one hour, we need to save the `password_reset_sent_date`. Before going on we need to add token and the method in the User model, we need a way to generate a token for the password reset function for the user model:


```sh
$ padrino-gen migration AddPasswordResetTokenToUsers
  password_reset_token:string password_reset_sent_date:datetime
       apply  orms/activerecord
      create  db/migrate/007_add_password_reset_for_users.rb
$ padrino rake ar:migrate
=> Executing Rake ar:migrate ...
  DEBUG -   (0.1ms)  SELECT "schema_migrations"."version"
    FROM "schema_migrations"
   INFO -  Migrating to CreateUsers (1)
   INFO -  Migrating to CreateJobOffers (2)
   INFO -  Migrating to AddUserIdToJobOffers (3)
   INFO -  Migrating to AddRegistrationFieldsToUsers (4)
   INFO -  Migrating to AddConfirmationCodeAndConfirmationToUsers (5)
   INFO -  Migrating to AddAuthentityTokenFieldToUsers (6)
   INFO -  Migrating to AddPasswordResetTokenToUsers (7)
  DEBUG -   (0.0ms)  select sqlite_version(*)
  DEBUG -   (0.1ms)  SELECT "schema_migrations"."version"
    FROM "schema_migrations"
```


Due to this point it is not enough have only this migration, we need to set default value and say that the `password_reset_token` as well as the `password_reset_sent_date` can be null:


```ruby
# db/migrate/007_add_password_reset_token_to_users.rb

class AddPasswordResetTokenToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :password_reset_token, default: 0, null: true
      t.datetime :password_reset_sent_date, default: 0, null: true
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :password_reset_token
      t.remove :password_reset_sent_date
    end
  end
end
```


The stage for the `save_forget_password_token` method is set: It takes our `generate_authentity_token` method from chapter ~\ref{sec:remember_me_funcion} and use the `Time.now` method to set the send date from the password reset function:


```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  ...
  def save_forget_password_token
    self.password_reset_token = generate_authentity_token
    self.password_reset_sent_date = Time.now
    self.save
  end
  ...
end
```


But the token that gets generated can be of the form `B4+KPW145dG9qjfsBuDhuNLVCG/32etcnEo+j5eAFz4M6/i98KRaZGIJ1K77n/HqePEbD2KFdI3ldIcbiOoazQ==`. The slash is bad for the routing. We already used the `normalize_confirmation_code` from `app/models/user_observer.rb` to remove such backslashes, and we could easily the same method again. But we don't want to apply [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself "DRY"). For this purpose we will create a `lib` folder, which acts as a place for sharing code which can be used by models, controllers, and other components. Inside the directory we create a `normalize_token.rb` file:


```ruby
# lib/StringNormalizer/normalize_token.rb

module StringNormalizer
  def normalize_token(token)
    token.gsub("/", "")
  end
end
```


And use the method in the `users_observer.rb`


```ruby
# app/models/user_observer.rb

class UserObserver < ActiveRecord::Observer
  include StringNormalizer
  ...

  private

  def set_confirmation_code(user)
    require 'bcrypt'
    salt = BCrypt::Engine.generate_salt
    confirmation_code = BCrypt::Engine.hash_secret(user.password, salt)
    normalize_token(confirmation_code)
  end
end
```


as well as in `user.rb`:


```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  include StringNormalizer
  ...

  private
  def generate_authentity_token
    require 'securerandom'
    self.authentity_token = normalize_token(SecureRandom.base64(64))
  end
end
```


We are now ready to create our mailer:


```sh
$ padrino-gen mailer PasswordReset password_forget_email
    create  app/mailers/password_reset.rb
    create  app/views/mailers/password_forget
```


In the mailer we take the user to create the password reset token:


```ruby
# app/mailers/password_reset.rb

JobVacancy::App.mailer :password_reset do
  email :password_reset_email do |user, link|
    from "admin@job-vacancy.de"
    subject "Password reset"
    to user.email
    locals :name => user.name, :link => link
    render 'password_reset/password_reset_email'
  end
end
```


The email template contains information and the link for reseting the password:


```erb
# app/views/mailers/password_reset/password_reset_email.plain.erb

Hi <%= name %>,

to reset your password, click on the link below

<%= link %>

If you do not requested a new password, you can ignore this message.

Your Job Vacancy!
```


When the email was send we need to write the `edit` action to handle the link action. The action will take the reset token and check if it still valid. If not, it will redirect us to the forget password route.


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  ...
  get :edit, :map => "/password-reset/:token/edit" do
    @user = User.find_by_password_reset_token(params[:token])

    if @user.password_reset_sent_date <= Time.now + (60 * 60)
      @user.update_attributes({:password_reset_token => 0,
        :password_reset_sent_date => 0})
      flash[:error] = "Password reset token has expired."
      redirect url(:sessions, :new)
    elsif @user
      render 'edit'
    else
      @user.update_attributes({:password_reset_token => 0,
        :password_reset_sent_date => 0})
      redirect url(:password_forget, :new)
    end
  end
end
```


The line with `Time.now + (60 * 60)` is not very readable. Rails has the functionality of using words like `1.hour.ago` with the help of [ActiveSupport](http://api.rubyonrails.org/v2.3.8/classes/ActiveSupport/CoreExtensions/Numeric/Time.html "ActiveSupport") module. Since Padrino is not using `ActiveSupport`, we use the [Timerizer](https://github.com/kylewlacy/timerizer "timerizer") gem which adds the functionality for us:


```ruby
# Gemfile
gem 'timerizer', '0.1.4'
```


And now we can use the new syntax for describing time in a better way:


```ruby
# app/controllers/password_forget.rb

require 'timerizer'

JobVacancy::App.controllers :password_forget do
  ...
  get :edit, :map => "/password-reset/:token/edit" do
    @user = User.find_by_password_reset_token(params[:token])

    if @user.password_reset_sent_date < 1.hour.ago
      ...
    elsif @user
      render 'edit'
    else
      ...
    end
  end
end
```


In the associated `edit` view we use the `form_for` and pass in the `user` model to have access to all validations. Besides we are using then `method:` hash to say which method we want to use for the action:


```erb
# app/views/password_forget/edit.erb

<h2>Reset Password</h2>

<% form_for @user, "/password-reset/#{@user.password_reset_token}",
  method: :post do |f| %>
  <%= f.label :password %>
  <%= f.password_field :password %>
  <%= error_message_on @user, :password, :class => "text-error",
    :prepend => "The password "%>

  <%= f.label :password_confirmation %>
  <%= f.password_field :password_confirmation %>
  <%= error_message_on @user, :password_confirmation, :class => "text-error" %>

  <p>
    <%= f.submit "Reset password", :class => "btn btn-primary" %>
  </p>
<% end %>
```


We add the `update` action now. First it checks, if the user can be found by the passed token and then we use the password field validations from the user model:


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  ...
  post :update, :map => "password-reset/:token" do
    @user = User.find_by_password_reset_token(params[:token])

    if @user.update_attributes(params[:user])
      @user.update_attributes({:password_reset_token => 0,
        :password_reset_sent_date => 0})
      flash[:notice] = "Password has been reseted.
        Please login with your new password."
      redirect url(:sessions, :new)
    else
      render 'edit'
    end
  end
end
```


- Box: Calling mailers in Padrino and where to put them
