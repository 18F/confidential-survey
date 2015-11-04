# Confidential Survey

This is a prototype application for gathering responses from
confidential surveys in a way that doesn't result in a large table of
sensitive records.

The basic idea is to not store individual form responses as records,
but to instead use the submission to increment the appropriate
counters. This allows to derive the statistics we want to ultimately
measure without assembling a large database of individual responses.

So, if we had a survey on ice cream and we wanted to ask employees:
- Do you like ice cream? (Yes/No/Prefer Not To Answer)
- What flavors do you like? (Chocolate/Vanilla/...)
- What toppings do you want on your sundae? (Sprinkles/Hot Fudge/..)
- What is your favorite brand? (Fill in the Blank)

And so on. We could classify the types of questions here among several
distinct types to start with:

- **exclusive** allow only one choice from the available options
- **exclusive-combo** allow people to select multiple choices but record the
exact value if they select a single one or `combination` if they pick more than one.
- **multiple** record each choice picked by a user
- **freefrom** accept freeform text

So what? I'll admit that ice cream is a dumb example.
This sounds like something you could setup with SurveyMonkey or Google
Forms, but imagine we wanted to ask questions about something more confidential
like employee diversity or sexual orientation or something. These systems all
collect individual responses as records or rows in a spreadsheet. While they are
probably secure, why do I need this detailed information if I am just going to generate
summary statistics anyway? Why should I be asking people to trust me that nobody
will use these records to drill down and do something awful like count how many
LGBT people are in the accounting department of the NYC office? What if the
data collection only allowed for pre-approved interpretations?

This program is **being written** (honestly, it doesn't work yet!) to accept
survey submissions and just use them to increment counters without saving the
responses to a single record. Instead, the survey would result in a collection
of counters like this

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
- A way to represent survey forms with YAML for easy rendering into forms
- The ability to specify intersection between variables you want more
  detailed breakdowns of
- A simple API endpoint for returning the data collected.
