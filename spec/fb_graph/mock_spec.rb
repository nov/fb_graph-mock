require 'spec_helper'

describe FbGraph::Mock do
  describe '#mock_graph' do
    context 'when block given' do
      it 'should register WebMock stub' do
        request_signature = WebMock::RequestSignature.new :get, File.join(FbGraph::ROOT_URL, 'matake')
        mock_graph :get, 'matake', 'users/me_private'
        WebMock::StubRegistry.instance.should be_registered_request request_signature
      end

      context 'when registered request not called' do
        it 'should raise WebMock::AssertionFailure.error_class' do
          expect do
            mock_graph :get, 'me', 'users/me_private' do
              # nothing to do
            end
          end.to raise_error WebMock::AssertionFailure.error_class
        end
      end

      context 'otherwise' do
        it 'should not raise error' do
          expect do
            mock_graph :get, 'matake', 'users/me_private' do
              FbGraph::User.fetch :matake
            end
          end.not_to raise_error
        end
      end
    end

    context 'when no block given' do
      context 'when registered request not called' do
        it do
          expect do
            mock_graph :get, 'me', 'users/me_private'
          end.not_to raise_error
        end
      end
    end

    context 'when registered response file specified' do
      it do
        expect do
          mock_graph :get, 'me', 'users/me_private'
        end.not_to raise_error
      end
    end

    context 'when custom response file specified' do
      it do
        absolute_path = File.join File.dirname(__FILE__), '../../mock_json/users/me_private.json'
        expect do
          mock_graph :get, 'me', absolute_path
        end.not_to raise_error
      end
    end

    context 'when no response file found' do
      it do
        self.should_receive(:warn).with [
          'No response file found.',
          'You can register a response mock by sending a pull request to fb_graph-mock gem.',
          '(at mock_json/not_registered.json)'
        ].join("\n")
        expect do
          mock_graph :get, 'me', 'not_registered'
        end.to raise_error Errno::ENOENT, /No such file or directory/
      end
    end

    context 'when params given' do
      let(:params) do
        {:foo => 'bar'}
      end

      context 'when GET' do
        it do
          request_signature = WebMock::RequestSignature.new :get, File.join(FbGraph::ROOT_URL, "matake?#{params.to_query}")
          mock_graph :get, 'matake', 'users/me_private', :params => params
          WebMock::StubRegistry.instance.should be_registered_request request_signature
        end
      end

      context 'when POST' do
        it do
          request_signature = WebMock::RequestSignature.new :post, File.join(FbGraph::ROOT_URL, 'me/feed'), :body => params.to_query
          mock_graph :post, 'me/feed', 'users/feed/post_without_access_token', :params => params
          WebMock::StubRegistry.instance.should be_registered_request request_signature
        end
      end
    end

    context 'when access_token given' do
      let(:params) do
        {:access_token => access_token}
      end
      let(:access_token) do
        'access_token'
      end

      context 'when GET' do
        it do
          request_signature = WebMock::RequestSignature.new :get, File.join(FbGraph::ROOT_URL, "matake?#{params.to_query}")
          mock_graph :get, 'matake', 'users/me_private', :access_token => access_token
          WebMock::StubRegistry.instance.should be_registered_request request_signature
        end
      end

      context 'when POST' do
        it do
          request_signature = WebMock::RequestSignature.new :post, File.join(FbGraph::ROOT_URL, 'me/feed'), :body => params.to_query
          mock_graph :post, 'me/feed', 'users/feed/post_without_access_token', :access_token => access_token
          WebMock::StubRegistry.instance.should be_registered_request request_signature
        end
      end
    end

    context 'when status given' do
      it 'should mock response with given status' do
        expect do
          mock_graph :get, 'me', 'users/me_public', :status => [401, 'Unauthorized'] do
            FbGraph::User.fetch :me
          end
        end.to raise_error FbGraph::Unauthorized
      end
    end
  end

  describe '#mock_fql' do
    let(:query) { 'SELECT * FROM users WHERE uid=me' }

    context 'when block given' do
      it 'should register WebMock stub' do
        request_signature = WebMock::RequestSignature.new :get, File.join(FbGraph::ROOT_URL, "fql?q=#{URI.encode query}")
        mock_fql query, 'query/user/with_valid_token'
        WebMock::StubRegistry.instance.should be_registered_request request_signature
      end

      context 'when registered request not called' do
        it 'should raise WebMock::AssertionFailure.error_class' do
          expect do
            mock_fql query, 'query/user/with_valid_token' do
              # nothing to do
            end
          end.to raise_error WebMock::AssertionFailure.error_class
        end
      end

      context 'otherwise' do
        it 'should not raise error' do
          expect do
            mock_fql query, 'query/user/with_valid_token' do
              FbGraph::Query.fetch query
            end
          end.not_to raise_error
        end
      end
    end

    context 'when no block given' do
      context 'when registered request not called' do
        it do
          expect do
            mock_fql query, 'query/user/with_valid_token'
          end.not_to raise_error
        end
      end
    end

    context 'when registered response file specified' do
      it do
        expect do
          mock_fql query, 'query/user/with_valid_token'
        end.not_to raise_error
      end
    end

    context 'when custom response file specified' do
      it do
        absolute_path = File.join File.dirname(__FILE__), '../../mock_json/query/user/with_valid_token.json'
        expect do
          mock_fql query, absolute_path
        end.not_to raise_error
      end
    end

    context 'when no response file found' do
      it do
        self.should_receive(:warn).with [
          'No response file found.',
          'You can register a response mock by sending a pull request to fb_graph-mock gem.',
          '(at mock_json/not_registered.json)'
        ].join("\n")
        expect do
          mock_fql query, 'not_registered'
        end.to raise_error Errno::ENOENT, /No such file or directory/
      end
    end
  end

  describe '#request_to' do
    it 'should assert whether WebMock::NetConnectNotAllowedError' do
      request_signature = WebMock::RequestSignature.new :get, File.join(FbGraph::ROOT_URL, 'me')
      expect do
        error = WebMock::NetConnectNotAllowedError.new request_signature
        raise error
      end.to request_to '/me'
    end
  end

  describe '#registered_mocks' do
    it do
      registered = FbGraph::Mock.registered_mocks
      registered.should be_instance_of Array
      registered.should_not be_blank
    end
  end
end