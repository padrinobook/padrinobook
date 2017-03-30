## Creating The Application

Start with generating a new project with the canonical `padrino` command. In contrast to our "Hello World!" application (app) before, we are using new options:


```sh
$ mkdir ~/padrino-projects
$ cd ~/padrino-projects
$ padrino-gen project job-vacancy -d activerecord \
  -t rspec \
  -s jquery \
  -e erb \
  -a sqlite
```


Explanation of the fields commands:


- **-d activerecord**: We are using [Active Record](https://rubygems.org/gems/activerecord "Active Record") as the orm library (*Object Relational Mapper*).
- **-t rspec**: We are using the [RSpec](https://github.com/dchelimsky/rspec/wiki/get-in-touch "RSpec") testing framework.
- **-s jquery**: Defining the JavaScript library we are using - for this app will be using the ubiquitous [jQuery](https://jquery.com "jQuery") library.
- **-e erb**: We are using [ERB](https://ruby-doc.org/stdlib-2.4.1/libdoc/erb/rdoc/ERB.html "ERB") (*embedded ruby*) markup for writing HTML templates.
- **-a sqlite**: Our adapter for the activerecord ORM[^orm] database adapter is [SQLite](http://www.sqlite.org "SQLite"). The whole database is saved in a text file.


Since we are using RSpec for testing, we will use its' built-in mock extensions [rspec-mocks](https://github.com/rspec/rspec-mocks "rspec mocks") for writing tests later. In case you want to use another mocking library like [rr](https://rubygems.org/gems/rr "rr") or [mocha](http://gofreerange.com/mocha/docs "mocha"), feel free to add it with the **-m** option.


You can use a vast array of other options when generating your new Padrino app, this table shows the currently available options:


- `orm`: Available options are: [activerecord](https://github.com/rails/rails/tree/master/activerecord "Active Record"), [couchrest](https://github.com/couchrest/couchrest "couchrest"),  [datamapper](http://datamapper.org "datamapper"), [minirecord](https://github.com/DAddYE/mini_record "minirecord"), [mongoid](https://github.com/mongoid/mongoid "mongoid"), [mongomatic](https://github.com/mongomatic/mongomatic "mongomatic"), [ohm](https://github.com/soveran/ohm "ohm"), [ripple](https://github.com/basho-labs/ripple "ripple"), and [sequel](https://github.com/jeremyevans/sequel "sequel"). The command line alias is `-d`.
- `test`: Available options are: [bacon](https://github.com/chneukirchen/bacon "bacon"), [cucumber](https://github.com/cucumber/cucumber "cucumber"), [minitest](https://github.com/seattlerb/minitest "minitest"), [riot](http://thumblemonks.github.io/riot "riot"), [rspec](https://github.com/rspec/rspec "rspec"), [shoulda](https://github.com/thoughtbot/shoulda "shoulda"), and [steak](https://github.com/cavalle/steak "steak"). The command line alias is `-t`.
- `script`: Available options are: [dojo](http://dojotoolkit.org "dojo"), [extcore](http://www.sencha.com/products/extcore "extcore"), [jquery](http://jquery.com "jQuery"), [mootools](http://mootools.net "mootools"), [prototype](http://prototypejs.org/ "prototype"), and [rightjs](http://rightjs.org "rightjs"). The command line alias is `-s`.
- `renderer`: Available options are: [erb](http://ruby-doc.org/stdlib-2.1.4/libdoc/erb/rdoc/ERB.html "erb"), [haml](http://ruby-doc.org/stdlib-2.1.4/libdoc/erb/rdoc/ERB.html "haml"), [liquid](http://liquidmarkup.org "liquid"), and [slim](http://slim-lang.com "slim"). The command line alias is `-e`.
- `stylesheet`: Available options are: [compass](http://compass-style.org "compass"), [less](http://lesscss.org "less"), [sass/scss](http://sass-lang.com "sass and scss"). The command line alias is `-c`.
- `mock`: Available options are: [mocha](http://gofreerange.com/mocha "mocha") and [rr](http://rr.github.io/rr "rr").


The default value of each option is none. In order to use them you have to specify the option you want to use.


Besides the `project` option for generating new Padrino apps, the following table illustrates the other generators available:


- `admin`: A very nice built-in admin dashboard.
- `admin_page`: Creates for an existing model the CRUD operation for the admin interface.
- `app`: You can define other apps to be mounted in your main app.
- `controller`: A controller takes date from the models and puts them into view that are rendered.
- `mailer`: Creating new mailers within your app.
- `migration`: Migrations simplify changing the database schema.
- `model`: Models describe data objects of your application.
- `project`: Generates a completely new app from the scratch.
- `plugin`: Creating new Padrino projects based on a template file - it's like a list of commands.


Later, when *the time comes*, we will add extra gems, for now though we'll grab the current gems using `bundle` by running at the command line:


```sh
$ bundle install
```

### Basic Layout

Lets design our first version of the *index.html* page which is the starter page our app. An early design question is: Where to put the *index.html* page? Because we are not working with controllers, the easiest thing is to put the *index.html* directly under the public folder in the project.


We are using [HTML5](http://en.wikipedia.org/wiki/HTML5 "HTML5") for the page, and add the following code into `public/index.html`:


```html
<!DOCTYPE html>
<html lang="en-US">
  <head>
    <title>Start Page</title>
  </head>
  <body>
    <p>Hello, Padrino!</p>
  </body>
</html>
```


Plain static content - this used to be the way websites were created in the beginning of the web. Today, apps provide dynamic layout. During this chapter, we will how to add more and more dynamic parts to our app.


We can take a look at our new page by executing the following command:


```sh
$ cd job-vacancy
$ bundle exec padrino start
```


You should see a message telling you that Padrino has taken the stage, and you should be able to view our created index page by visiting <http://localhost:3000/index.html> in your browser.


You might ask "Why do we use the `bundle exec` command - isn't `padrino start` enough?" The reason for this is that we use bundler to load exactly those Ruby gems that we specified in the Gemfile. I recommend that you use `bundle exec` for all following commands, but to focus on Padrino, I will skip this command on the following parts of the book.


You may have thought it a little odd that we had to manually requests the index.html in the URL when viewing our start page. This is because our app currently has no idea about **routing**. Routing is the process to recognize request URLs and to forward these requests to actions of controllers. With other words: A router is like a like vending machine where you put in money to get a coke. In this case, the machine is the *router* which *routes* your input "Want a coke" to the action "Drop a Coke in the tray".


### First Controller And Routing

Lets add some basic routes for displaying our home, about, and contact-page. How can we do this? With the help of a routing controller. A controller makes data from you app (in our case job offers) available to the view (seeing the details of a job offer). Now let's create a controller in Padrino names page:


```sh
$ padrino-gen controller page
  create  app/controllers/page.rb
  create  app/helpers/page_helper.rb
  create  app/views/page
   apply  tests/rspec
  create  spec/app/controllers/page_controller_spec.rb
```


Lets take a closer look at our page-controller:


```ruby
# app/controller/page.rb

JobVacancy::App.controllers :page do

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
end
```


The controller above defines for our `JobVacancy` the `:page` controller with no specified routes inside the app. Let's change this and define the *about*, *contact*, and *home* actions:


```ruby
# app/controller/page.rb

JobVacancy:.App.controllers :page do
  get :about, :map => '/about' do
    render :erb, 'about'
  end

  get :contact , :map => '/contact' do
    render :erb, 'contact'
  end

  get :home, :map => '/' do
    render :erb, 'home'
  end
end
```


We will go through each line:


- `JobVacancy::App.controller :page` - Define the namespace *page* for our JobVacancy app. Typically, the controller name will also be part of the route.
- `do ... end` - This expression defines a block in Ruby. Think of it as a method without a name, also called anonymous functions, which is passed to another function as an argument.
- `get :about, :map => '/about'` - The HTTP command *get* starts the declaration of the route followed by the *about* action (as a symbol[^symbol]), and is finally mapped to the explicit URL */about*. When you start your server with `bundle exec padrino s` and visit the URL <http://localhost:3000/about>, you can see the rendered output of this request.
- `render :erb, 'about'` - This action tells us that we want to render the *erb* file *about* for the corresponding controller which is `page` in our case. This file is actually located at `app/views/page/about.erb` file. Normally the views are placed under `app/views/<controller-name>/<action-name>.<ending>`. Instead of using an ERB templates, you could also use `:haml`, or another [template engine](https://www.ruby-toolbox.com/categories/template_engines "template engine for Ruby"). You can even completely drop the rendering option and leave the matching completely for Padrino.


[^symbol]: Unlike strings, symbols of the same name are initialized and exist in memory only once during a session of ruby. This makes your programs more efficient.


Call the following command to see all defined routes for your application:


```sh
$ padrino rake routes
=> Executing Rake routes ...

  Application: JobVacancy
  URL                  REQUEST  PATH
  (:page, :about)        GET    /about
  (:page, :contact)      GET    /contact
  (:page, :home)         GET    /
```


### Application Template

Although we are now able to put content (albeit static) on our site, it would be nice to have some sort of basic styling on our web page. First we need to generate a basic template for all pages we want to create:


```erb
<%# app/views/layouts/application.erb %>

<!DOCTYPE html>
<html lang="en-US">
  <head>
    <title>Job Vacancy - find the best jobs</title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```


Let's see what is going on with the `<%= yield %>` line. At first you may ask what does the `<>` symbols mean. They are indicators that you want to execute Ruby code to fetch data that is put into the template. Here, the `yield` command will put the content of the called page, like *about.erb* or *contact.erb*,  into the template.


### CSS Design Using Twitter Bootstrap

The guys at Twitter were kind enough to make their CSS framework [Twitter Bootstrap](https://github.com/twitter/bootstrap/ "Twitter Bootstrap") available for everyone to use.


Padrino itself also provides built-in templates for common tasks done on web app. These [padrino-recipes](https://github.com/padrino/padrino-recipes "Padrino recipes") help you saving time by not reinventing the wheel.  Thanks to [@arthur_chiu](http://twitter.com/#!/arthur_chiu "@arthur_chiu"), we use his [bootstrap-plugin](https://github.com/padrino/padrino-recipes/blob/master/plugins/bootstrap_plugin.rb "bootstrap plugin") by executing:


```sh
$ padrino-gen plugin bootstrap
  apply  https://github.com/padrino/padrino-recipes/raw/master/plugins/...
  create    public/stylesheets/bootstrap.css
  ...
```


Next we need to include the style sheet in our app template for the whole app:


```erb
<%# app/views/layouts/application.erb %>

<!DOCTYPE html>
<html lang="en-US">
  <head>
    <title>Job Vacancy - find the best jobs</title>
    <%= stylesheet_link_tag 'bootstrap', 'bootstrap-theme' %>
    <%= javascript_include_tag 'bootstrap.min', 'jquery', 'jquery-ujs' %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```


The `stylesheet_link_tag` points to the *bootstrap.min.css* in you app *public/stylesheets* directory and will automatically create a link to this stylesheet. The `javascript_include_tag` does the same as `stylesheet_link_tag` for your JavaScript files in the *public/javascripts* directory.


### Using Sprockets to Manage the Asset Pipeline

[Sprockets](https://github.com/sstephenson/sprockets "Sprockets") are a way to manage serving your assets like CSS, and JavaScript compiling all the different files in one summarized file for each type. To take advantage to use a preprocessor to write your assets with [Sass](http://sass-lang.com "Sass"), [CoffeeScript](http://coffeescript.org "CoffeeScript"), or [less](http://lesscss.org "less").


To implement Sprockets in Padrino there the following strategies:


- [rake-pipeline](https://github.com/livingsocial/rake-pipeline "rake-pipeline"): Define filters that transforms directory trees.
- [grunt](http://gruntjs.com "grunt"): Set a task to compile and manage assets in JavaScript.
- [sinatra-assetpack](https://github.com/rstacruz/sinatra-assetpack "sinatra-assetpack"): Let's you define you assets transparently in Sinatra.
- [padrino-sprockets](https://github.com/nightsailer/padrino-sprockets "padrino-sprockets"): Integrate sprockets with Padrino in the Rails way.


We are using the **padrino-sprockets** gem. Let's add it to our Gemfile (don't forget to run `bundle install`):


```ruby
# Gemfile

gem 'padrino-sprockets', :require => ['padrino/sprockets'],
  :git => 'git://github.com/nightsailer/padrino-sprockets.git'
```

Next we need to move all our assets from the public folder in the assets folder:


```sh
$ cd job-vacancy
$ mkdir -p app/assets
$ cd public
$ mv -v fonts images javascripts stylesheets ../app/assets
```


Now we have to register Padrino-Sprockets in this application:


```ruby
# app/app.rb

module JobVacancy
  class App < Padrino::Application
    ...
    register Padrino::Sprockets
    sprockets
    ...
  end
end
```


Next we need create an application.css file and add the following to determine the order of the loaded CSS files in `app/assets/stylesheets/application.css`:


```javascript
/* app/assets/stylesheets/application.css */

/*
 * This is a manifest file that'll automatically include all the stylesheets ...
 * ...
 *
 *= require_self
 *= require bootstrap
 *= require bootstrap-theme
 *= require site
*/
```


First we are loading the `bootstrap` default css, then `bootstrap-theme`, and finally our customized `site` CSS. The `require_self` loads the file itself, to define the order that the files are loaded. This is helpful if you want to check the order of the loaded CSS as a comment above your application without ever have to look into the source of it.


Next let's have a look into our JavaScript file `app/assets/javascript/application.js`:


```javascript
/* app/assets/javascript/application.js */

// This is a manifest file that'll be compiled into including all the files ...
// ...
//
//= require_tree .
```


The interesting thing here is the `require_tree .` option. This option tells Sprockets to include all JavaScript files in the assets folder with no specific order.


Now, we can clean up the include statements in our application template:


```erb
<%# app/views/layouts/application.erb %>

<!DOCTYPE html>
<html lang="en-US">
<head>
  <title>Job Vacancy - find the best jobs</title>
  <%= stylesheet_link_tag '/assets/application' %>
  <%= javascript_include_tag '/assets/application' %>
</head>
```


Now we want to enable compression for our CSS and JavaScript files. For CSS compression Padrino Sprockets is using [YUI compressor](https://github.com/sstephenson/ruby-yui-compressor "YUI compressor") and for JS compression the [Uglifier](https://github.com/lautis/uglifier "Uglifier"). We need to add these these Gems in our `Gemfiles`:


```ruby
# Gemfile
...
gem 'padrino-sprockets', :require => 'padrino/sprockets',
  :git => 'git://github.com/nightsailer/padrino-sprockets.git'
gem 'uglifier', '2.1.1'
gem 'yui-compressor', '0.9.6'
...
```


And finally we need to enable minifying in our production environment:


```ruby
# app/app.rb

module JobVacancy
  class App < Padrino::Application
    ...
    register Padrino::Sprockets
    sprockets :minify => (Padrino.env == :production)
    ...
  end
end
```


### Navigation

Next we want to create the top-navigation for our app. We already implemented the *page* controller with the relevant actions. All we need is to put links to them in a navigation header for our basic layout.


```erb
<%# app/views/layouts/application.erb %>

<!DOCTYPE html>
<html lang="en-US">
  <head>
    <title>Job Vacancy - find the best jobs</title>
    <%= stylesheet_link_tag 'bootstrap', 'bootstrap-theme' %>
    <%= javascript_include_tag 'bootstrap.min', 'jquery', 'jquery-ujs' %>
    <%= stylesheet_link_tag '/stylesheets/site.css' %>
</head>
<body>
  <div class="container">
    <div class="row">
      <div class="span12 offset3">
        <span id="header">Job Vacancy Board</span>
      </div>
      <div class="row">
        <nav id="navigation">
          <div class="span2 offset4">
            <%= link_to 'Home', url(:page, :home) %>
          </div>
          <div class="span2">
            <%= link_to 'About', url(:page, :about) %>
          </div>
          <div class="span2">
            <%= link_to 'Contact', url(:page, :contact) %>
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
```


Explanation of the new parts:


- [link_to](http://www.padrinorb.com/api/Padrino/Helpers/AssetTagHelpers.html#link_to-instance_method) - Is a helper for creating links. The first argument is the name for the link and the second is for the URL (href) to which the link points to.
- [url](http://www.padrinorb.com/api/Padrino/Routing/InstanceMethods.html#url-instance_method) (or `url_for`) - This helper return the link which can be used as the second parameter for the `link_to` function. It specifies the <:controller>, <:action> which will be executed. You can use in your helper in your whole app to create clean and encapsulated URLs.


Now that the we provide links to other parts of the app, lets add some sugar-candy styling:


```css
/* app/assets/stylesheets/site.css */

body {
  font: 18.5px Palatino, 'Palatino Linotype', Helvetica, Arial, Verdana,
    sans-serif;
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
```


I will not explain anything at this point about CSS. If you still don't know how to use it, please go through [w3c school css](http://www.w3schools.com/css/default.asp "w3c school css") tutorial. Since we are using the asset pipeline, we don't need to register our new CSS file in `views/application.erb` - now you will understand why we did this.


### Writing Tests

Our site does not list static entries of job offers that you write, but other users will be allowed to post job offers from the Internet to our site. We need to add this behavior to our site. To be on the sure side, we will implement this behavior by writing tests first, then the code. We use the [RSpec](http://rspec.info/ "RSpec") testing framework for this.


Remember when we created the *page-controller* with `padrino-gen controller page`? Thereby, Padrino created a corresponding spec file `spec/app/controller/page_controller_spec.rb` which has the following content:


```ruby
# spec/app/controller/page_controller_spec.rb
require 'spec_helper'

RSpec.describe "/page" do
  pending "add some examples to #{__FILE__}" do
    before do
      get "/page"
    end

    it "returns hello world" do
      expect(last_response.body).to eq "Hello World"
    end
  end
end
```


Let's update that file and write some basic tests to make sure that everything is working as expected. Replace the specs in the file with the following code:


```ruby
# spec/app/controller/page_controller_spec.rb

require 'spec_helper'

RSpec.describe "PageController" do
  describe "GET #about" do

    it "renders the :about view" do
      get '/about'
      expect(last_response).to be_ok
    end
  end

  describe "GET #contact" do
    it "renders the :contact view" do
      get '/contact'
      expect(last_response).to be_ok
    end
  end

  describe "GET #home" do
    it "renders :home view" do
      get '/'
      expect(last_response).to be_ok
    end
  end
end
```


Let's explain the interesting parts:


- `spec_helper` - Is a file to load commonly used functions to setup the tests.
- `describe block` - This block describes the context for our tests. Think of it as way to group related tests.
- `get ...` - This command executes a HTTP GET to the provided address.
- `last_response` - The response object returns the header and body of the HTTP request.


Now let's run the tests with `rspec spec/app/controllers/page_controller_spec.rb` and see what's going on:


```sh
...

Finished in 0.21769 seconds
3 examples, 0 failures
```


Cool, all tests passed! We didn't exactly use behavior-driven development until now[^note].

[^note]: Note: It's possible your tests did not pass due to a Padrino error in which a comma ( , ) was omitted during the initial app generation that looks something like 'NameError: undefined local variable' check your `spec_helper.rb` file and make sure the following matches: `def app(app = nil, &blk)`, please  note the comma right after nil.


\begin{aside}
\heading{Red-Green Cycle}

In behavior-driven development (BDD) it is important to write a failing test first and then the code that satisfies the test. The red-green cycle represents the colors that you will see when executing these test: Red first, and then beautiful green. But once your code passes the tests, take yet a little more time to refactor your code. This little mind shift helps you a lot to think more about the problem and how to solve it. The test suite is a nice by product too.

\end{aside}

