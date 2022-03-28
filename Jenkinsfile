dockerComposePipeline(
  commands: [
    [
      'rubocop',
      'rspec'
    ],
  ],
  artifacts: [
    junit   : 'artifacts/rspec/*.xml',
    html    : [
      'RuboCop'      : 'artifacts/rubocop',
    ],
  ]
)

