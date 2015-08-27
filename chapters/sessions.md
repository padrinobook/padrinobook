## Sessions

Now that our users have the possibility to register and confirm on our page, we need to make it possible for our users to sign in. For handling login, we need to create a session controller:


```sh
$ padrino-gen controller Sessions new create destroy
  create  app/controllers/sessions.rb
  create  app/views/sessions
   apply  tests/rspec
  create  spec/app/controllers/sessions_controller_spec.rb
  create  app/helpers/sessions_helper.rb
   apply  tests/rspec
  create  spec/app/helpers/sessions_helper_spec.rb
```


We made a mistake during the generation - we forget to add the right action for our request. Before making the mistake to delete the generated files by hand with a couple of `rm's`, you can run a generator to destroy a controller:


```sh
$ padrino-gen controller Sessions -d
  remove  app/controllers/sessions.rb
  remove  app/views/sessions
   apply  tests/rspec
  remove  spec/app/controllers/sessions_controller_spec.rb
  remove  app/helpers/sessions_helper.rb
   apply  tests/rspec
  remove  spec/app/helpers/sessions_helper_spec.rb
```


And run the generate command with the correct actions:


```sh
$ padrino-gen controller Sessions get:new post:create delete:destroy
```


Our session controller is naked:


```ruby
# app/controllers/sessions_controller.rb

JobVacancy:App.controllers :sessions do

  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end

  get :new do
  end

  post :create do
  end

  delete :destroy do
  end
end
```


Before going on to write our tests first before we start with the implementation:


```ruby
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
```


\begin{aside}
\heading{Test-First development}

