# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtm/version'

Gem::Specification.new do |gem|
  gem.name          = "mtm"
  gem.version       = Mtm::VERSION
  gem.authors       = ["Bruce Yue"]
  gem.email         = ["bruce.yue@outlook.com"]
  gem.description   = %q{Timecard solution}
  gem.summary       = %q{Timecard}
  gem.homepage      = "http://www.sharealltech.com"
  gem.add_dependency("sfdc", ">=2.0.0")
  gem.add_dependency("ruby-progressbar", ">=1.0.2")
  gem.add_dependency("twilio-ruby", ">=3.9.0")

  gem.files           = Dir.glob("lib/**/*") +
                      %w{README.md} +
                      Dir.glob("bin/*")

  gem.executables = %w(mtm)
  gem.bindir  = ["bin"]

  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
