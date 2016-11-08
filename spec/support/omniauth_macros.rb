module OmniauthMacros
  def mock_auth_hash
    # The mock_auth configuration allows you to set per-provider (or default)
    # authentication hashes to return during integration testing.
    OmniAuth.config.test_mode = true
    omniauth_hash = {
      'provider' => 'wunderlist',
      'uid' => '29530575',
      'info' => {
        'name' => "John Holly",
        'email': 'holly@mail.wtf'
      },
      'credentials' => {
        'token' => 'mock_token'
      }
    }
    # OmniAuth.config.mock_auth[:wunderlist]
    OmniAuth.config.add_mock(:wunderlist, omniauth_hash)
    # return omniauth_hash
  end
end
