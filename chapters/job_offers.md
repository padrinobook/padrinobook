## Job Offers


### Refine the model


Since we are now basically done with the user management, it's time to model our `JobOffer` model.

Specs first:


```ruby
# spec/app/models/job_offer_spec.rb

require 'spec_helper'

RSpec.describe JobOffer do
  let(:job_offer) { build_stubbed(:job_offer) }
  let(:wrong_job_offer) { JobOffer.new }

  it 'can be created' do
    expect(job_offer).not_to be_nil
  end

  it 'must have a title' do
    wrong_job_offer.title = ''
    wrong_job_offer.description = 'hallo'

    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a description' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = ''

    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a location' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a contact' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = ''
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a time_start' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = 'Test'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must have a time_end' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = 'Test'
    wrong_job_offer.time_start = '2019/01/16'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'time_start cannot be bigger then time_end' do
    wrong_job_offer.title = 'Hallo'
    wrong_job_offer.description = 'hallo'
    wrong_job_offer.location = 'Berlin'
    wrong_job_offer.contact = 'Test'
    wrong_job_offer.time_start = '2019/01/17'
    wrong_job_offer.time_end = '2019/01/16'
    expect(wrong_job_offer.valid?).to be_falsey
  end

  it 'must be related to a user' do
    expect(job_offer.user).to be_nil
    job_offer.build_user({id: 100})
    expect(job_offer.user.id).to eq 100
  end
end
```