Is a term from [Extreme Programming (XP)](http://en.wikipedia.org/wiki/Extreme_programming "Extreme Programming (XP)") and means that you first write down your tests before writing any code to solve it. This forces you to really think about what you are going to do. These tests prevent you from over engineering a problem because you has to make these tests green.

\end{aside}


Here are now the tests for the `GET :new` and `POST :create` actions of our session controller:


```ruby
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
```


We are using **mocking** to make test what we want with the `User.should_receive(:find_by_email).and_return(user)` method. I was thinking at the first that mocking is something very difficult but it isn't Read it the method out loud ten times and you can guess whats going on. If our `User` object gets call from it's class method `find_by_email` it should return our user object. This method will simulate from calling an actual find method in our application - yeah we are mocking the actual call and preventing our tests from hitting the database and making it faster. Actual call and preventing our tests from hitting the database and making it faster.


Here is the code for our session controller to make the test green:


```ruby
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
```


When I started the tests I got some weird error messages of calling a method on a nil object and spend one hour till I found the issue. Do you remember the `UserObserver`? Exactly, this tiny piece of code is also activated for our tests and since we disable sending mails with the `set :delivery_method, :test` settings in `app.rb` I never received an mails. The simple to this problem was to add an option to in the `spec_helper.rb` to disable the observer:


```ruby
# spec/spec_helper.rb
...
RSpec.configure do |conf|
  conf.before do
    User.observers.disable :all # <-- turn of user observers for testing reasons
  end
  ...
end
```


Running our tests:


```sh
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
```


Before going on with implementing the logout action we need to think what happened after we login. We have to find a mechanism to enable the information of the logged in user in all our controllers and views. We will do it with sessions. When we created the session controller there was the line `create  app/helpers/sessions_helper.rb` -- let's look into this file:


```ruby
# app/helpers/sessions_helper.rb

# Helper methods defined here can be accessed in any controller or view in
# the application

JobVacancy::App.helpers do
  # def simple_helper_method
  #  ...
  # end
end
```


Yeah, Padrino prints the purpose of this new file and it says what we want to do. Let's implement the main features:


```ruby
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
```


There's a lot of stuff going on in this helper:


- `current_user`: Uses the `||=` notation. If the left hand-side isn't initialized, initialize the left hand-side with the right hand-side.
- `sign_in(user)`: Uses the global [session](http://www.sinatrarb.com/faq.html#sessions "Sinatra session") method use the user Id as login information
- `sign_out`: Purges the `:current_user` field from our session.
- `signed_in?`: We will use this small method within our whole application to display special actions which should only be available for authenticated users.


\begin{aside}
\heading{Why Sessions and how does sign\_out work?}

When you request an URL in your browser you are using the HTTP/HTTPS protocol. This protocol is stateless that means that it doesn't save the state in which you are in your application. Web applications implement states with one of the following mechanisms: hidden variables in forms when sending data, cookies, or query strings (e.g. <http://localhost:3000/login?user=test&password=test>).


We are going to use cookies to save if a user is logged in and saving the user-Id in our session cookies under the `:current_user` key.


What the delete method does is the following: It will look into the last request in your application inside the session information hash and delete the `current_user` key. And the sentence in code `browser.last_request.env['rack.session'].delete(:current_user)`. If you want to explore more of the internal of an application I highly recommend you [Pry](https://github.com/pry/pry "Pry"). You can throw in at any part of your application `binding.pry` and have full access to all variables.

\end{aside}


Now we are in a position to write tests for our `:destroy` action:


```ruby
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
      # first arguments are params (like the ones out of an form), the second
      # are environments variables
    get '/logout', { :name => 'Hans', :password => 'Test123' },
      'rack.session' => { :current_user => 1 }
  end
  ...
end
```


We use the our own `session` method in our tests to have access to the last response of our `rack.session`.  What we need to achieve is to have access to [Rack's SessionHash](http://rubydoc.info/github/rack/rack/master/Rack/Session/Abstract/SessionHash "Rack's SessionHash"). The definition of this method is part of our `spec_helper.rb` method:


```ruby
# spec/spec_helper.rb

...
# have access to the session variables
def session
  last_request.env['rack.session']
end
```


And finally the implementation of the code that it make our tests green:


```ruby
# app/controllers/session.rb

JobVacancy::App.controllers :sessions do
  get :destroy, :map => '/logout' do
    sign_out
    redirect '/'
  end
end
```


What we forget due to this point is to make use of the `sign_in(user)` method. We need this during our session `:create` action:


```ruby
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
```


Where can we test now our logic? The main application layout of our application should have a "Login" and "Logout" link according to the status of the user:


```erb
<%# app/views/application.rb %>

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
          <%= link_to 'Logout', url(:sessions, :destroy) %>
        <% else %>
        <div class="span2">
          <%= link_to 'Login', url(:sessions, :new) %>
        </div>
        <% end %>
        </nav>
      </div>
      ...
    </div>
  </div>
</body>
```


With the change above we changed the default "Registration" entry in our header navigation to "Login". We will add the link to the registration form now in the 'session/new' view:


```erb
<%# app/views/sessions/new.erb %>

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

New on this platform? <%= link_to 'Register', url(:users, :new) %>
```


\begin{aside}
\heading{No hard coded urls for controller routes}

The line above with `<% form_tag '/sessions/create' do %>` is not a good solution. If you are changing the mapping inside the controller, you have to change all the hard coded paths manually. A better approach is to reference the controller and action within the `url` method with `url(:sessions, :create)`.

\end{aside}


Here we are using the [form_tag](http://www.padrinorb.com/guides/application-helpers#form-helpers "form_tag of Padrino") instead of the `form_for` tag because we don't want to render information about a certain model. We want to use the information of the session form to find a user in our database. We can use the submitted inputs with `params[:email]` and `params[:password]` in the `:create` action in our action controller. My basic idea is to pass a variable to the rendering of method which says if we have an error or not and display the message accordingly. To handle this we are using the `:locals` option to create customized params for your views:


```ruby
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
```


Now we can use the `error` variable in our view:


```erb
<%# app/views/sessions/new.erb %>

<h1>Login</h1>

<% form_tag url(:sessions, :create) do %>
  <% if error %>
    <div class="alert alert-error">
      <h4>Error</h4>
      Your Email and/or Password is wrong!
    </div>
  <% end %>
...
<% end %>

New on this platform? <%= link_to 'Register', url(:users, :new) %>
```


The last thing we want to is to give the user feedback about what the action he was recently doing. Like that it would be nice to give feedback of the success of the logged and logged out action. We can do this with short flash messages above our application which will fade away after a certain amount of time. To do this we can use Padrino's flash mechanism is build on [Rails flash message implementation](http://guides.rubyonrails.org/action_controller_overview.html#the-flash "Rails flash message implementation").


And here is the implementation of the code:


```erb
<%# app/views/application.erb %>

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
```


Next we need implement the flash messages in our session controller:


```ruby
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
```


If you now login successfully you will see the message but it will stay there forever. But we don't want to have this message displayed the whole time, we will use jQuery's [fadeOut method](http://api.jquery.com/fadeOut "fadeOut method of jQuery") to get rid of the message. Since we are first writing our own customized JavaScript, let's create the file with the following content:


```erb
<%# app/views/application.erb %>

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
```


Feel free to add the `flash[:notice]` function when the user has registered and confirmed successfully on our platform. If you have problems you can check [my commit](https://github.com/wikimatze/job-vacancy/commit/f7233bf2edc7da89f02adf7f030a090fc74b3f2d).

