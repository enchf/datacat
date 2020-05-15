# frozen_string_literal: true

Gem::Specification.new do |s|
    s.name        = 'datacat'
    s.version     = '0.1.2'
    s.date        = '2020-05-15'
    s.summary     = "A process monitor client"
    s.description = "Process monitor utility reporting to Prometheus through Pushgateway."
    s.authors     = ["Ernesto Espinosa"]
    s.email       = 'e.ernesto.espinosa@gmail.com'
    s.files       = Dir["lib/**/*.rb"]
    s.homepage    = 'https://github.com/enchf/datacat'
    s.license     = 'MIT'

    s.executables << 'datacat'

    s.add_runtime_dependency 'prometheus-client'
  end
