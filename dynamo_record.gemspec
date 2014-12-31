# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamo_record/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamo_record"
  spec.version       = DynamoRecord::VERSION
  spec.authors       = ["Nguyen Vu Nguyen"]
  spec.email         = ["nvunguyen@gmail.com"]
  spec.summary       = %q{A simple DynamoDB ORM wrapper on top of aws-sdk v2}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.1.0"
  spec.add_dependency "aws-sdk", "~> 2.0.17.pre"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "vcr", "~> 2.9.3"
  spec.add_development_dependency "webmock", "~> 1.20.4"
end
