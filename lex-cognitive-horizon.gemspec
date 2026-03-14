# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_horizon/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-horizon'
  spec.version       = Legion::Extensions::CognitiveHorizon::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Horizon'
  spec.description   = 'Temporal planning horizon modeling for brain-modeled agentic AI — ' \
                       'dynamic expansion/contraction based on stress, success, and construal level theory'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-horizon'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-horizon'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-horizon'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-horizon'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-horizon/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-cognitive-horizon.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
end
