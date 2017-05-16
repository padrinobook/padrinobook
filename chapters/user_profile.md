## User Profile

To update a user profile we need the `edit` and `update` action. Let's beginning with writing tests for the `edit` action:


```ruby
# spec/app/controller/users_controller_spec.rb

...

describe "GET /users/:id/edit" do
  let(:user) { build(:user) }
  let(:user_second) { build(:user) }

  it 'redirects to /login if user is not signed in' do
    expect(User).to receive(:find_by_id).and_return(nil)
    get '/users/-1/edit'
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/login')
  end

  it 'redirects to /login signed in user tries to call a different user' do
    expect(User).to receive(:find_by_id).and_return(user, user_second)
    get "/users/#{user_second.id}/edit"
    expect(last_response).to be_redirect
    expect(last_response.header['Location']).to include('/login')
  end

  it 'renders the view for editing a user' do
    expect(User).to receive(:find_by_id).and_return(user, user)
    get "/users/#{user.id}/edit", {}, 'rack.session' =>
      { current_user: user_second }
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
    render 'edit'
  end
end
```


We don't want that everybody can edit the profile for other users. Before we are going to call these actions we set a
[route filter](http://padrinorb.com/guides/controllers/route-filters/ "before route filter")[^route-filter]. They are
evaluated before each requests for the given actions.

For the `get :edit` action we are using [namespaced route aliases](http://padrinorb.com/guides/controllers/routing/#namespaced-route-aliases
 "namespaced route aliases"). They have the advantage that you can refer to them with the `url_for` method.

[^route-filter]: It is possible to define variables, change the response, request, and so on.

Let's write the tests for the `update` action:


```ruby
# spec/app/controllers/users_controller_spec.rb

...
describe "PUT /users/:id" do
  let(:user) { build(:user) }
  let(:user_second) { build(:user) }
  let(:put_user) {
    {'name' => user.name,
     'email' => user.email,
     'password' => user.password,
     'password_confirmation' => user.password
    }
  }

  describe "redirects to /login if" do
    it 'user is not signed in' do
      expect(User).to receive(:find_by_id).and_return(nil)
      put '/users/1'
      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/login')
    end

    it "user is signed in and tries to call a different user" do
      expect(User).to receive(:find_by_id).and_return(user, user_second)
      put "/users/1"
      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/login')
    end
  end

  describe "link to /edit" do
    it 'if user has valid account changes' do
      test_user = double(User, id: user.id)
      expect(test_user).to receive(:update_attributes).with(put_user) { true }
      expect(User).to receive(:find_by_id).and_return(test_user, test_user)

      put "/users/#{user.id}", user: put_user
      expect(last_response).to be_redirect
      expect(last_response.body).to eq 'You have updated your profile.'
      expect(last_response.header['Location']).to include('/edit')
    end

    it 'if user has not valid account changes' do
      put_user =
        {'name' => user.name,
         'email' => user.email,
         'password' => user.password,
         'password_confirmation' => 'fake'
        }

      test_user = double(User, id: user.id)
      expect(test_user).to receive(:update_attributes).with(put_user) { false }
      expect(User).to receive(:find_by_id).and_return(test_user, test_user)

      put "/users/#{user.id}", user: put_user
      expect(last_response).to be_redirect
      expect(last_response.body).to eq 'Your profile was not updated.'
      expect(last_response.header['Location']).to include('/edit')
    end
  end
end
...
```

We are using [test doubles](https://relishapp.com/rspec/rspec-mocks/v/3-6/docs/basics/test-doubles "test doubles")
which stands for any objects that is used during the test. Since we don't want to have a database we can mock the
`update_attributes` method and can return what we need for our tests.


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


Please note that the [update_attributes](http://www.rubydoc.info/gems/activerecord/ActiveRecord%2FPersistence:update "update_attributes") method is making a [valid?](http://www.rubydoc.info/gems/activerecord/ActiveRecord%2FValidations:valid%3F  "valid?") method before the changes are saved.


Making the `update` pass in the view is a little bit tricky: The HTTP specification only understands `GET` and `POST` in the `<form>` method attribute. How can we solve this? We need to use a hidden form with the `put` method:


```erb
<%# app/views/users/edit.erb %>

<h2>Edit your profile</h2>

<% form_for @user, url(:users, :update, id: @user.id), method: :put do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
  <%= error_message_on @user, :name, class: "text-error", prepend: "The name " %>

  <%= f.label :email %>
  <%= f.text_field :email %>
  <%= error_message_on @user, :email, class: "text-error", prepend: "The email " %>

  <%= f.label :password %>
  <%= f.password_field :password %>
  <%= error_message_on @user, :password, class: "text-error",
    prepend: "The password "%>

  <%= f.label :password_confirmation %>
  <%= f.password_field :password_confirmation %>
  <%= error_message_on @user, :password_confirmation, class: "text-error" %>

  <p>
    <%= f.submit "Save changes", class: "btn btn-large btn-primary" %>
  </p>
<% end %>
```


You can specify the [HTTP methods](https://www.w3schools.com/tags/ref_httpmethods.asp "HTTP methods") with `method: <action>`. So `method: :put` will be translated into:


```html
<input type="hidden" value="put" name="_method"</input>
```


### Authorization
\label{sec:authorization}

The controller actions are ready and we used many method from the `session_helper.rb`. Before we add now the action for
signup and registration to the view, it's time to test the helper from "Sessions" section ~\ref{sec:sessions}.


Our generated helper spec has the following structure:


```ruby
# app/helpers/sessions_helper.rb

require 'spec_helper'

RSpec.describe "JobVacancy::App::SessionsHelper" do
  pending "add some examples to (or delete) #{__FILE__}" do
    let(:helpers){ Class.new }
    before { helpers.extend JobVacancy::App::SessionsHelper }
    subject { helpers }

    it "should return nil" do
      expect(subject.foo).to be_nil
    end
  end
end
```


The new thing here is the [subject](https://relishapp.com/rspec/rspec-core/v/3-6/docs/subject/explicit-subject "subject"). It describe a thing (object, class, method) under test. Because we are testing only one object here, the name `subject` is fine for use but if you handling several objects in a test, you can't possibly guess what `subject` is because it is not intention revealing. For that case you better give the object the right name.


Padrino is requiring helper automatically in the `spec_helper` file with the following line:


```ruby
# spec/spec_helper.rb

...
Dir[File.expand_path(File.dirname(__FILE__) + '/../app/helpers/**/*.rb')]
  .each(&method(:require))
...
```


Here is the outline of the tests:


```ruby
# spec/app/helpers/sessions_helper_spec.rb

require 'spec_helper'


RSpec.describe "JobVacancy::App::SessionsHelper" do
  let(:user) { User.new }
  let(:session_helper) { Class.new }

  before { session_helper.extend JobVacancy::App::SessionsHelper }
  subject { session_helper }

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


Please not that we will not test the `current_user=(user)` method because it is a setter method.


What we need to do now for our test is to to mock a request and set the user id of some of our test user in the session hash. To create a new session we will use [Rack::Test::Session](https://github.com/rack-test/rack-test/blob/master/lib/rack/test.rb#L25 "Rack::Test::Session") and mock the `last_request` method call:


```ruby
# spec/app/helpers/sessions_helper_spec.rb

require 'spec_helper'

RSpec.describe "JobVacancy::App::SessionsHelper" do

  ...
  describe "#current_user" do
    it 'returns the current user if user is set' do
      subject.current_user = user
      expect(User).to receive(:find_by_id).never
      expect(subject.current_user).to eq user
    end

    it "returns the current user from session" do
      user.id = 1
      browser = Rack::Test::Session.new(JobVacancy::App)
      browser.get '/', {}, 'rack.session' => { current_user: user.id }
      expect(User).to receive(:find_by_id).and_return(user)
      expect(subject).to receive(:session).and_return(user)
      expect(subject.current_user).to eq user
    end
  end
  ...
end
```


Instead of writing `JobVacancy::App` you can also pass `app` in the line `Rack::Test::Session.new(JobVacancy::App)` which is automatically defined in the `spec_helper`:


```ruby
# spec/spec_helper.rb
...

def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
```


You can write the other tests as an exercise[^exercise-spec-helper-spec] on your own.


[^exercise-spec-helper-spec]: In case you have problems with writing them, please check the [spec on GitHub](https://github.com/wikimatze/job-vacancy/blob/master/spec/app/controllers/sessions_controller_spec.rb "spec on GitHub").


Finally, we need to provide the edit link in the header navigation:


```erb
# app/views/application.erb

<nav id="navigation">
  ...
  <% if signed_in? %>
    <div class="span2">
      <%= link_to 'Logout', url(:sessions, :destroy) %>
    </div>
    <div class="span2">
      <%= link_to 'Edit Profile', url(:users, :edit, id: session[:current_user]) %>
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

We are currently using the `sign_in` method from the session helper to login an user. But this is only valid for a session. What we need is something permanent.
[Cookies](https://en.wikipedia.org/wiki/HTTP_cookie "Cookies") are the perfect choice for this. We could use the `user_id` from the user as an unique token,
but this can be changed too easily. Creating an unique long [secure hash](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms "secure hash") is more secure.


Let's create and run the migration for the authenticity token:


```sh
$ padrino-gen migration AddAuthentityTokenToUsers authentity_token:string
     apply  orms/activerecord
    create  db/migrate/006_add_authentity_token_to_users.rb
$ padrino rake ar:migrate
=> Executing Rake ar:migrate ...
  DEBUG -   (0.1ms)  SELECT "schema_migrations"."version"
    FROM "schema_migrations" ...
   INFO -  Migrating to AddAuthentityTokenFieldToUsers (6)
   ...
```


\begin{aside}
\heading{Cookies}

HTTP is a [stateless protocol](http://en.wikipedia.org/wiki/Stateless_protocol "stateless protocol") and cookies way a
way to save information sent from a website and store them in the browser. Each time the user visits the site again, the
browser sends the information back to server and notifies the server about the identity of the user.

A cookie can consists of the following components: name, value, expiry date, path (scope of the cookie), domain (valid for which
domain).
\end{aside}


A way to create random strings in Ruby is to use the [SecureRandom class](http://ruby-doc.org/stdlib-2.4.1/libdoc/securerandom/rdoc/SecureRandom.html "securerandom class").
By using the [before_create callback](http://www.rubydoc.info/docs/rails/ActiveRecord/Callbacks "before_create callback"),
we create a token for each registered user[^registered-user-note].


[^registered-user-note]: If you are in a situation where you already have a bunch of users and you now decide to create hashes for them, you have to create a migration script for the existing user base.


```ruby
# models/user.rb

class User < ActiveRecord::Base
  require 'securerandom'
  ...

  before_create :generate_authentity_token
  ...

  private

  def generate_authentity_token
    self.authentity_token = SecureRandom.base64(64)
    SecureRandom
  end
end
```


To test the private callback, we can use the [send method](http://ruby-doc.org/core-2.4.1/Object.html#method-i-send "send method") to create our `generate_authentity_token` callback:


```ruby
# spec/models/user_spec.rb

require 'spec_helper'

RSpec.describe "User Model" do
  ...

  describe "#generate_authentity_token" do
    it 'generates the authentity_token before user is saved' do
      expect(user).to receive(:save) { true }
      user.send(:generate_authentity_token)
      user.save
      expect(user.authentity_token).not_to be_empty
    end
  end
end
```


Next it's time to create the checkbox on the login page with help of the
[check_box_tag](http://www.rubydoc.info/gems/padrino-helpers/Padrino%2FHelpers%2FFormHelpers:check_box_tag "check_box_tag"):


```erb
<%# views/sessions/new.erb %>

<h1>Login</h1>

  ...
  <label class="checkbox">
    <%= check_box_tag :remember_me %> Remember me
  </label>
```


If the user clicks on the *Remember me* checkbox, it's time for our session controller to create a cookie. We have to
modify our `create` action from the session controller:


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
                            value: { domain: 'jobvacancy.de',
                                        path: '/' },
                                        max_age: "#{thirty_days_in_seconds}")
        @user.save
      end

      flash[:notice] = 'You have successfully logged in!'
      sign_in(@user)
      redirect '/'
    else
      render 'new', locals: { error: true }
    end
  end
  ...
end
```


First, we create a secure random hex value and assign to the `authentity_token` attribute to the user. Then we use the
[set_cookie](http://www.rubydoc.info/github/rack/rack/Rack%2FResponse%2FHelpers:set_cookie "set_cookie") method to
generate a cookie which is valid for thirty days.


When you login the next time into the application, click the remember me you checkbox. Stop and start the application
again, you will be logged in automatically for the next thirty days.


![Figure 2-2. Start page of the app](images/cookies.png)


If you want to see the cookie in your browser, you can install [Web Developer extension](https://addons.mozilla.org/en-US/firefox/addon/web-developer "Web Developer extension") for [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new "Mozilla Firefox") and open the *View cookie information* pane in the *Cookies* tab.

The specs for the `post :create` action:

```ruby
# spec/app/controllers/sessions_controller_spec.rb

...

describe "POST :create" do
  ...

  it 'redirects if user is correct and has remember_me' do
    token = 'real'
    user = double('User')
    thirty_days_in_seconds = 2592000
    expect(user).to receive(:id) { 1 }
    expect(user).to receive(:password) { 'secret' }
    expect(user).to receive(:confirmation) { true }
    expect(user).to receive(:authentity_token=) { token }
    expect(user).to receive(:save)
    expect(User).to receive(:find_by_email) { user }
    expect(SecureRandom).to receive(:hex).at_least(:once) { token }

    post 'sessions/create', password: 'secret', remember_me: true
    expect(last_response).to be_redirect
    cookie = last_response['Set-Cookie']
    expect(cookie).to include('permanent_cookie')
    expect(cookie).to include('path=/')
    expect(cookie).to include('domain%3D%3E%22jobvacancy.de')
    expect(cookie).to include("max-age=#{thirty_days_in_seconds}")
  end
end
```


### Password Reset

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


We have to create a `GET` `:action` and map it to `/password_forget`:


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  get :new, :map => 'password_forget'  do
    render 'new'
  end
  ...
end
```


In the `new` action’s view we’ll create the form with the [form_tag](http://padrinorb.com/guides/application-helpers/form-helpers/#list-of-form-helpers "form_tag") without a model that allows a user to enter their email address and request that their password is reset. The form looks like this:


```erb
<%# app/views/password_forget/new.erb %>

<h2>Forgot Password</h2>

<% form_tag url(:password_forget, :create) do %>
  <%= label_tag :email %>
  <%= text_field_tag :email %>

  <p>
    <%= submit_tag "Reset password", class: "btn btn-primary" %>
  </p>
<% end %>
```

The idea behind the `POST` `:create` action is the following: We need to process the password-forget email and email instructions on how to reset password to the supplied email address. We don't validate if the email address is correct, we don't want to have malicious user to check if a user exists or not.


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  ...
  post :create do
    @user = User.find_by_email(params[:email])

    if @user
      @user.save_forget_password_token
      # here the deliver method will be called
    end

    render 'success'
  end
  ...
end
```


The `save_forget_password_token` method will generate a security token for the given user. The token should only valid for one hour. We need to save the `password_reset_sent_date` as well as the `password_reset_token`. Let's add these fields to the `User` model:


```sh
$ padrino-gen migration AddPasswordResetTokenToUsers
  password_reset_token:string password_reset_sent_date:datetime
       apply  orms/activerecord
       ...
```


Due to this point it is not enough have only this migration, we need to set default value and say that the `password_reset_token` as well as the `password_reset_sent_date` can be `null`:


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


The stage for the `save_forget_password_token` method is set: It takes our `generate_authentity_token` method from
chapter ~\ref{sec:remember_me_funcion} and use the [Time.now](http://ruby-doc.org/core-2.4.1/Time.html#method-c-now "Time.now")
method to set the send date from the password reset function:


```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  ...
  def save_forget_password_token
    self.password_reset_token = generate_authentity_token
    self.password_reset_sent_date = Time.now
    self.save
  end
end
```


But the token that gets generated can be of the form `B4+KPW145dG9qjfsBuDhuNLVCG/32etcnEo+j5eAFz4M6/i...`. The slash (`/`) and plus (`+`) is bad for routing. We already used the `normalize_confirmation_code` from section ~\ref{sec:controller_method_and_action_for_password_confirmation} to remove such backslashes, and we could easily the same method again. But we want to apply [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself "DRY"). For this purpose we will create a `lib` folder, which acts as a place for sharing code which can be used by models, controllers, and other components. Inside the directory we create a `normalize_token.rb` file:


```ruby
# lib/StringNormalizer/normalize_token.rb

module StringNormalizer
  def normalize(token)
    token.delete('/').delete('+')
  end
end
```


And the test the `StringNormalizer` is similar to the `SessionsHelper` tests of section ~\ref{sec:authorization}:


```ruby
# spec/lib/normalize_token_spec.rb

require 'spec_helper'

RSpec.describe StringNormalizer do
  let(:string_normalizer) { Class.new { extend StringNormalizer } }

  subject { string_normalizer }

  it 'replaces slashes and + signs in strings' do
    token = 'B4+K/32'
    expected_token = 'B4K32'
    expect(string_normalizer.normalize(token)).to eq expected_token
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
    normalize(confirmation_code)
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
    self.authentity_token = normalize(SecureRandom.base64(64))
  end
end
```


We are now ready to create our mailer:


```sh
$ padrino-gen mailer PasswordReset password_reset_email
```


In the mailer we take the user to create the password reset token as a link for them:


```ruby
# app/mailers/password_reset.rb

JobVacancy::App.mailer :password_reset do
  email :password_reset_email do |user, link|
    from 'admin@job-vacancy.de'
    subject 'Password reset'
    to user.email
    locals name: user.name, link: link
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


Now we can use the deliver method to send the password-reset link for the user in the `create` action:


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  ...
  post :create do
    ...

    if @user
      ...
      link = "http://localhost:3000" + url(:password_forget, :edit,
        :token => @user.password_reset_token)
      deliver(:password_reset, :password_reset_email, @user, link)
    end
    ...
  end
  ...
end
```


When the email was send we need to write the `edit` action to handle the link action. The action will take the reset
token and check if it is still valid.


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do

  ...
  get :edit, :map => "/password-reset/:token/edit" do
    @user = User.find_by_password_reset_token(params[:token])

    if @user && Time.now.to_datetime <
      (@user.password_reset_sent_date.to_datetime + (1.0/24.0))
      render 'edit'
    elsif @user && Time.now.to_datetime >=
      (@user.password_reset_sent_date.to_datetime + (1.0/24.0))
      @user.update_attributes(
        { password_reset_token: 0, password_reset_sent_date: 0 })
      redirect url(:sessions, :new), flash[:error] =
        'Password reset token has expired.'
    else
      redirect url(:password_forget, :new)
    end
  end
end
```


The line with `@user.password_reset_sent_date.to_datetime + (1.0/24.0)` add one hour a hour fraction[^time-fraction] of a whole day.
I know that this line is not very readable - as an alternative you could use the [Timerizer](https://github.com/kylewlacy/timerizer "timerizer")[^timerizer]

[^time-fraction]: Got the inspiration from http://stackoverflow.com/a/31447415
[^timerizer]: Provides you a `1.hour.ago` or 1.hour.after like syntax inspired from from [ActiveSupport](http://api.rubyonrails.org/v2.3.8/classes/ActiveSupport/CoreExtensions/Numeric/Time.html "ActiveSupport") module.


In the associated `edit` view we use the `form_for` and pass in the `user` model to have access to all validations.
Besides we are using then `method:` hash to say which method we want to use for the action:


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


Next we add the `update` action. First it checks, if the user can be found by the passed token and then we use the
password field validations from the user model:


```ruby
# app/controllers/password_forget.rb

JobVacancy::App.controllers :password_forget do
  ...

  post :update, :map => "password-reset/:token" do
    @user = User.find_by_password_reset_token(params[:token])

    if @user && @user.update_attributes(params[:user])
      @user.update_attributes({:password_reset_token => 0,
        :password_reset_sent_date => 0})
      redirect url(:sessions, :new), flash[:notice] = "Password has been reseted.
        Please login with your new password."
    else
      render 'edit'
    end
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

- Box: Calling mailers in Padrino and where to put them
