RSpec.describe Ezlog::Rails::AccessLog do
  include_context 'Middleware' do
    subject(:middleware) { described_class.new app, Ezlog.logger('AccessLog') }
    let(:env) do
      {
        'REQUEST_METHOD' => 'GET',
        'QUERY_STRING' => 'test=true',
        'PATH_INFO' => '/healthcheck',
        'action_dispatch.remote_ip' => '127.0.0.1',
        'rack.input' => StringIO.new('')
      }
    end
    let(:status) { 200 }
  end

  describe '#call' do
    it 'logs the request path and result as a message' do
      expect { call }.to log message: 'GET /healthcheck?test=true -> 200 (OK)'
    end

    it 'logs additional information about the request' do
      expect { call }.to log logger: 'AccessLog',
                             remote_ip: '127.0.0.1',
                             method: 'GET',
                             path: '/healthcheck?test=true',
                             params: {test: 'true'},
                             response_code: 200
    end

    context 'when the params contain sensitive information' do
      before do
        env['QUERY_STRING'] = 'password=test_pass'
        env['action_dispatch.parameter_filter'] = [:password]
      end

      it 'logs the request path with sensitive information filtered out' do
        expect { call }.to log message: 'GET /healthcheck?password=[FILTERED] -> 200 (OK)'
      end

      it 'logs the request params with sensitive information filtered out' do
        expect { call }.to log params: {password: '[FILTERED]'}
      end
    end
  end
end
