## User Profile

To update a use profile we need and `edit` and `update` action. Let's beginning with writing tests for the `edit`
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


The interesting part above is the `.twice` call. We need to use this because when want to edit a user we need to load this
profile and load it again if we are having an input error.


As you can see in the test above we are using namespaced routes an alias for the action.


{: lang="ruby" }
    # app/controllers/user.rb

    # using namespaced route alias
    get :edit, :map => '/users/:id/edit' do
      @user = User.find_by_id(params[:id])
      unless @user
        redirect('/')
      end
      render 'users/edit'
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


Making this test pass took me a while. The HTTP spec only understands GET and POST in a the `<form>`'s method attribute.
How can we solve this? We need to use a hidden form with the form input called `_method` with a `put` value. You will
see this right after the controller code.


{: lang="ruby" }
    # app/controllers/users.rb
    ...
    put :update, :map => '/users/:id' do
      @user = User.find_by_id(params[:id])

      unless @user
        flash[:error] = "User is not registered in our platform."
        render 'users/edit'
      end

      if @user.update_attributes(params[:user])
        flash[:notice] = "You have updated your profile."
        redirect('/')
      else
        flash[:error] = "Your profile was not updated."
        render 'users/edit'
      end
    end


And finally the edit form:


{: lang="erb" }
    # app/views/users/edit.erb

    <% form_for(@user, "/users/#{@user.id}") do |f| %>
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


If you now open the browser at http://jobvacancy.de:3000/users/37/edit  you can edit the user even if you are not logged
into the application. Ups, this is huge security issue.


