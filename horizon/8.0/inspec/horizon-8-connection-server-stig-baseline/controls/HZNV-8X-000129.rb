control 'HZNV-8X-000129' do
  title 'The Horizon Connection Server must invalidate SSO Credentials after two hours of idle time.'
  desc  'Horizon Connection Server is intended to provide remote desktops and applications for more or less continuous use. For desktop connections, the credentials stored with Horizon must be invalidated after two hours, which will force subsequent desktop connection attempts to require reauthentication.'
  desc  'rationale', ''
  desc  'check', "
    Log in to the Horizon Connection Server administrative console.

    From the left pane, navigate to Settings >> Global Settings.

    In the right pane, click the \"General Settings\" tab and locate the \"Disconnect Applications and Discard SSO Credentials for Idle Users\" setting.

    If the \"Disconnect Applications and Discard SSO Credentials for Idle Users\" setting is set to \"Never\", or the value of \"Disconnect Applications and Discard SSO Credentials for Idle Users\" is set to anything greater than \"120\" minutes (two hours), this is a finding.
  "
  desc  'fix', "
    Log in to the Horizon Connection Server administrative console.

    From the left pane, navigate to Settings >> Global Settings.

    In the right pane, click the \"General Settings\" tab.

    Click \"Edit\".

    Next to \"Disconnect Applications and Discard SSO Credentials for Idle Users\", select \"After\" from the dropdown and fill in \"120\" minutes in the text field.

    Click \"OK\".
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-APP-000516-AS-000237'
  tag gid: 'V-HZNV-8X-000129'
  tag rid: 'SV-HZNV-8X-000129'
  tag stig_id: 'HZNV-8X-000129'
  tag cci: ['CCI-000366']
  tag nist: ['CM-6 b']

  horizonhelper.setconnection

  result = horizonhelper.getpowershellrestwithtoken('rest/config/v1/settings/general')

  json = JSON.parse(result.stdout)

  describe json['client_idle_session_timeout_policy'] do
    it { should cmp 'TIMEOUT_AFTER' }
  end

  describe json['client_idle_session_timeout_minutes'] do
    it { should cmp <= 120 }
  end
end