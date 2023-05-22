control 'VCST-67-000020' do
  title 'The Security Token Service must set "URIEncoding" to UTF-8.'
  desc  "Invalid user input occurs when a user inserts data or characters into
a hosted application's data entry field and the hosted application is
unprepared to process that data. This results in unanticipated application
behavior, potentially leading to an application compromise. Invalid user input
is one of the primary methods employed when attempting to compromise an
application.

    An attacker can also enter Unicode characters into hosted applications in
an effort to break out of the document home or root home directory or bypass
security checks. The Security Token Service must be configured to use a
consistent character set via the \"URIEncoding\" attribute on the Connector
nodes.
  "
  desc  'rationale', ''
  desc  'check', "
    Connect to the PSC, whether external or embedded.

    At the command prompt, execute the following command:

    # xmllint --format /usr/lib/vmware-sso/vmware-sts/conf/server.xml | sed '2
s/xmlns=\".*\"//g' | xmllint --xpath
'/Server/Service/Connector[@port=\"${bio-custom.http.port}\"]/@URIEncoding' -

    Expected result:

    URIEncoding=\"UTF-8\"

    If the output does not match the expected result, this is a finding.
  "
  desc 'fix', "
    Connect to the PSC, whether external or embedded.

    Navigate to and open /usr/lib/vmware-sso/vmware-sts/conf/server.xml.

    Navigate to each of the <Connector> nodes.

    Configure each <Connector> node with the value 'URIEncoding=\"UTF-8\"'.
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-APP-000251-WSR-000157'
  tag gid: 'V-239671'
  tag rid: 'SV-239671r816738_rule'
  tag stig_id: 'VCST-67-000020'
  tag fix_id: 'F-42863r816737_fix'
  tag cci: ['CCI-001310']
  tag nist: ['SI-10']

  describe xml("#{input('serverXmlPath')}") do
    its(['Server/Service/Connector[@port="${bio-custom.http.port}"]/@URIEncoding']) { should cmp "#{input('uriEncoding')}" }
  end
end