# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'datacat/version'

Gem::Specification.new do |s|
    s.name        = 'datacat'
    s.version     = DataCat::VERSION
    s.date        = '2020-05-15'
    s.summary     = "A process monitor client"
    s.description = "Process monitor utility reporting to Prometheus through Pushgateway."
    s.authors     = ["Ernesto Espinosa"]
    s.email       = 'e.ernesto.espinosa@gmail.com'
    s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
    s.bindir      = 'bin'
    s.homepage    = 'https://github.com/enchf/datacat'
    s.license     = 'MIT'

    s.executables << 'datacat'

    s.add_development_dependency 'irb', '~> 1.2'

    s.add_runtime_dependency 'prometheus-client', '~> 2.0'
  end
