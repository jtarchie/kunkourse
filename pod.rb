require 'oj'
require 'securerandom'
require 'tempfile'

Pod = Struct.new(:name, :image, :command) do
  def run!
    pod_file = Tempfile.new('pod')
    pod_file.write Oj.dump(payload)
    pod_file.close
    system("kubectl create -f #{pod_file.path}")
    puts "pod: #{File.read(pod_file.path)}"
  end

  def finished?
    payload = Oj.load `kubectl get pod #{pod_name} -o json`
    payload.fetch('status').fetch('phase') == 'Succeeded'
  end

  def output
    return nil unless finished?
    `kubectl logs pod/#{pod_name}`
  end

  private

  def pod_name
    "kunkourse-#{name}"
  end

  def payload
    @payload ||= {
      'apiVersion' => 'v1',
      'kind' => 'Pod',
      'metadata' => {
        'name' => pod_name
      },
      'spec' => {
        'containers' => [
          {
            'name' => name,
            'image' => image,
            'command' => command
          }
        ],
        'restartPolicy' => 'Never'
      }
    }
  end
end

class CheckResource
  def initialize(source:, resource_type:)
    check_json = Oj.dump('source' => source)
    @pod = Pod.new(
      "check-#{SecureRandom.hex(10)}",
      "concourse/#{resource_type}-resource",
      ['sh', '-c', "echo '#{check_json}' | /opt/resource/check"]
    )
  end

  def run!
    @pod.run!
  end

  def finished?
    @pod.finished?
  end

  def versions
    Oj.load(@pod.output) if @pod.output
  end
end

class TaskRunner
  def initialize(image_resource:, run:, digest:)
    @pod = Pod.new(
      "task-#{SecureRandom.hex(10)}",
      "#{image_resource.fetch('source').fetch('repository')}@#{digest}",
      [run.fetch('path')] + run.fetch('args')
    )
  end

  def run!
    @pod.run!
  end

  def finished?
    @pod.finished?
  end

  def output
    @pod.output
  end
end
