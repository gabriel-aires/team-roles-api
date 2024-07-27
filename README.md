# Team Roles API

### Setup

After cloning this project, please create an `.env` file at the root of the repository containing the following contents:

```
POSTGRES_PASSWORD=postgres
POSTGRES_USER=postgres
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
RAILS_MASTER_KEY=219813a7ac496afe027a275a146abc60
RAILS_ENV=production
TEAM_SERVICE_URI=https://cgjresszgg.execute-api.eu-west-1.amazonaws.com

```

*All values are visible, since this is not a real production app*

Run `docker compose up -d` to start the Rails and Postgres containers

### Run Tests

To execute the RSpec tests, open a new shell with `docker compose run web bash` and execute the following commands inside the terminal:

```
RAILS_ENV=test ./bin/rails db:test:prepare
RAILS_ENV=test bundle exec rspec -f d
```

### Available Endpoints

#### Base URI
http://0.0.0.0:3000

#### GET /roles
Returns all roles

#### GET /roles/:id
Returns a role by id. Parameter: `id` (uuid)

#### POST /roles
Creates a role. Parameters: `name` (string), `is_default` (boolean optional, assumed false)

#### GET /memberships
Returns all memberships

#### GET /memberships?role_id=:role_id
Returns all memberships filtered by role_id. Parameter: `role_id` (uuid)

#### GET /memberships/:id
Returns a membership by id. Parameter: `id` (uuid)

#### GET /memberships/lookup?user_id=:user_id&team_id=:team_id
Returns a membership by user_id and team_id. Parameters: `user_id` (uuid), `team_id` (uuid)

#### POST /memberships
Creates a membership. Parameters: `user_id` (uuid), `team_id` (uuid), `role_id` (uuid optional, assumed developer id)

### Solution Overview

This API relies on the teams service to gather data about users and teams. I assumed the teams service would keep user data in sync with the users service via some background job. This simplifies the approach, as we don't need to make additional HTTP requests to the users service for validation.

The first step of the solution involved the creation of models for roles and memberships. Each role has a name, a default flag and many associated memberships. A membership is represented by a role, a user id and a team id. After adding basic validation to the models, I created custom methods to ensure the existence of a single default role, update all roles after creating a new default, and setting a default role for a membership if no explicit role was passed.

I adjusted the migrations in order to make the id columns UUIDs, provide defaults, prevent nulls, add the required indexes, etc.

After that, I created an error handler concern which I included in the base controller class. This gave me automatic error responses for common ActiveRecord exceptions.

Then I proceeded to implement the roles controller using index, show and create methods that would be called by the resourceful routes.

Before implementing the memberships controller, I created some custom exceptions and the teams service client that would be responsible for retrieving the users associated to a team. For that purpose, I combined the data for the team leader and the team members. Any connection error or null response body would raise an App::ClientError exception that could be rescued later by a service.

I then proceeded to implement the index and show methods for the memberships controller. The index route has an optional parameter in order to enable filtering memberships by role id.

The last methods would involve additional logic that should not be placed in the controller, so I created a base service class in order to accept request parameters, manipulate an array of possible validation errors and return success or error responses in a convenient way.

In order to lookup a membership by user id and team id, I created a custom 'lookup' method that used a service object to handle validations and return a response.

The create method also required a service for validations and wrapping the functionality provided by the teams service client. Basically, an error response would be sent in case of missing parameters, role not found (via exception propagation), team not found or user not associated with the given team. Otherwise, membership would be created with the specified role or the default one, should the role_id parameter be absent.

Finally, I used the `active_model_serializers` gem to customize the JSON output of the API. For consuming the teams API, I used the `httparty` gem. For the tests, I have used `rspec` and `webmock`. The app configuration was handled by `dotenv-rails`.

### Possible improvements

- Add a sidekiq job to sync membership data with the teams service in order to handle user/team deletions
- Accept camelCase parameters and transform the response accordingly
- Add pagination to lists using a meta field or the Link header
- Add unit tests for the service classes (couldn't do it because of time constraints)
- In the case of the teams and users services, the response code should be 404 for records not found
- Additionaly, those services should send proper error responses instead of null.