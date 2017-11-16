## Sessions
\label{sec:sessions}


It is now possible for our user to register and confirm their registration. In order to handle login we will create a
session controller:


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


We made a mistake during the generation - we forget to add the right actions. Of course we could delete the generated files by hand with a couple of `rm's`, but there is a more elegant way to destroy a controller:


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


Our session controller will look like:


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


\begin{aside}
\heading{Test-First development}

The term comes from [Extreme Programming (XP)](https://en.wikipedia.org/wiki/Extreme_programming "Extreme Programming (XP)") and means that you first write down your tests before writing any implementation code. This forces you to really think about what you are going to do.
There is the hypotheses relating to code quality and a more direct correlation between TDD and productivity were inconclusive.

The tests prevent you from over engineering a problem because you have to make these tests green.

\end{aside}


We write our tests first before the implementation:


```ruby
# spec/app/controllers/sessions_controller_spec.rb

require 'spec_helper'


RSpec.describe "/sessions" do
  describe "GET /login" do
    it "load the login page" do
      get "/login"
      expect(last_response).to be_ok
    end
  end

  describe "POST /sessions/create" do
    let(:user) { build_stubbed(:user) }
    let(:params) { attributes_for(:user) }

    it 'stays on login page if user is not found' do
      expect(User).to receive(:find_by_email) { false }
      post 'sessions/create'
      expect(last_response).to be_ok
    end

    it 'stays on login page if user is not confirmed' do
      user.confirmation = false
      expect(User).to receive(:find_by_email) { user }
      post 'sessions/create'
      expect(last_response).to be_ok
    end

    it 'stays on login page if user has wrong password' do
      user.confirmation = true
      user.password = 'correct'
      expect(User).to receive(:find_by_email) { user }
      post 'sessions/create', password: 'wrong'
      expect(last_response).to be_ok
    end

    it 'redirects to home for confirmed user and correct password' do
      user.confirmation = true
      user.password = 'correct'
      expect(User).to receive(:find_by_email) { user }
      post 'sessions/create', password: 'correct'
      expect(last_response).to be_redirect
    end
  end

  describe "DELETE /logout" do
    xit 'empty the current session'
    xit 'redirects to homepage if user is logging out'
  end
end
```


We are using [method stubs](http://www.relishapp.com/rspec/rspec-mocks/v/3-3/docs "method stubs")[^mocking-is-easy] to make test what we want with the `expect(User).to receive(:find_by_email).and_return(false)`[^mock-and-return-false] method.  So we stimulate the actual application call `find_by_email` in our application and preventing our tests from hitting the database and making it faster. Beside we are using [xit](https://relishapp.com/rspec/rspec-core/v/3-6/docs/pending-and-skipped-examples/skip-examples#temporarily-skipping-by-prefixing-`it`,-`specify`,-or-`example`-with-an-x "xit") to temporarily disable tests.

[^mocking-is-easy]: At first I was thinking at that mocking is something very difficult. Read it the method out loud ten times and you can guess whats going on. If our `User` object gets call from it's class method `find_by_email` it should return false.
[^mock-and-return-false]: Instead of writing `and_return(object)` you can also write the shortcut `{object}` which will I use in the next spec files

Here is the code for our session controller to make the tests "green":


```ruby
# app/controllers/session.rb

JobVacancy::App.controllers :sessions do

  get :new, :map => "/login" do
    render 'new'
  end

  post :create do
    @user = User.find_by_email(params[:email])

    if @user && @user.confirmation && @user.password == params[:password]
      redirect '/'
    else
      render 'new'
    end
  end

  delete :destroy, :map => '/logout' do
  end

end
```


When I started the tests I got some weird error messages of calling a method `user.save` on a nil object when I started writing the test.
Do you remember the `UserObserver`? Exactly, this tiny piece of code is also activated for our tests and since we disable sending mails with the `set :delivery_method, :test` settings in `app.rb` I never received an mails. The solution to this problem was to add an option to in the `spec_helper.rb` to disable the observers:


```ruby
# spec/spec_helper.rb
...
RSpec.configure do |conf|
  conf.before do
    ActiveRecord::Base.observers.disable :all
  end
  ...
end
```


Running our tests:


```sh
$ rspec spec/app/controllers/sessions_controller_spec.rb


SessionsController
  GET /login
    load the login page
  POST /sessions/create
    stays on login page if user is not found (FAILED - 1)
    stays on login page if user is not confirmed (FAILED - 2)
    stays on login page if user has wrong password (FAILED - 3)
    redirects to home for confirmed user and correct password (FAILED - 4)
  DELETE /logout
    empty the current session (PENDING: Temporarily skipped with xit)
    redirects to homepage if user is logging out (PENDING: Temporarily skipped \
      with xit)

Pending: (Failures listed here are expected and do not affect your suite's \
  status)
    ...

Failures:

  1) SessionsController POST /sessions/create stay on page if user is not found
     Failure/Error: expect(last_response).to be_ok
       expected `#<Rack::MockResponse:0xacd2ddc @original_headers={"Content-Type"=>
       "text/plain", "X-Content-Type-Options"=>"nosniff", "Set-Cookie"=>"rack.
       session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRTlkOWJjYWM3YmQ1MDg2ZmFmMzk3%
       0AMmNmZTE4M2IyMmUyYjQ5YzRiYzNmZjg4ODNmYjcwODZkMTc5NjM4NTJh
       M2MG%0AOwBGSSIJY3NyZgY7AEZJIiVhM2JhMWZmMjFkNjg1MDMzODczMjFjYWYxNTBi%
       0AOWVkOAY7AEZJIg10cmFja2luZwY7AEZ7B0kiFEhUVFBfVVNFUl9BR0VOVAY7
       %0AAFRJIi1kYTM5YTNlZTVlNmI0YjBkMzI1NWJmZWY5NTYwMTg5MGFmZDgwNzA5
       %0ABjsARkkiGUhUVFBfQUNDRVBUX0xBTkdVQUdFBjsAVEkiLWRhMzlhM2VlNWU2%
       0AYjRiMGQzMjU1YmZlZjk1NjAxODkwYWZkODA3MDkGOwBG%0A--
       d6e98e46cbddb5ab1287ac6bc9fba47bcfb2724f; path=/; HttpOnly"},
       @errors="", @body_string=nil, @status=403, @header={"Content-Type"=>"text/plain"
       , "X-Content-Type-Options"=>"nosniff", "Set-Cookie"=>
       "rack.session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRTlkOWJjYWM3YmQ1MDg2ZmFmMzk3
       %0AMmNmZTE4M2IyMmUyYjQ5YzRiYzNmZjg4ODNmYjcwODZkMTc5NjM4NTJhM2MG
       %0AOwBGSSIJY3NyZgY7AEZJIiVhM2JhMWZmMjFkNjg1MDMzODczMjFjYWYxNTBi%
       0AOWVkOAY7AEZJIg10cmFja2luZwY7AEZ7B0kiFEhUVFBfVVNFUl9BR0VOVAY7
       %0AAFRJIi1kYTM5YTNlZTVlNmI0YjBkMzI1NWJmZWY5NTYwMTg5MGFmZDgwNzA5
       %0ABjsARkkiGUhUVFBfQUNDRVBUX0xBTkdVQUdFBjsAVEkiLWRhMzlhM2VlNWU2
       %0AYjRiMGQzMjU1YmZlZjk1NjAxODkwYWZkODA3MDkGOwBG%0A--
       d6e98e46cbddb5ab1287ac6bc9fba47bcfb2724f; path=/; HttpOnly",
       "Content-Length"=>"9"}, @chunked=false,
       @writer=#<Proc:0xacd2cb0@/home/wm/.rvm/gems/ruby-2.2.1/gems
       /rack-1.5.5/lib/rack/response.rb:27 (lambda)>, @block=nil,
       @length=9, @body=["Forbidden"]>.ok?` to return true, got false
       # ./spec/app/controllers/sessions_controller_spec.rb:18:in `block
       (3 levels) in <top (required)>'
...

Finished in 0.38537 seconds (files took 0.74964 seconds to load)
8 examples, 5 failures, 2 pending
...
```


The part of the tests with `POST :create.to be_ok` are failing because of [Padrinos csrf token](http://www.rubydoc.info/github/padrino/padrino-framework/Padrino%2FHelpers%2FFormHelpers%2FSecurity:csrf_token_field "Padrinos csrf token").


\begin{aside}
\heading{CSRF (Cross-site request forgery)}

[CSRF](https://en.wikipedia.org/wiki/Cross-site_request_forgery "Cross-site request forgery" )
is a malicious exploit of a website where unauthorized commands are transmitted from a user that the web application trusts. Those commands can be hidden
image tags, JavaScript XMLHttpRequests or hidden forms. To protect against those attacks, web applications are embedding
additional authentication data into requests to detect requests from unauthorized locations.

How does Padrino protects against CSRF?

If you take a look into `config/apps.rb` you can see the following entry:


```ruby
Padrino.configure_apps do
  # enable :sessions
  set :session_secret, '6a3ec199b53b002a3bfaf60' +
    'c746b9182c095950b41f182790a81a0e36d96884'
end
```


This token is used to generate the hidden authenticity token in forms with the help of the current session. Start your application and take a look into the HTML <http://localhost:3000/login>:

```html
<form action="/sessions/create" accept-charset="UTF-8" method="post">
    <input type="hidden" name="authenticity_token"
    value="068aa59cb97beaff2038b403ac9946d7" />
  <label for="email">Email: </label>
  <input type="text" name="email" />

  <label for="password">Password: </label>
  <input type="password" name="password" />

  <label class="checkbox">
    <input type="checkbox" name="remember_me" value="1" /> Remember me
  </label>

  <p>
    <a href="/password_forget">forget password?</a>
  </p>

  <p>
    <input type="submit" value="Sign up" class="btn btn-primary" />
  </p>
</form>
```

The `authenticity_token` is 068aa59cb97beaff2038b403ac9946d7 and is calculated from the current session.
Fill in the form without submitting the data. Now stop the app, change the value of `session_secret` in the `config/apps.rb` file and start the app again.(You can now check value of `"authenticity_token"` in a new tab of the <http://localhost:3000/login> page and see that it is different). If you now subm the data in the first tab you will get a `Forbidden` - that's how CSRF works in Padrino.


You can get Padrino's reaction of this attack in the log under:


```sh
   WARN -  attack prevented by Padrino::AuthenticityToken
  DEBUG -      POST (0.0050s) /sessions/create - 403 Forbidden
```
\end{aside}


To make the tests running, you need to disable them for the test environment:


```ruby
# app/app.rb

module JobVacancy
  class App < Padrino::Application
  ...

  configure :test do
    set :protect_from_csrf, false
  end

  end
end
```


Before going on with implementing the logout action we need to think what happened after we login. We have to find a mechanism to enable the information of the logged in user in all our controllers and views. We will do it with sessions helper. Let's look into this file:


```ruby
# app/helpers/sessions_helper.rb

# Helper methods defined here can be accessed in any controller or view in
# the application

module JobVacancy
  class App
    module SessionsHelper
      # def simple_helper_method
      # ...
      # end
    end

    helpers SessionsHelper
  end
end
```


Yeah, Padrino prints the purpose of this new file and it says what we want to do. Let's implement the main
features[^test-sessions-helper]:


[^test-sessions-helper]: We will write the test in chapter \ref{sec:authorization}



```ruby
# app/helpers/session_helper.rb

module JobVacancy
  class App
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

    helpers SessionsHelper
  end
end
```


There's a lot of stuff going on in this helper:


- `current_user`: Uses the `||=` notation. If the left hand-side isn't initialized, initialize the left hand-side with the right hand-side.
- `current_user?`: Checks if the passed in user is the currently logged in user.
- `sign_in`: Uses the global [session](http://www.sinatrarb.com/faq.html#sessions "Sinatra session") method use the user-id as login information
- `sign_out`: Purges the `:current_user` field from our session.
- `signed_in?`: We will use application to display special actions which should only be available for authenticated users.


\begin{aside}
\heading{Why Sessions and how does sign\_out work?}

When you request an URL in your browser, you are using the HTTP/HTTPS protocol. This protocol is stateless that means that it doesn't save the state in which you are in your application. Web applications implement states with one of the following mechanisms: hidden variables in forms when sending data, cookies, or query strings (e.g. <http://localhost:3000/login?user=test&password=test>).


We are going to use cookies to save if a user is logged in and saving the user-id in our session cookies under the `:current_user` key.


The delete method does the following: It will look into the last request in your application inside the session information hash and delete the `:current_user` key.

If you want to explore more of the internal of an application I highly recommend you [pry gem](https://github.com/pry/pry "pry"). You can throw in at any part of your application `binding.pry` and have full access to all variables.

\end{aside}


Now we are in a position to write tests for our `:destroy` action:


```ruby
# spec/app/controller/sessions_spec.rb

require 'spec_helper'

RSpec.describe "/sessions" do
  ...
  describe "POST /sessions/create" do
    it 'redirects to home for confirmed user and correct password' do
      login_user(user)
    end
  ...
  end

  describe "DELETE /logout " do
    it 'empty the current session' do
      login_user(user)
      delete '/logout'
      expect(last_request.env['rack.session'][:current_user]).to be_nil
    end

    it 'redirects to homepage if user is logging out' do
      delete '/logout'
      expect(last_response).to be_redirect
      expect(last_response.body).to include('You have successfully logged out.')
    end
  end
end

private

def login_user(user)
  user.confirmation = true
  user.password = 'correct'
  expect(User).to receive(:find_by_email) { user }
  post 'sessions/create', password: 'correct'
  expect(last_request.env['rack.session'][:current_user]).not_to be_nil
end

```


We use the [last_request method](https://github.com/brynary/rack-test/blob/master/lib/rack/mock_session.rb#L48 "last_request method") to access to [Rack's SessionHash](http://rubydoc.info/github/rack/rack/master/Rack/Session/Abstract/SessionHash "Rack's SessionHash") information.


And finally the implementation of the code that make our tests green:


```ruby
# app/controllers/session.rb

JobVacancy::App.controllers :sessions do
  ...
  delete :destroy, :map => '/logout' do
    sign_out
    redirect '/', flash[:notice] = 'You have successfully logged out.'
  end
end
```


What we forget due to this point is to make use of the `sign_in(user)` method in our session `:create` action:


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


How can we test now our logic in the view? The main application layout should have a "Login" and "Logout" link according to the status of the user:


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
        <% if signed_in? %> ...
          <%= link_to 'Logout', url(:sessions, :destroy,
            :authenticity_token => session[:csrf]), :method => :delete %>
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


Please note that we have to pass the `authenticity_token` with the saved value of `csrf` for security reasons for security reasons (check box~\ref{box:csrf}). Please not that we have to pass method `:delete` here because we are not in a form.


 The HTTP specification only understands GET and POST in the <form> method attribute. How can we solve this? We need to use a hidden form with the put method:


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

New? <%= link_to 'Register', url(:users, :new) %>
```


\begin{aside}
\heading{No hard coded URLs for controller routes}

The line above with `<% form_tag '/sessions/create' do %>` is not a good solution. If you are changing the mapping inside the controller, you have to change all the hard coded paths manually.

A better approach is to reference the controller and action within the `url` method with `url(:sessions, :create)`. Try it out!
\end{aside}


Here we are using the [form_tag](http://padrinorb.com/guides/application-helpers/form-helpers/#list-of-form-helpers "form_tag of Padrino") instead of the `form_for` tag because we don't want to render information about a certain model.

We want to use the information of the session form to find a user in our database. We can use the submitted inputs with `params[:email]` and `params[:password]` in the `:create` action in our sessions controller.


What is if the given parameters does not match? The basic idea is to pass a variable to the rendering of method which says if we have an error or not and display the message accordingly. To handle this we are using the `:locals` which allows us to use to create customized params in our views:
Local variables accessible in the partial
option to create customized params for your views:


```ruby
# app/controllers/sessions.rb

JobVacancy::App.controllers :sessions do
  get :new, :map => "/login" do
    render 'new', locals: { error: false }
  end

  post :create do
    @user = User.find_by_email(params[:email])

    if @user && @user.confirmation && @user.password == params[:password]
      sign_in(@user)
      redirect '/'
    else
      render 'new', locals: { error: true }
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

New? <%= link_to 'Register', url(:users, :new) %>
```


The last thing we want to is to give the user feedback about what the recently action. Like that it would be nice to give feedback of the success of the logged and logged out action. We can do this with short flash messages above our application which will fade away after a certain amount of time. To do this we can use [Padrino's flash mechanism](http://www.rubydoc.info/github/padrino/padrino-framework/Padrino/Flash/Helpers#flash-instance_method "Padrino's flash mechanism")[^padrino-flash]

[^padrino-flash]: It is s build on [Rails flash message implementation](http://guides.rubyonrails.org/action_controller_overview.html#the-flash "Rails flash message implementation").


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
    <% if !flash.empty? %>
      <div class="row" id="flash">
      <% if flash.key?(:notice) %>
        <div class="span9 offset3 alert alert-success">
          <%= flash[:notice] %>
        </div>
      <% end %>
      </div>
    <% end %>
  </div>
  ...
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
      sign_in(user)
      redirect '/', flash[:notice] = 'You have successfully logged out.'
    else
      render 'new', locals: { error: true }
    end
  end
  ...
end
```


If you now login successfully you will see the message but it will not go away. We will use jQuery's [fadeOut method](http://api.jquery.com/fadeOut "fadeOut method of jQuery") to get rid of the message.


This is the first time we writing our own customized JavaScript, let's create the inline with the following content:


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

