dockerComposePipeline(
  commands: [
    [
      run: 'rspec', entrypoint: '/bin/sh -c',
      run: 'rubocop', entrypoint: '/bin/sh -c'
    ]
  ],
  artifacts: [
    junit   : 'artifacts/rspec/*.xml',
    html    : [
      'RuboCop'      : 'artifacts/rubocop',
    ],
  ]
)

