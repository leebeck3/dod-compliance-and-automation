control 'VRPP-8X-000047' do
  title 'PostgreSQL must invalidate session identifiers upon user logout or other session termination.'
  desc  "
    Captured sessions can be reused in \"replay\" attacks. This requirement limits the ability of adversaries to capture and continue to employ previously valid session IDs.

    This requirement focuses on communications protection for PostgreSQL session rather than for the network packet. The intent of this control is to establish grounds for confidence at each end of a communications session in the ongoing identity of the other party and in the validity of the information being transmitted.

    Session IDs are tokens generated by PostgreSQL to uniquely identify a user's (or process's) session. DBMSs will make access decisions and execute logic based on the session ID.

    Unique session IDs help to reduce predictability of said identifiers. Unique session IDs address man-in-the-middle attacks, including session hijacking or insertion of false information into a session. If the attacker is unable to identify or guess the session information related to pending application traffic, they will have more difficulty in hijacking the session or otherwise manipulating valid sessions.

    When a user logs out, or when any other session termination event occurs, PostgreSQL must terminate the user session(s) to minimize the potential for sessions to be hijacked.
  "
  desc  'rationale', ''
  desc  'check', "
    As a database administrator, perform the following at the command prompt:

    # sysctl \\
         net.ipv4.tcp_keepalive_time \\
         net.ipv4.tcp_keepalive_intvl \\
         net.ipv4.tcp_keepalive_probes

    Example output:

    net.ipv4.tcp_keepalive_time = 7200
    net.ipv4.tcp_keepalive_intvl = 75
    net.ipv4.tcp_keepalive_probes = 9

    If any of \"net.ipv4.tcp_keepalive_time\", \"net.ipv4.tcp_keepalive_intvl\", or \"net.ipv4.tcp_keepalive_probes\" are not set to organizational defined requirements, this is a finding.
  "
  desc 'fix', "
    At the command prompt, open the '/etc/sysctl.conf' file and add or update the following lines:

    net.ipv4.tcp_keepalive_time = 7200
    net.ipv4.tcp_keepalive_intvl = 75
    net.ipv4.tcp_keepalive_probes = 9

    Note: Set the parameters to organizational requirements or use the values in the examples above.

    Reload the system settings by running the following command:

    # sysctl --system
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-APP-000220-DB-000149'
  tag gid: 'V-VRPP-8X-000047'
  tag rid: 'SV-VRPP-8X-000047'
  tag stig_id: 'VRPP-8X-000047'
  tag cci: ['CCI-001185']
  tag nist: ['SC-23 (1)']

  idle = input('tcpKeepAliveIdle')
  interval = input('tcpKeepAliveInterval')
  count = input('tcpKeepAliveCount')

  describe kernel_parameter('net.ipv4.tcp_keepalive_time') do
    its('value') { should cmp idle }
  end

  describe kernel_parameter('net.ipv4.tcp_keepalive_intvl') do
    its('value') { should cmp interval }
  end

  describe kernel_parameter('net.ipv4.tcp_keepalive_probes') do
    its('value') { should cmp count }
  end
end
