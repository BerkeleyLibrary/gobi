dockerComposePipeline(
  commands: [
    [
      'rubocop',
      'rspec'
    ],
  ],
  archiveArtifacts artifacts: 'build/**/*.log', allowEmptyArchive: true
  artifacts: [
    junit   : 'artifacts/rspec/*.xml',
    html    : [
      'RuboCop'      : 'artifacts/rubocop/*.html',
    ],
  ]
)

