# Confidential Survey

This is a prototype application for gathering responses from
confidential surveys in a way that doesn't result in a large table of
sensitive records.

The basic idea is to not store individual form responses as records,
but to instead use the submission to increment the appropriate
counters. This allows to derive the statistics we want to ultimately
measure without assembling a large database of individual responses.

So, if we had a survey on diversity and we wanted to ask employees:
- What is your gender? (male/female/other/decline)
- What division do you work for? (engineering/sales/product)
(_I know these questions could be formulated better, but this is just
for the purposes of illustration_)

We could then gather counts of responses for each response to each
question like

- Gender:Male 85
- Gender:Female 72
- Gender:Other 2
- Gender:Decline 3
- LGBT:No 112
- Division:Engineering 83
- Division:Sales 56
- Division:Product 23

We could even indicate in our config we want to collect combined counters for
permutations of both fields so we can get stats like

- Gender:Male|Division:Engineering 67
- Gender:Female|Division:Engineering 16
and so on...

These combined-field counters will not be automatic and I strongly
recommend that you avoid picking any combinations that would be too
specific, lest someone is tempted to figure out which of the four
people in engineering managment is the 1 who identifies as LGBT. The
whole point of this program is to make such analyses impossible.

This program will have the following components:
- A simple single-table DB schema for storing the counters
- A way to represent survey forms with YAML for easy rendering
- The ability to specify linkages between variables you want more
  detailed breakdowns of
- A simple API endpoint for returning the data collected.

