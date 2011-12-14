### Layout for our app ###

- twitter bootstrap
- sass
- clue it all together


### Writing our first tests with RSpec###

-
- n
- n


### Bringing in dynamic with Padrino ###

The first step to enlightenment is to understand the **Model View Architecture** (MVC) - the basic design
of Padrino application. What does that means? The idea of MVC is to separate code into independent
parts to make it easier to the behavior of legacy code without having to change unrelated code.

- `Model` - abstraction of data model, this will bring you things like a user-profile or a job offer
  to the real world (**data**)
- `View` - displays the information from the model and gives the User a interface to interact with
  (**browser**)
- `Controller` - handles the interaction between the model and the view like a brain (**Server**). In our app we
  have methods to post and see job-offers

Each part of the MVC interacts with each other but in loose coupled way. A job-offer (`model`) does
not need to know how to display a job. The view does not need to know how to interact with the
database - it gets information and displays them. The controller is not responsible for the
look-and-feel and models - it gets commands to handle the views and the according models for the
views.

For those readers who wants to want a more detailed explanation of the MVC pattern check TBD


