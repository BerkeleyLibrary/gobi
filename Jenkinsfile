dockerComposePipeline(
  commands: [
    [
      'rubocop',
      'brakeman',
      'rspec'
    ],
  ],
  artifacts: [
    junit   : 'artifacts/rspec/**/*.xml',
    html    : [
      'RuboCop'      : 'artifacts/rubocop',
      'Brakeman'     : 'artifacts/brakeman',
    ],
  ]
)

