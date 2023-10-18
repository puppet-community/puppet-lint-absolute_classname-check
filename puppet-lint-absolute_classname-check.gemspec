Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-absolute_classname-check'
  spec.version     = '4.0.0'
  spec.homepage    = 'https://github.com/voxpupuli/puppet-lint-absolute_classname-check'
  spec.license     = 'Apache-2.0'
  spec.author      = 'Vox Pupuli'
  spec.email       = 'voxpupuli@groups.io'
  spec.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.summary     = 'A puppet-lint plugin to check that classes are not included or referenced by their absolute name.'
  spec.description = <<-EOF
    A puppet-lint plugin to check that classes are not included or referenced by their absolute name.
  EOF

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'puppetlabs-puppet-lint', '~> 5.0'
end
