require 'fb_graph'
require 'webmock/rspec'

module FbGraph
  module Mock
    def mock_graph(method, path, response_path, options = {})
      stub_request(
        method,
        endpoint_for(path)
      ).with(
        request_for(method, options)
      ).to_return(
        response_for(response_path, options)
      )
      if block_given?
        response = yield
        a_request(
          method,
          endpoint_for(path)
        ).with(
          request_for(method, options)
        ).should have_been_made.once
        response
      end
    end

    def mock_fql(query, response_file, options = {})
      options.merge!(:params => {
        :q => query
      })
      stub_request(:get, FbGraph::Query.new(query).endpoint).with(
        request_for(:get, options)
      ).to_return(
        response_for(response_file, options)
      )
      if block_given?
        response = yield
        a_request(:get, FbGraph::Query.new(query).endpoint).with(
          request_for(:get, options)
        ).should have_been_made.once
        response
      end
    end

    def request_to(path, method = :get)
      raise_error(WebMock::NetConnectNotAllowedError) { |e|
        e.message.should include("Unregistered request: #{method.to_s.upcase}")
        e.message.should include(endpoint_for path)
      }
    end

    private

    def endpoint_for(path)
      File.join(FbGraph::ROOT_URL, path)
    end

    def request_for(method, options = {})
      request = {}
      if options[:access_token]
        options[:params] ||= {}
        options[:params][:access_token] = options[:access_token].to_s
      end
      if options[:params]
        case method
        when :post, :put
          request[:body] = options[:params]
        else
          request[:query] = options[:params]
        end
      end
      request
    end

    def response_for(response_path, options = {})
      response = {}
      response[:body] = response_file_for response_path
      if options[:status]
        response[:status] = options[:status]
      end
      response
    end

    def response_file_for(response_path)
      _response_file_path_ = if File.exist? response_path
        response_path
      else
        File.join(
          File.dirname(__FILE__), '../../mock_json', "#{response_path}.json"
        )
      end
      unless File.exist? _response_file_path_
        response_file_required! _response_file_path_
      end
      File.new _response_file_path_
    end

    def response_file_required!(response_path)
      warn [
        'No response file found.',
        'You can register a response mock by sending a pull request to fb_graph-mock gem.',
        "(at #{File.join 'mock_json', response_path.split('mock_json').last})"
      ].join("\n")
    end

    module_function

    def registered_mocks
      Dir.glob(
        File.join(File.dirname(__FILE__), '../../mock_json/**/*.json')
      ).collect do |file_path|
        file_path.split('mock_json').last.sub('.json', '')
      end
    end
  end
end