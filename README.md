[![Code Climate](https://codeclimate.com/github/18F/confidential-survey/badges/gpa.svg)](https://codeclimate.com/github/18F/confidential-survey) [![Test Coverage](https://codeclimate.com/github/18F/confidential-survey/badges/coverage.svg)](https://codeclimate.com/github/18F/confidential-survey/coverage) [![Dependency Status](https://gemnasium.com/18F/confidential-survey.svg)](https://gemnasium.com/18F/confidential-survey) [![security](https://hakiri.io/github/18F/confidential-survey/develop.svg)](https://hakiri.io/github/18F/confidential-survey/develop) [![Build Status](https://travis-ci.org/18F/confidential-survey.svg?branch=develop)](https://travis-ci.org/18F/confidential-survey)

# Confidential Survey (v 0.0.8)

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

So what? I'll admit that ice cream is a dumb example. It's something
you could setup with an existing public service like SurveyMonkey or
Google Forms, but imagine we wanted to ask questions about something
more confidential like employee diversity or sexual orientation. These
systems all collect individual responses as records or rows in a
spreadsheet. While they are probably secure, why do I need this
detailed information if I am just going to generate summary statistics
anyway? Individual responses might be anonymous, but may endanger a
respondent's privacy when combined together in a query.  Why should I
be asking people to trust me that nobody will use these records to
drill down and do something awful like count how many LGBT people are
in the accounting department of the NYC office? What if the data
collection only allowed for pre-approved interpretations?

This program is **still being written** (honestly, it doesn't work
that well yet) to accept survey submissions and just use them to
increment counters without saving the responses to a single
record. Instead, the survey would result in a collection of counters
like this

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

This program will have the following components:
- A simple single-table DB schema for storing the counters
- A way to [represent survey forms with YAML](config/surveys/sample-survey.yml)
  for easy rendering into forms
- The ability to specify _intersections_ between variables you want more
  detailed breakdowns of
- A simple API endpoint for returning the data collected.

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

# Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
