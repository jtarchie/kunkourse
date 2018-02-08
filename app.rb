require 'yaml'
require_relative './pod'

def wait_for(pod:)
  print 'Waiting for pod'
  print '.' until pod.finished?
  print "\n"
end

pipeline = YAML.load_file('./spec/fixtures/hello.yml')
pipeline['jobs'].each do |job|
  job['plan'].each do |step|
    next unless step.key?('task')
    config = step.fetch('config')
    image_resource = config.fetch('image_resource')

    check_resource = CheckResource.new(
      source: image_resource.fetch('source'),
      resource_type: image_resource.fetch('type')
    )
    check_resource.run!
    wait_for(pod: check_resource)
    digest   = check_resource.versions.first.fetch('digest')

    task_pod = TaskRunner.new(
      image_resource: config.fetch('image_resource'),
      run: config.fetch('run'),
      digest: digest
    )
    task_pod.run!
    wait_for(pod: task_pod)
    puts "task: #{task_pod.output}"
  end
end
