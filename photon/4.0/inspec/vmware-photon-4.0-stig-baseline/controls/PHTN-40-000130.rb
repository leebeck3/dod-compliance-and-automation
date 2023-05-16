control 'PHTN-40-000130' do
  title 'The Photon operating system TDNF package management tool must cryptographically verify the authenticity of all software packages during installation.'
  desc  'Installation of any non-trusted software, patches, service packs, device drivers, or operating system components can significantly affect the overall security of the operating system. This requirement ensures the software has not been tampered with and has been provided by a trusted vendor.'
  desc  'rationale', ''
  desc  'check', "
    At the command line, run the following command to verify software packages are cryptographically verified during installation:

    # grep \"^gpgcheck\" /etc/tdnf/tdnf.conf

    If \"gpgcheck\" is not set to \"1\", this is a finding.
  "
  desc 'fix', "
    Navigate to and open:

    /etc/tdnf/tdnf.conf

    Add or update the following line:

    gpgcheck=1
  "
  impact 0.7
  tag severity: 'high'
  tag gtitle: 'SRG-OS-000366-GPOS-00153'
  tag gid: 'V-PHTN-40-000130'
  tag rid: 'SV-PHTN-40-000130'
  tag stig_id: 'PHTN-40-000130'
  tag cci: ['CCI-001749']
  tag nist: ['CM-5 (3)']

  describe command('grep "^gpgcheck" /etc/tdnf/tdnf.conf') do
    its('stdout.strip') { should cmp 'gpgcheck=1' }
  end
end