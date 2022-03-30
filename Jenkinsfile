dockerComposePipeline(
  commands: [
    [run: 'rspec', 'rubocop', entrypoint: '/bin/sh -c']
  ],
  artifacts: [
    junit   : 'artifacts/rspec/*.xml',
    html    : [
      'RuboCop'      : 'artifacts/rubocop',
    ],
  ]
)