The special thing about this spec is that we have to ensure that the `time_start` value is not lower then the `time_end` value.
We will do this with the [validates method](https://api.rubyonrails.org/v5.2.2/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates "validates method") to have a custom validation:


```ruby
# app/models/job_offer.rb
class JobOffer < ActiveRecord::Base
  belongs_to :user

  validates :title,
    :description,
    :location,
    :contact,
    :time_start,
    :time_end,
    presence: true

  validate :dates

  private
  def dates
    if time_start && time_end && time_start > time_end
      errors.add(:time_end, 'must be after time_start')
    end
  end
end
```


The `errors.add` method will add an error to the model to the `:time_end` property with a custom
message.


### Create the controller

```sh
padrino-gen controller JobOffers get:index get:new post:create get:mylist \
                                 get:edit put:update get:job delete:job \
                                 --no-helper
      create  app/controllers/job_offers.rb
      create  app/views/job_offers
       apply  tests/rspec
      create  spec/app/controllers/job_offers_controller_spec.rb
```


Let's start by writing the specs for the four actions: `get:jobs`, `get:new`, `post:create`, and `get:mylist`:


```ruby
# spec/app/controllers/job_offers_controller_spec.rb

require 'spec_helper'

RSpec.describe "/jobs" do
  let(:user) { build_stubbed(:user) }

  describe "GET /jobs" do
    it "render the :jobs view" do
      get "/jobs"
      expect(last_response).to be_ok
    end
  end

  describe "GET /jobs/new" do
    context "user is not logged in" do
      it 'redirects to login' do
        expect(User).to receive(:find_by_id).and_return(nil)
        get "/jobs/new"
        expect(last_response).to be_redirect
        expect(last_response.header['Location']).to include('/login')
      end
    end

    context "user is logged in" do
      it 'renders the :new routes' do
        expect(User).to receive(:find_by_id).and_return(user)
        get "/jobs/new"
        expect(last_response).to be_ok
      end
    end
  end

  describe "POST /jobs/create" do
    context "user is not logged in" do
      it 'redirects to login' do
        expect(User).to receive(:find_by_id).and_return(nil)
        post '/jobs/create'
        expect(last_response).to be_redirect
        expect(last_response.header['Location']).to include('/login')
      end
    end

    context "user is logged in" do
      let(:user) { build_stubbed(:user) }
      let(:job) { build_stubbed(:job_offer) }

      it 'renders the post page if form is invalid' do
        expect(User).to receive(:find_by_id).and_return(user)
        expect(JobOffer).to receive(:new).and_return(job)
        expect(job).to receive(:valid?).and_return(false)

        post '/jobs/create'
        expect(last_response).to be_ok
      end

      it 'list page if job offer is saved' do
        expect(User).to receive(:find_by_id).and_return(user)
        expect(JobOffer).to receive(:new).and_return(job)
        expect(job).to receive(:valid?).and_return(true)
        expect(job).to receive(:write_attribute)
          .with(:user_id, user.id)
          .and_return(true)

        expect(job).to receive(:save).and_return(true)

        post '/jobs/create', job_offer: job
        expect(last_response).to be_redirect
        expect(last_response.body).to eq "Job is saved"
      end
    end
  end

  describe "GET /jobs/mylist" do
    context "user is not logged in" do
      it 'redirects to login' do
        expect(User).to receive(:find_by_id).and_return(nil)
        get '/jobs/mylist'
        expect(last_response).to be_redirect
        expect(last_response.header['Location']).to include('/login')
      end
    end

    context "user is logged in" do
      it 'renders list of users job offers' do
        expect(User).to receive(:find_by_id).and_return(user)
        get "/jobs/mylist"
        expect(last_response).to be_ok
      end
    end
  end
end
```


And the implementation:


```ruby
# app/controllers/job_offers.rb

JobVacancy::App.controllers :job_offers do
  before :new, :create, :mylist do
    if !signed_in?
      redirect('/login')
    end
  end

  get :index, :map => '/jobs' do
    @job_offers = JobOffer.all
    render 'jobs', :locals => { job_offers: @job_offers }
  end

  get :new, :map => '/jobs/new' do
    @job_offer = JobOffer.new
    render 'new'
  end

  post :create, :map => '/jobs/create' do
    @job_offer = JobOffer.new(params[:job_offer])

    if @job_offer && @job_offer.valid?
      @job_offer.write_attribute(:user_id, current_user.id)
      @job_offer.save
      redirect url(:job_offers, :mylist), flash[:notice] = "Job is saved"
    end

    render 'new'
  end

  get :mylist, :map => '/jobs/mylist' do
    @job_offers = JobOffer.where("user_id = ?", current_user.id)
    render 'mylist', :locals => { job_offers: @job_offers }
  end
end
```


The interesting part is the `JobOffer.where` method where we are using [Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html#retrieving-objects-from-the-database "Active Record Query Interface") to get to the desired data as an array from the database.


Time to add the views. Let's start with `get:index`:


```erb
<%# app/views/job_offers/jobs.erb %>

<h1>Jobs</h1>

<h3>Overview of latest released jobs</h3>

<br>

<div class="content">
  <table class="table is-fullwidth">
    <thead>
      <tr>
        <th>Title</th>
        <th>Start date</th>
      </tr>
    </thead>
    <tbody>
      <% if @job_offers %>
        <% @job_offers.each do |job_offer| %>
          <tr>
            <td><%= link_to job_offer.title, \
              url(:job_offers, :job, id: job_offer.id ) %></td>
            <td><%= job_offer.time_start %></td>
          </tr>
        <% end  %>
      <% else %>
        There are no open job offerings
      <% end %>
    </tbody>
  </table>
</div>
```


And the view for `get:new`:


```erb
<%# app/views/job_offers/new.erb %>

<h1>Create a new job offer</h1>

<% form_for(@job_offer, url(:job_offers, :create)) do |f| %>
  <div class="field">
    <%= f.label :title, :class => 'label' %>
    <div class="control">
      <%= f.text_field :title, :class => 'input' %>
    </div>
    <%= error_message_on :job_offer, :title, \
      :class => "has-background-danger", :prepend => "The title" %>
  </div>

  <div class="field">
    <%= f.label :description, :class => 'label' %>
    <div class="control">
      <%= f.text_area :description, :class => 'textarea' %>
    </div>
    <%= error_message_on :job_offer, :description, \
      :class => "has-background-danger", :prepend => "The description" %>
  </div>

  <div class="field">
    <%= f.label :location, :class => 'label' %>
    <div class="control">
      <%= f.text_area :location, :class => 'input' %>
    </div>
    <%= error_message_on :job_offer, :location, \
      :class => "has-background-danger", :prepend => "The location" %>
  </div>

  <div class="field">
    <%= f.label :contact, :class => 'label' %>
    <div class="control">
      <%= f.text_area :contact, :class => 'input' %>
    </div>
    <%= error_message_on :job_offer, :contact, \
      :class => "has-background-danger", :prepend => "The contact" %>
  </div>

  <div class="field">
    <%= f.label :time_start, :class => 'label' %>
    <div class="control">
      <%= f.date_field :time_start, :class => 'input' %>
    </div>
    <%= error_message_on :job_offer, :time_start, \
      :class => "has-background-danger", :prepend => "The time_start" %>
  </div>

  <div class="field">
    <%= f.label :time_end, :class => 'label' %>
    <div class="control">
      <%= f.date_field :time_end, :class => 'input' %>
    </div>
    <%= error_message_on :job_offer, :time_end, \
      :class => "has-background-danger", :prepend => "The time_end" %>
  </div>

  <div class="field">
    <div class="control">
      <%= f.submit "Post new job", :class => "button is-large is-link" %>
    </div>
  </div>
<% end %>
```


In order to get a proper start and end date for the job-offer we are using the [date_field](https://www.rubydoc.info/github/padrino/padrino-framework/Padrino/Helpers/FormBuilder/AbstractFormBuilder#date_field-instance_method "date_field") element.


And the view for `get:mylist`:


```erb
<%# app/views/job_offers/mylist.erb %>

<h1>My Jobs</h1>

<%= link_to 'Create a new job', url(:job_offers, :new), \
  :class => 'button is-link' %>

<table class="table is-fullwidth">
  <thead>
    <tr>
      <th>Position</th>
      <th>Title</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <% @job_offers.each do |job_offer| %>
      <tr>
        <td><%= job_offer.id %></td>
        <td><%= job_offer.title %></td>
        <td><%= link_to 'Edit', url(:job_offers, :edit, id: job_offer.id) %> |
          <%= link_to 'Delete', url(:job_offers, :job, id: job_offer.id, \
            :authenticity_token => session[:csrf]), :method => :delete %>
        </td>
      </tr>
    <% end  %>
  </tbody>
</table>
```


Let's finish our specs by writing them for the last four remaining actions: `get:edit`, `put:update`, `get:job`
and `delete:job`:


```ruby
# spec/app/controllers/job_offers_controller_spec.rb

require 'spec_helper'

RSpec.describe "/jobs" do
  let(:user) { build_stubbed(:user) }

  ...

  describe "GET /jobs/myjobs/:id/edit" do
    let(:job) { build_stubbed(:job_offer) }
    let(:user_second) { build_stubbed(:user) }

    it 'redirects to /login if user is not signed in' do
      expect(User).to receive(:find_by_id).and_return(nil)
      get '/jobs/myjobs/1/edit'
      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/login')
    end

    it 'redirects to /jobs/mylist user tries to edit a job from another user' do
      expect(User).to receive(:find_by_id).and_return(user)
      job.user = user_second
      expect(JobOffer).to receive(:find_by_id)
        .with("#{job.id}")
        .and_return(job)

      get "/jobs/myjobs/#{job.id}/edit"

      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/jobs/mylist')
    end

    it 'renders edit view if signed in user edits his own job' do
      expect(User).to receive(:find_by_id).and_return(user)
      job.user = user
      expect(JobOffer).to receive(:find_by_id)
        .with("#{job.id}")
        .and_return(job)

      get "/jobs/myjobs/#{job.id}/edit"

      expect(last_response).to be_ok
    end
  end

  describe "PUT /jobs/myjobs/:id" do
    it 'try to edit non existing job' do
      updated_job_offer = ['']
      expect(JobOffer).to receive(:find_by_id)
        .with('1000')
        .and_return(nil)

      put "/jobs/myjobs/1000", job_offer: updated_job_offer

      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/jobs/mylist')
    end

    it 'job_offer changes are not valid' do
      @existing_job_offer = double(JobOffer, id: 1, title: 'old')
      updated_job_offer = ['']
      expect(JobOffer).to receive(:find_by_id)
        .with('1')
        .and_return(@existing_job_offer)
      expect(@existing_job_offer).to receive(:update)
        .with(updated_job_offer)
        .and_return(false)

      put "/jobs/myjobs/1", job_offer: updated_job_offer

      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/jobs/myjobs/1/edit')
      expect(last_response.body).to eq 'Job offer was not updated.'
    end

    it 'job_offer changes are valid' do
      @existing_job_offer = double(JobOffer, id: 1, title: 'old')
      updated_job_offer = ['']
      expect(JobOffer).to receive(:find_by_id)
        .with('1')
        .and_return(@existing_job_offer)
      expect(@existing_job_offer).to receive(:update)
        .with(updated_job_offer)
        .and_return(true)

      put "/jobs/myjobs/1", job_offer: updated_job_offer

      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/jobs/mylist')
      expect(last_response.body).to eq 'Job offer was updated.'
    end

    it 'job_offer changes DB error' do
      @existing_job_offer = double(JobOffer, id: 1, title: 'old')
      updated_job_offer = ['']
      expect(JobOffer).to receive(:find_by_id)
        .with('1')
        .and_return(@existing_job_offer)
      expect(@existing_job_offer).to receive(:update)
        .with(updated_job_offer)
        .and_raise(ActiveRecord::RecordInvalid)

      put "/jobs/myjobs/1", job_offer: updated_job_offer

      expect(last_response).to be_redirect
      expect(last_response.header['Location']).to include('/jobs/myjobs/1/edit')
      expect(last_response.body).to eq 'Job offer changes were not valid'
    end
  end

  describe "GET /job/:id" do
    let(:job_offer) { build_stubbed(:job_offer) }

    context "Job exists" do
      it 'renders the page' do
        expect(JobOffer).to receive(:find_by_id)
          .with("#{job_offer.id}")
          .and_return(job_offer)

        get "/jobs/#{job_offer.id}"
        expect(last_response).to be_ok
        expect(last_response.body).to include("#{job_offer.title}")
      end
    end

    context "Job does not exists" do
      it 'renders the job overview page' do
        expect(JobOffer).to receive(:find_by_id)
          .with("#{job_offer.id}")
          .and_return(nil)

        get "/jobs/#{job_offer.id}"
        expect(last_response).to be_ok
        expect(last_response.body).to include('Overview of latest jobs')
      end
    end
  end

  describe "DELETE /job/:id" do
    let(:job_offer) { build_stubbed(:job_offer) }
    let(:user_second) { build_stubbed(:user) }

    context "Job exists" do
      context "User is logged" do
        it 'deletes his own job' do
          expect(User).to receive(:find_by_id).and_return(user)
          job_offer.user = user
          expect(JobOffer).to receive(:find_by_id)
            .with("#{job_offer.id}")
            .and_return(job_offer)

          expect(job_offer).to receive(:delete)

          delete "/jobs/#{job_offer.id}"
          expect(last_response).to be_redirect
        end

        it 'redirects to /jobs/mylist if user deletes job of another user' do
          expect(User).to receive(:find_by_id).and_return(user)
          job_offer.user = user_second
          expect(JobOffer).to receive(:find_by_id)
            .with("#{job_offer.id}")
            .and_return(job_offer)
          expect(job_offer).to_not receive(:delete)

          delete "/jobs/#{job_offer.id}"
          expect(last_response).to be_redirect
        end
      end

      context "User is not logged in" do
        it 'redirects to /login' do
          expect(User).to receive(:find_by_id).and_return(nil)
          delete "/jobs/#{job_offer.id}"
          expect(last_response).to be_redirect
          expect(last_response.header['Location']).to include('/login')
        end
      end
    end

    context "Job does not exists" do
      context "User logged in" do
        it 'redirects to /jobs/mylist' do
          expect(User).to receive(:find_by_id).and_return(user)
          expect(JobOffer).to receive(:find_by_id)
            .with("#{job_offer.id}")
            .and_return(nil)

          expect(job_offer).to_not receive(:delete)

          delete "/jobs/#{job_offer.id}"
          expect(last_response).to be_redirect
        end
      end
    end
  end
end
```


The new thing in the spec is `.and_raise(ActiveRecord::RecordInvalid)` - as the time says you can expect that certain
exceptions are raised.


Now to the implementation:


```ruby
# app/controllers/job_offers.rb

JobVacancy::App.controllers :job_offers do
  before :new, :create, :mylist, :edit do
    if !signed_in?
      redirect('/login')
    end
  end
  ...

  get :edit, :map => '/jobs/myjobs/:id/edit' do
    @job_offer = JobOffer.find_by_id(params[:id])

    if @job_offer && @job_offer.user.id != current_user.id
      redirect url(:job_offers, :mylist)
    end

    render 'edit', :locals => { job_offer: @job_offer }
  end

  put :update, :map => '/jobs/myjobs/:id' do
    @job_offer = JobOffer.find_by_id(params[:id])

    if @job_offer == nil
      redirect url(:job_offers, :mylist)
    end

    begin
      if @job_offer.update(params[:job_offer])
        redirect url(:job_offers, :mylist), \
          flash[:notice] = 'Job offer was updated.'
      end
    rescue ActiveRecord::RecordInvalid
      redirect url(:job_offers, :edit, id: params[:id]), \
        flash[:error] = 'Job offer changes were not valid'
    end

    redirect url(:job_offers, :edit, id: params[:id]), \
      flash[:error] = 'Job offer was not updated.'
  end

  get :job, :map => '/jobs/:id' do
    @job_offer = JobOffer.find_by_id(params[:id])

    if @job_offer
      render 'job', :local => { job_offer: @job_offer }
    else
      render 'jobs'
    end
  end

  delete :job, :map => '/jobs/:id' do
    if !signed_in?
      redirect('/login')
    end

    @job_offer = JobOffer.find_by_id(params[:id])

    if @job_offer && current_user && @job_offer.user.id == current_user.id
      @job_offer.delete
    end

    redirect url(:job_offers, :mylist)
  end
end
```


As you can see in line ... we use the [begin/rescure block](http://rubylearning.com/satishtalim/ruby_exceptions.html "begin/rescure block") to catch
exceptions.


Now let's add the view for `get:edit`:


```erb
<%# app/views/job_offers/edit.erb %>

<h2>Edit your job</h2>

<br>
<% form_for @job_offer, url(:job_offers, :update, id: @job_offer.id), \
    method: :put do |f| %>
  <div class="field">
    <%= f.label :title, :class => 'label' %>
    <div class="control">
      <%= f.text_field :title, :class => 'input' %>
    </div>
    <%= error_message_on job_offer, :title, \
    :class => "has-background-danger", :prepend => "The title" %>
  </div>

  <div class="field">
    <%= f.label :description, :class => 'label' %>
    <div class="control">
      <%= f.text_area :description, :class => 'textarea' %>
    </div>
    <%= error_message_on job_offer, :description, \
      :class => "has-background-danger", :prepend => "The description" %>
  </div>

  <div class="field">
    <%= f.label :location, :class => 'label' %>
    <div class="control">
      <%= f.text_area :location, :class => 'input' %>
    </div>
    <%= error_message_on job_offer, :location, \
      :class => "has-background-danger", :prepend => "The location" %>
  </div>

  <div class="field">
    <%= f.label :contact, :class => 'label' %>
    <div class="control">
      <%= f.text_area :contact, :class => 'input' %>
    </div>
    <%= error_message_on job_offer, :contact, \
      :class => "has-background-danger", :prepend => "The contact" %>
  </div>

  <div class="field">
    <%= f.label :time_start, :class => 'label' %>
    <div class="control">
      <%= f.date_field :time_start, :class => 'input' %>
    </div>
    <%= error_message_on job_offer, :time_start, \
      :class => "has-background-danger", :prepend => "The time_start" %>
  </div>

  <div class="field">
    <%= f.label :time_end, :class => 'label' %>
    <div class="control">
      <%= f.date_field :time_end, :class => 'input' %>
    </div>
    <%= error_message_on job_offer, :time_end, \
    :class => "has-background-danger", :prepend => "The time_end" %>
  </div>

  <div class="field">
    <div class="control">
      <%= f.submit "Update job", :class => "button is-large is-link" %>
    </div>
  </div>
<% end %>
```


And the last view `get:job` has two views:


```erb
<%# app/views/job_offers/job.erb %>

<h1><%= @job_offer.title %></h1>

<div class="content">
  <%= @job_offer.description %>
</div>

<%= link_to 'Get to job overview', url(:job_offers, :index), \
  :class => 'button is-link' %>
```

and:


```erb
<%# app/views/job_offers/jobs.erb %>

<h1>Jobs</h1>

<h3>Overview of latest jobs</h3>

<br>

<div class="content">
  <table class="table is-fullwidth">
    <thead>
      <tr>
        <th>Title</th>
        <th>Start date</th>
      </tr>
    </thead>
    <tbody>
      <% if @job_offers %>
        <% @job_offers.each do |job_offer| %>
          <tr>
            <td><%= link_to job_offer.title, \
              url(:job_offers, :job, id: job_offer.id ) %></td>
            <td><%= job_offer.time_start %></td>
          </tr>
        <% end  %>
      <% else %>
        There are no open job offerings
      <% end %>
    </tbody>
  </table>
</div>
```


Next we want to give the logged in user the possibily to view all the jobs, a link edit a the job and change our default
view to display the all job offer.

Let's start by adding the correct links:


```erb
<%# app/views/application.erb %>

...
<li>
  <%= link_to 'New Job', url(:job_offers, :new) %>
</li>
<li>
  <%= link_to 'My Jobs', url(:job_offers, :mylist) %>
</li>
<li>
  <% if session[:current_user] %>
    <%= link_to 'Edit Profile', url(:users, :edit, id: session[:current_user]) %>
<% end %>
</li>
...
```


And display the latest job on the start page, we just add a redirect to `/jobs`:


```ruby
# app/controllers/pages.rb

JobVacancy::App.controllers :pages do
  get :home, :map => "/" do
    redirect url(:job_offers, :index)
  end
  ...
end
```


I'll leave it to you to write the specs this class.


## Enable markdown rendering job description


[Markdown](https://en.wikipedia.org/wiki/Markdown "Markdown") is a markup language which can be used to create HTML out
of simple constructs.


```
# My Job Offers


- [Best Padrino Job in Berlin](http://job-vacancy.com/)

**These are my best** *offers*
```


will be translated into the following HTML version:


```html
<h1>My Job Offers</h1>
<ul>
  <li><a href="http://job-vacancy.com/">Best Padrino Job in Berlin</a></li>
</ul>
<p><strong>These are my best</strong> <em>offers</em></p>
```


Let's add the `enable_markdown` property to our `JobOffer` model and set this value to `false` as a default value:


```sh
$ padrino-gen migration AddEnableMarkdownToJobOffers enable_markdown:boolean
   apply  orms/activerecord
  create  db/migrate/008_add_enable_markdown_to_job_offers.rb
```


Here is the migration:


```ruby
# db/migrate/008_add_enable_markdown_to_job_offers.rb

class AddEnableMarkdownToJobOffers < ActiveRecord::Migration[5.1]
  def self.up
    change_table :job_offers do |t|
      t.boolean :enable_markdown, default: false
    end
  end

  def self.down
    change_table :job_offers do |t|
      t.remove :enable_markdown
    end
  end
end
```


Run the migration. Now add the following snippets in the `new.erb` and `edit.erb` template:


```erb
<div class="field">
  <label class="checkbox">
    <%= f.check_box :enable_markdown, :class => 'checkbox' %> \
      Enable Markdown rendering
  </label>
</div>
```


In order to use the markdown rendering we need a suitable tool for it. We use the [redcarped gem](https://github.com/vmg/redcarpet "redcarped gem") for this job. Let's add this to our `Gemfile`:


```ruby
gem 'redcarpet', '3.4.0'
```


and run `bundle install`. Let's create the specs for our new helper:


```ruby
require 'spec_helper'

RSpec.describe JobVacancy::App::MarkdownHelper do
  let(:user) { User.new }
  let(:markdown_helper) { Class.new.extend JobVacancy::App::MarkdownHelper}

  subject { markdown_helper }

  describe "#markdown" do
    it 'renders html' do
      expected_result = "<h1>Hallo</h1>\n"
      text_to_render = "# Hallo"
      expect(subject.markdown(text_to_render)).to eq expected_result
    end
  end
end
```


And the implementation:


```ruby
# app/helpers/markdown_helper.rb

module JobVacancy
  class App
    module MarkdownHelper
      def markdown(text)
        options = {
          filter_html:     true,
          hard_wrap:       true,
          link_attributes: { rel: 'nofollow', target: "_blank" },
          space_after_headers: false,
          fenced_code_blocks: true
        }

        extensions = {
          autolink:           true,
          superscript:        true,
          disable_indented_code_blocks: true
        }

        renderer = Redcarpet::Render::HTML.new(options)
        markdown = Redcarpet::Markdown.new(renderer, extensions)

        markdown.render(text).html_safe
      end
    end

    helpers MarkdownHelper
  end
end
```


And make use of the new helper method:


```erb
<%# app/views/job_offers/job.erb %>

<h1><%= @job_offer.title %></h1>

<div class="content">
  <% if @job_offer.enable_markdown %>
    <%= markdown(@job_offer.description) %>
  <% else %>
    <%= @job_offer.description %>
  <% end %>
</div>

<%= link_to 'Get to job overview', url(:job_offers, :index), \
  :class => 'button is-link' %>
```


## Add the is_published option

When a user creates a new job offer, we don't want that the currently written job is automatically visible by all users.
Let's add a `is_published` property:


```sh
$ padrino-gen migration AddIsPublishedToJobOffers is_published:boolean
   apply  orms/activerecord
  create  db/migrate/009_add_is_published_to_job_offers.rb
```


after that, please change the value in the migration from `:joboffers` to `:job_offers` and add the `default: false` property.
Now run the migration.


Now adjust the `app/views/job_offers/edit.erb` and `app/views/job_offers/new.erb` with:


```erb
<div class="field">
  <label class="checkbox">
    <%= f.check_box :is_published, :class => 'checkbox' %>
  </label>
</div>
```


Until now, the `get :index` action grabs all available jobs. But we only need the ones which has the `is_published`
value set to true. We can do that with `JobOffer.where("is_published = ?", true)`. You don't need to adjust the test,
because we only test if the page can be rendered (even if there are jobs or no jobs).


## Attachment

