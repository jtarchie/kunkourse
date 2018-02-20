require 'json'
require 'tempfile'
require 'digest'

module Kunkourse
  module Repository
    class Memory
      def create_container(name:, image:, command:)
        payload = {
          'apiVersion' => 'v1',
          'kind' => 'Pod',
          'metadata' => {
            'name' => container_name(name, prefix: 'pod')
          },
          'spec' => {
            'containers' => [
              {
                'name' => container_name(name),
                'image' => image,
                'command' => command
              }
            ],
            'restartPolicy' => 'Never'
          }
        }.to_json

        file = Tempfile.new('pod')
        file << payload
        file.close

        system("kubectl create -f #{file.path}")
      end

      def container_status(name:)
        payload = JSON.parse(`kubectl get pod #{container_name name, prefix: 'pod'} -o json`)
        case payload.fetch('status').fetch('phase')
        when 'Succeeded'
          :success
        else
          :pending
        end
      end

      def container_output(name:)
        `kubectl logs #{container_name name, prefix: 'pod'}`
      end

      def set_output(name:, output:)
        @outputs ||= {}
        @outputs[name.dup] = output.dup
      end

      def get_output(name:)
        @outputs ||= {}
        @outputs[name.dup]
      end

      def create_version(name:, version:)
        @versions ||= Hash.new { |h, k| h[k] = [] }
        @versions[name.dup] << version.dup
      end

      def latest_version(name:)
        @versions[name.dup].last
      end

      private

      def container_name(name, prefix: nil)
        [
          prefix,
          'kunkourse',
          Digest::SHA2.hexdigest(name)
        ].compact.join('-')[0..62]
      end
    end
  end
end
