locals_without_parens = [
  after_each: 0,
  after_each: 1,
  after_scenario: 0,
  after_scenario: 1,
  before_each: 0,
  before_each: 1,
  before_scenario: 0,
  before_scenario: 1,
  config: 1,
  formatter: 2,
  inputs: 1,
  job: 1,
  job: 2,
  job: 3,
  jobs: 1
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
