[![Code Climate](https://codeclimate.com/github/18F/confidential-survey/badges/gpa.svg)](https://codeclimate.com/github/18F/confidential-survey) [![Test Coverage](https://codeclimate.com/github/18F/confidential-survey/badges/coverage.svg)](https://codeclimate.com/github/18F/confidential-survey/coverage) [![Dependency Status](https://gemnasium.com/18F/confidential-survey.svg)](https://gemnasium.com/18F/confidential-survey) [![security](https://hakiri.io/github/18F/confidential-survey/develop.svg)](https://hakiri.io/github/18F/confidential-survey/develop) [![Build Status](https://travis-ci.org/18F/confidential-survey.svg?branch=develop)](https://travis-ci.org/18F/confidential-survey)

# Confidential Survey (v 0.0.9)

This is a prototype application for gathering responses from
confidential surveys in a way that doesn't result in a large table of
sensitive records.

The basic idea is to not store individual form responses as records,
but to instead use the submission to increment the appropriate
counters. This allows to derive the statistics we want to ultimately
measure without assembling a large database of individual responses.

[This diagram illustrates the difference from a traditional survey.](doc/how-the-survey-works.pdf)

So, if we had a survey on ice cream and we wanted to ask employees:
- Do you like ice cream? (Yes/No/Prefer Not To Answer)
- What flavors do you like? (Chocolate/Vanilla/...)
- What toppings do you want on your sundae? (Sprinkles/Hot Fudge/..)
- What is your favorite brand? (Fill in the Blank)

And so on. We could classify the types of questions here among several
distinct types to start with:

- **exclusive** allow only one choice from the available options
- **exclusive-combo** allow people to select multiple choices but
  record the exact value if they select a single one or `combination` if
  they pick more than one.
- **multiple** record each choice picked by a user
- **freefrom** accept freeform text

So what? A survey about ice cream is admittedly a dumb example. It's
something you could setup with an existing public service like
SurveyMonkey or Google Forms. Imagine however that we wanted to ask
questions about something more confidential like employee diversity or
sexual orientation. These systems all collect individual responses as
records or rows in a spreadsheet. While they are probably secure, why
do I need this detailed information if I am just going to generate
summary statistics anyway? Individual responses might be anonymous,
but may endanger a respondent's privacy when combined together in a
query.  Why should I be asking people to trust me that nobody will use
these records to drill down and do something awful like count how many
LGBT people are in the accounting department of the NYC office? What
if the data collection only allowed for pre-approved interpretations?

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

Be careful: This functionality is meant for very broad intersections like
`engineering/non-engineering` AND `gender` for instance. Fine-grained intersections
could harm the privacy of individuals

This program has the following components:
- A simple single-table DB schema for storing the counters
- A way to [represent survey forms with YAML](config/surveys/sample-survey.yml)
  for easy rendering into forms
- The ability to specify _intersections_ between variables you want more
  detailed breakdowns of
- A simple JSON API endpoint for returning the data collected.

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
```

Then you can go to http://localhost:3000/survey/sample-survey and you
should see a survey you can fill out.

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
cf set-env survey HTTP_AUTH_NAME [username]
cf set-env survey HTTP_AUTH_PASSWORD: [password]
cf set-env survey-ssh HTTP_AUTH_NAME [username]
cf set-env survey-ssh HTTP_AUTH_PASSWORD: [password]
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

## Notes on Survey Construction

- I am not a lawyer. Neither is this application. Just because you
  _can_ use this program to create a survey for people like employees or
  students, this application doesn't grant you the legal or moral right
  to do so. Please consult with the appropriate people first.
- Confidential surveys -- or responses to specific questions within -- should
  never be mandatory and this program will never include cookies or
  authentication for that reason.
- This means there are no protections against users voting more than once. **Do
  not use this to hold an election.**
- Whenever possible, users should be presented with an option to
  explicitly decline to answer. Users always have the option of silently
  declining by not selecting any choice, but those rejections are simply
  not counted vs. an active decline
- Intersections should be used sparingly and in such a way that a specific
subpopulation can not be used to deanonymize survey respondents.

## Caveats About Anonymity

- This program is written to minimize the amount of information collected to
  help preserve the anonymity of respondents, but I can not explicitly _guarantee_
  that respondents will always be anonymous. I am trying the best I can, but I am
  not an expert in cryptography and anonymity.
- To protect the anonymity of whether users have submitted any responses or not,
  this program explicitly does not use cookies or other means to identify specific
  users. This means there are no protections against ballot-box stuffing
- HTTP server logs make it impossible for me to guarantee a user's
  participation on a particular survey is anonymous, unless server logs
  are also scrubbed. I'd suggest using TOR

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
