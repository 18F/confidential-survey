[![Code Climate](https://codeclimate.com/github/18F/confidential-survey/badges/gpa.svg)](https://codeclimate.com/github/18F/confidential-survey) [![Test Coverage](https://codeclimate.com/github/18F/confidential-survey/badges/coverage.svg)](https://codeclimate.com/github/18F/confidential-survey/coverage) [![Dependency Status](https://gemnasium.com/18F/confidential-survey.svg)](https://gemnasium.com/18F/confidential-survey) [![security](https://hakiri.io/github/18F/confidential-survey/develop.svg)](https://hakiri.io/github/18F/confidential-survey/develop) [![Build Status](https://circleci.com/gh/18f/confidential-survey.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/18f/confidential-survey.svg?style=shield&circle-token=:circle-token)

# Confidential Survey (v 0.2.1)

This is an application for gathering responses from confidential
surveys in a way that doesn't result in a large table of sensitive
records.

The basic idea is to not store individual form responses as records
but instead only use the survey response just to increment the
appropriate counters. This allows us to derive the statistics we want
to ultimately measure without assembling a large database of private
responses. This principle of collecting only the minimum amount of
information is also known as
[Datensparsamkeit](http://martinfowler.com/bliki/Datensparsamkeit.html),
which is just a cool word to say.

![Survey Data Flow](doc/confidential-survey-data-flow.png)

So, if we had a survey on ice cream and we wanted to ask employees:
- Do you like ice cream? (Yes/No/Prefer Not To Answer)
- What flavors do you like? (Chocolate/Vanilla/...)
- What toppings do you want on your sundae? (Sprinkles/Hot Fudge/..)
- What is your favorite brand? (Fill in the Blank)

And so on, we could classify the types of questions here among several
distinct types to start with:

- **exclusive** allow only one choice from the available options
- **exclusive-combo** allow people to select multiple choices but
  record the exact value if they select a single one or `combination` if
  they pick more than one.
- **multiple** record each choice picked by a user
- **freefrom** accept freeform text

A survey about ice cream is admittedly a dumb example. It's something
you could create with an existing public service like SurveyMonkey or
Google Forms. Imagine however that we wanted to ask questions about
something more confidential like employee diversity or sexual
orientation. These systems all collect individual responses as
database records or rows in a spreadsheet. While they are probably
secure, why do I need this detailed information if I am only going to
generate summary statistics anyway? Individual responses might be
anonymous, but may endanger a respondent's privacy when combined
together in a query.  Why should I be asking people to trust me that
nobody will use these records to drill down and do something awful
like count how many LGBT people are in the accounting department of
the NYC office? What if the data collection only allowed for
pre-approved interpretations?

This program is written to automatically preserve privacy by
discarding survey submissions and using them just to increment
counters like this

Survey: ice-cream
- like_ice_cream:yes 85
- like_ice_cream:no 23
- like_ice_cream:decline 5
- flavor:chocolate 83
- flavor:vanilla 45
- flavor:strawberry 12
- flavor:combination 34
- toppings:sprinkles 83
- toppings:coconut 7
- toppings:none 83
- brand:Blue Bell 43
- brand:Gifford's 8

If we wanted to also drill down on the intersections between two fields, we
could specify that in a configuration in advance (this system is designed to
prevent such analysis after the fact)

- flavor:chocolate|topping:sprinkles 47
- flavor:chocolate|topping:coconut 2
and so on...

Be careful: This functionality is meant for very broad intersections
like `engineering/non-engineering` AND `gender` for
instance. Finer-grained intersections that span many fields and result
in only a few responses could harm the privacy of individuals.

This program has the following components:
- A simple single-table DB schema for storing the counters
- A way to [represent survey forms with YAML](config/surveys/sample-survey.yml)
  for easy rendering into forms
- The ability to specify _intersections_ between variables you want more
  detailed breakdowns of
- A simple JSON API endpoint for returning the data collected to authorized administrators.

## Local Development

The survey application is written as a Ruby on Rails application
running on Ruby 2.3.0. Most of its libraries are available as gems
that can be installed by bundler. It does use Postgresql as its
database, so you will need to have that installed.

To get a local copy running

``` shell
git clone git@github.com:18F/confidential-survey.git
cd confidential-survey
bundle install
bundle exec rake db:setup
bundle exec rails server
export SURVEY_ADMIN_NAME=debug
export SURVEY_ADMIN_PASSWORD=debug
```

Then you can go to http://localhost:3000/survey/sample-survey and you
should see a survey you can fill out. If you visit an
administrator-protected route, it should prompt you for the username
and password set above.

## Testing

``` shell
bundle exec rake
```

should execute the tests. All tests are written in RSpec

## Deploying the Application

This application is deployed on the cloud.gov PaaS which runs on Cloud
Foundry. The following instructions are 18F-specific, but could easily
be adapted for other Cloud Foundry instances or other web hosts.

Create the app (it's ok if the deploy fails):

```
cf push survey
```

Create the database service:

```
cf create-service rds shared-psql survey-psql
```

Set environment variables with `cf set-env`:

```
cf set-env survey SURVEY_ADMIN_NAME [username]
cf set-env survey SURVEY_ADMIN_PASSWORD: [password]
```

The application is currently secured in production with blanket HTTP
Authentication, so you will need to set its username and
password. These will also need to be set to run the app in cf ssh so
we have to set this twice.

Set up the database:

```
cf-ssh
bundle exec rake db:migrate
bundle exec rake db:seed
```

Restage the app:

```
cf restage survey
```

To deploy future releases:

``` shell
cf push survey
```

## Deploying a New Survey

Surveys are implemented as YAML configuration files within the
`config/surveys` directory of the application (here is
[a sample survey included in the repo](https://github.com/18F/confidential-survey/blob/develop/config/surveys/sample-survey.yml)). Surveys
do not need to be – and probably *should not* be – checked into the
repo.

1. To make a new survey live, the app (with survey file in its
   `config/surveys`) must be deployed to production. This limits the
   ability to create/edit surveys on the system only to the lead
   developer or anybody else with deploy access to the specific
   space. If the survey is named `SURVEY_NAME.yml`, the new survey
   form is accessible at `/surveys/SURVEY_NAME`
2. To mark a live survey as `inactive` – meaning that it no longer
   accepts responses – the developer has to edit a field in the
   survey's YAML configuration to be `active: false` and redeploy the
   survey.
3. To delete the survey form entirely, the developer can delete the
   survey's YAML file and redeploy. This will not remove the counts
   recorded for the survey from the database.

The survey name is used to key all tallies for its responses in the
system. This means that changing the survey name/URL will reset all
its tallies to 0 unless you rename all the old rows to use the new ID.

## Access Control

The survey application supports two different modes of securing access:

* One-time use tokens that can be distributed to a population (**default**)
* A single HTTP authentication username/password shared across all users

Neither of these schemes are meant to identify specific users for a
survey. The goal of these tools is merely to limit access to surveys
so that they can be taken only by people who are supposed to take the
survey.

### Token Access

The token scheme requires the survey administrators to generate a pool
of tokens for the survey. These can then be distributed out to survey
participants. It is best that whoever is doing this distribution does
not retain a list of which tokens are sent to which users, since that
information could potentially be used by someone with database access
to identify people who have not taken the survey.

To generate tokens, an administrator can send a GET or POST request to
`/surveys/SURVEY-NAME/token` and this will generate a token linked to
the survey and return a URL that can be given to a single user for
taking the survey. This endpoint can be called to return a batch of
tokens by appending a `n=` argument to the request. Here is an example
of calling it on a development instance running on localhost.

```shell
curl --user ${SURVEY_ADMIN_USER}:${SURVEY_ADMIN_PASSWORD} http://localhost:3000/surveys/sample-survey/token\?n\=10

http://localhost:3000/surveys/sample-survey?token=z9OJSmzFZcKWDpXlnt1LPA
http://localhost:3000/surveys/sample-survey?token=wE-gRGcI0ayHH3Q8qW5MtA
http://localhost:3000/surveys/sample-survey?token=Hi59JzRPbXOAN9Mu2876sg
http://localhost:3000/surveys/sample-survey?token=FU7bwF29kKqcV-27lAIfCQ
http://localhost:3000/surveys/sample-survey?token=Wm-pvsfkr20y-pGALiYjuw
http://localhost:3000/surveys/sample-survey?token=FmOml8wTKJo7mHAjf_8y8A
http://localhost:3000/surveys/sample-survey?token=xKquRdHvi0YpJ2iADxpZpw
http://localhost:3000/surveys/sample-survey?token=PHPd_SW5i-AzZaIUscl13w
http://localhost:3000/surveys/sample-survey?token=iqQPTzQ21pdEaKjROb6Ozw
http://localhost:3000/surveys/sample-survey?token=C7Zg2J_1nyFpW-dWms-gNQ
```

Once a user uses this URL to fill out the survey, the token will be
revoked and the URL will not work again. This means that the same URL
should not be given to several users. The token is only used for
access and does not identify a respondent in any way. There is no
issue with generating many extra tokens that aren't used, and tokens
can be generated at any time when a survey is active. To close access
to a survey, all tokens can be revoked by an administrator.

``` shell
curl --user ${SURVEY_ADMIN_USER}:${SURVEY_ADMIN_PASSWORD} http://localhost:3000/surveys/sample-survey/revoke
```

Tokens are generated by the `SurveyToken` model using Ruby's
`SecureRandom` class for generating random tokens using system
libraries for randomness and entropy. Currently, each token is a
16-byte random number meaning there is a 1 in 3.40282367x10^38 chance
of guessing a token. All of this does assume the `SecureRandom`
library has no issues that weaken random number generation.

### HTTP Authentication

Alternatively, you can specify that the tool should use blanket HTTP
authentication to protect the survey form. This requires you to add 2-3
fields to the survey YAML to indicate that you want to use HTTP
authentication:

``` yaml
access:
    type: http_auth
    user: <username>
    password: <password>
```

This will then require HTTP authentication for users to access /
submit the surveys. There are a few caveats to this approach:

* It is up to you to use a sufficiently secure password.
* Since the same credentials are shared across all users, there is
  nothing to prevent ballot-box stuffing.
* Surveys must be set `active: false` and redeployed to disable HTTP
  auth-protected surveys since it does not rely on access tokens

## Notes on Survey Construction

- I am not a lawyer. Neither is this application. Just because you
  _can_ use this program to create a survey for people like employees or
  students, this application doesn't grant you the legal or moral right
  to do so. Please consult with the appropriate people first.
- Whenever possible, users should be presented with an option to
  explicitly decline to answer. Users always have the option of silently
  declining by not selecting any choice, but those rejections are simply
  not counted vs. an active decline
- Intersections should be used sparingly and in such a way that a
  specific subpopulation can not be used to deanonymize survey
  respondents.
- Administrators could conceivably forge responses/stuff ballot
  boxes/over-represent certain individuals by minting as many tokens as
  they wanted. This is not a tool for elections.

## Caveats About Anonymity

This program is written to minimize the amount of information
collected to help preserve the anonymity of respondents, but I can not
explicitly _guarantee_ that respondents will always be
anonymous. There are a few ways in which anonymity could potentially
be compromised:

- If an attacker has a list of which tokens were distributed to which
  users, they could use this information to figure out who has NOT
  taken the survey unless all tokens are automatically scrubbed with
  the `revoke_tokens` request. For this reason, whomever is
  distributing the tokens should ideally not keep a list of who has
  what tokens at all, and should not share any information with an
  administrator who has access to the database.
- If the attacker had the ability to monitor incoming requests to the
  application as well, they could see a specific user's responses when
  they were submitted with the user's token.
- If the attacker has the ability to view the database, he could
  reverse engineer survey responses by capturing the tallies on a
  quick interval and looking for differences in counts. Keep your
  database secure.
- Server logs could conceivably leak information about surveys. This
  application does not keep logs about submissions, but proper care
  should be taken to scrub logs at load balancers as well. In
  addition, IP addresses could be used to identify if a user has
  participated in the survey even if the communication and responses
  are secure. For maximum safety, use TOR.

## Why Is There a Session Cookie?

The application will set a session cookie, which seems like something
that will undermine the promises of anonymity. Unfortunately, I need
to use that cookie for Rails' protection against Cross-Site Request
Forgery (CSRF) with the form. Rails' form classes provide that
protection automatically. The survey application emphatically does not
use the session cookie for storing/retrieving any other information or
any other cookies.

## Security Scans

This repository uses two tools to provide a total of three types of automated security checks:

- [Brakeman](http://brakemanscanner.org/) provides static code analysis.
- [Hakiri](https://hakiri.io/) is used to ensure the Rails/Ruby versions contain no known CVEs.
- Hakiri is used to ensure the gems declared in the Gemfile contain no known CVEs.

All security scans are built into the test suite. `bundle exec rake spec` will run them. To run the security scans ad hoc:

Brakeman:
```
bundle exec brakeman
```

Hakiri for Ruby/Rails versions:
```
bundle exec hakiri system:scan -m hakiri_manifest.json
```

Hakiri for Gemfile dependency versions:
```
bundle exec hakiri gemfile:scan
```

### Ignored Brakeman warnings

Sometimes Brakeman will report a false positive. In cases like these, the warnings will be ignored. Ignored warnings are declared in `config/brakeman.ignore`. This file contains a machine-readable list of all ignored warnings. Any ignored warning will contain a note explaining (or linking to an explanation of) why the warning is ignored.

# Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
