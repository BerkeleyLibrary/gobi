dockerComposePipeline(
  commands: [
    [
      'rubocop',
      'rspec'
    ],
  ],
  archiveArtifacts: [
    artifacts: 'build/artifacts/rubocop/*.html', allowEmptyArchive: true,
  ],
  artifacts: [
    junit   : 'artifacts/rspec/*.xml',
    html    : [
      'RuboCop'      : 'artifacts/rubocop/*.html',
    ],
  ]
)

