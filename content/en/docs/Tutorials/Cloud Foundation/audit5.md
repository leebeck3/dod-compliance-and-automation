---
title: "Audit Cloud Foundation 5.x"
weight: 3
description: >
  Auditing VCF 5.x for STIG Compliance
---
## Overview
Auditing VCF for STIG compliance involves scanning the SDDC Manager appliance.  

Scanning other components of a VCF deployment such as [vSphere](/docs/tutorials/vsphere) and [NSX](/docs/tutorials/NSX) is documented in those sections on this site.

## Prerequisites
Versions listed below were used for this documentation. Other versions of these tools may work as well but if issues are found it is recommended to try the versions listed here.  

* The [vmware-cloud-foundation-sddcmgr-5x-stig-baseline](https://github.com/vmware/dod-compliance-and-automation/tree/master/vcf/5.x/inspec/vmware-cloud-foundation-sddcmgr-5x-stig-baseline) profile downloaded.
* The [vmware-photon-3.0-stig-inspec-baseline](https://github.com/vmware/dod-compliance-and-automation/tree/master/photon/3.0/inspec/vmware-photon-3.0-stig-inspec-baseline) profile downloaded.
* InSpec/Cinc Auditor 5.22.3
* SAF CLI 1.2.20
* STIG Viewer 2.17
* A VCF 5.x environment. 5.0 was used in these examples.
* An account with access to VCF.

## Auditing SDDC Manager
### Generate bearer token for SDDC Manager
The SDDC Manager InSpec profile connects to the API via a bearer token to query the configurations to audit.

This is a curl example. This can also be done via other methods such as Postman. 
```bash
# Ran from a Linux machine.
curl -k 'https://sddc-manager.vrack.vsphere.local/v1/tokens' -i -X POST \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d '{
  "username" : "administrator@vsphere.local",
  "password" : "replaceme"
}'
```

A token can also be generated UI by going to the Developer Center >> API Explorer >> Tokens.  
![alt text](/images/vcf5_generate_token.png)

Retrieve token by copying the value in the `accessToken` field.  
![alt text](/images/vcf5_view_token.png)


### Update profile inputs
Included in the `vmware-cloud-foundation-sddcmgr-5x-stig-baseline` is an example [inputs-vcf-sddcmgr-5x-example](https://github.com/vmware/dod-compliance-and-automation/tree/master/vcf/5.x/inspec/vmware-cloud-foundation-sddcmgr-5x-stig-baseline/inputs-vcf-sddcmgr-5x-example.yml) file with the following inputs relevant to SDDC Manager.

Update the inputs as shown below with values relevant to your environment. Specifically `syslogServer`,`sddcManager`,`bearerToken`,`sftpBackupsEnabled`,`sftpServer`,`ntpServers`,`currentVersion`,and `myVmwareAccount`.
```yaml
# Inputs for Photon OS.
authprivlog: /var/log/audit/auth.log
sshdcommand: "sshd -T -C 'user=vcf'"
# Enter environment specific syslog server with port. replace.local:514
syslogServer: 'replace.local:514'
# Inputs for PostgreSQL. No updates needed.
postgres_user: postgres
pg_data_dir: /data/pgdata/
pg_log_dir: /var/log/postgres
pg_owner: postgres
pg_group: users
# SDDC Manager Application
# Enter SDDC Manager FQDN/IP
sddcManager: 'sddc-manager.vsphere.local'
# Enter bearer token for API based tests
bearerToken: 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJhOGVjYTViMS04OTMwLTRiOGYtOGJmMy0xM2U4NTg2MzE3MmYiLCJpYXQiOjE2ODU1NDUyMzQsInN1YiI6ImFkbWluaXN0cmF0b3JAdnNwaGVyZS5sb2NhbCIsImlzcyI6InZjZi1hdXRoIiwiYXVkIjoic2RkYy1zZXJ2aWNlcyIsIm5iZiI6MTY4NTU0NTIzNCwiZXhwIjoxNjg1NTQ4ODM0LCJ1c2VyIjoiYWRtaW5pc3RyYXRvckB2c3BoZXJlLmxvY2FsIiwibmFtZSI6ImFkbWluaXN0cmF0b3JAdnNwaGVyZS5sb2NhbCIsInNjb3BlIjpbIlJFU09VUkNFX0ZVTkNUSU9OQUxJVFlfV1JJVEUiLCJMSUNFTlNJTkdfSU5GT19SRUFEIiwiU0REQ19GRURFUkFUSU9OX1dSSVRFIiwiQVZOX1dSSVRFIiwiU0REQ19NQU5BR0VSX1JFQUQiLCJDRVJUX1dSSVRFIiwiQ09NUE9TQUJJTElUWV9XUklURSIsIkxJQ0VOU0VfS0VZX1JFQUQiLCJDT01QT1NBQklMSVRZX1JFQUQiLCJFREdFX0NMVVNURVJfV1JJVEUiLCJVU0VSX1JFQUQiLCJDUkVERU5USUFMX1dSSVRFIiwiQkFDS1VQX0NPTkZJR19SRUFEIiwiQ0xVU1RFUl9XUklURSIsIkFWTl9SRUFEIiwiVkFTQV9QUk9WSURFUl9SRUFEIiwiRE9NQUlOX1dSSVRFIiwiQ0VJUF9SRUFEIiwiU09TX1dSSVRFIiwiU0REQ19NQU5BR0VSX1dSSVRFIiwiTlRQX1dSSVRFIiwiVEFHX1dSSVRFIiwiREVQT1RfQ09ORklHX1dSSVRFIiwiU1lTVEVNX1JFQUQiLCJERVBPVF9DT05GSUdfUkVBRCIsIkhPU1RfV1JJVEUiLCJSRVNPVVJDRV9MT0NLX1dSSVRFIiwiQkFDS1VQX1JFU1RPUkVfUkVBRCIsIkNFUlRfUkVBRCIsIlVTRVJfV1JJVEUiLCJVUEdSQURFX1JFQUQiLCJPVEhFUl9SRUFEIiwiTElDRU5TSU5HX1dSSVRFIiwiU09TX1JFQUQiLCJFVkVOVF9XUklURSIsIlNFQ1VSSVRZX0NPTkZJR19SRUFEIiwiQ1JFREVOVElBTF9SRUFEIiwiSE9TVF9SRUFEIiwiQ0VJUF9XUklURSIsIlJFU09VUkNFX0xPQ0tfUkVBRCIsIk9USEVSX1dSSVRFIiwiTElDRU5TRV9LRVlfV1JJVEUiLCJSRVNPVVJDRV9GVU5DVElPTkFMSVRZX1JFQUQiLCJDQV9SRUFEIiwiVEFHX1JFQUQiLCJMSUNFTlNJTkdfUkVBRCIsIk5FVFdPUktfUE9PTF9XUklURSIsIldDUF9SRUFEIiwiTElDRU5TSU5HX0lORk9fV1JJVEUiLCJCQUNLVVBfUkVTVE9SRV9XUklURSIsIk5UUF9SRUFEIiwiRURHRV9DTFVTVEVSX1JFQUQiLCJFVkVOVF9SRUFEIiwiQkFDS1VQX0NPTkZJR19XUklURSIsIldDUF9XUklURSIsIlNFUlZJQ0VfQUNDT1VOVF9XUklURSIsIk5FVFdPUktfUE9PTF9SRUFEIiwiQ0FfV1JJVEUiLCJDTFVTVEVSX1JFQUQiLCJWQVNBX1BST1ZJREVSX1dSSVRFIiwiRE5TX1dSSVRFIiwiU1lTVEVNX1dSSVRFIiwiVlJTTENNX1dSSVRFIiwiRE5TX1JFQUQiLCJTRVJWSUNFX0FDQ09VTlRfUkVBRCIsIlNERENfRkVERVJBVElPTl9SRUFEIiwiRE9NQUlOX1JFQUQiLCJWUlNMQ01fUkVBRCIsIlVQR1JBREVfV1JJVEUiXSwicm9sZSI6WyJBRE1JTiJdfQ.Wqxti-ZId624KeH5vF'
# Set to true if file based/sftp backups are used for SDDC Manager. Set to false if image based backups are used.
sftpBackupsEnabled: true
# Enter environment specific sftp server.
sftpServer: '10.1.2.3'
# Enter environment specific ntp servers. This is an array.
ntpServers: ['time-a-g.nist.gov','time-b-g.nist.gov']
# Enter latest version of SDDC manager with build. 5.0.0.0-21822418
currentVersion: '5.0.0.0-21822418'
# Enter myvmware account used to pull updates in SDDC Manager if used.
myVmwareAccount: 'myvmwarevcfaccount@test.local'
```

### Update the SSH config to allow scan
By default the SDDC Manager appliance does not allow root SSH and the `vcf` does not have the required privileges to complete the scan so root SSH must be temporarily enabled to complate the scan. These steps can be reversed once the audit is complete.  

```bash
# Allow root SSH into SDDC manager
ssh vcf@sddc-manager.vsphere.local
su -
vi /etc/ssh/sshd_config
# Update PermitRootLogin from no to yes and save
systemctl restart sshd
```

### Run the audit
In this example we will be scanning a target SDDC Manager, specifying an inputs file, and outputting a report to the CLI and to a JSON file ran from a linux machine.  
```bash
# Note this command is being ran from the root of the profile folder. Update paths as needed if running from a different location.
> inspec exec . -t ssh://root@sddc-manager.vsphere.local --password 'replaceme' --show-progress --input-file inputs-vcf-sddcmgr-5x-example.yml --reporter cli json:/tmp/reports/VCF_5.0.0_SDDC_Manager_STIG_Report.json

# Shown below is the last part of the output at the CLI.
  ✔  CFUI-5X-000019: The SDDC Manager UI service log files must only be accessible by privileged users.
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/access.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/access.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/access.log group is expected to cmp == "vcf"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/sddc-manager-ui-activity.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/sddc-manager-ui-activity.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/sddc-manager-ui-activity.log group is expected to cmp == "vcf"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/cspViolationReport.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/cspViolationReport.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/cspViolationReport.log group is expected to cmp == "vcf"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/sddcManagerServer.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/sddcManagerServer.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/sddcManagerServer.log group is expected to cmp == "vcf"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/supervisor.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/supervisor.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/supervisor.log group is expected to cmp == "vcf"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/user-logs/administrator-vsphere.local/administrator.server.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/user-logs/administrator-vsphere.local/administrator.server.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/user-logs/administrator-vsphere.local/administrator.server.log group is expected to cmp == "vcf"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/user-logs/administrator-vsphere.local/administrator.client.log is expected not to be writable by others
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/user-logs/administrator-vsphere.local/administrator.client.log owner is expected to cmp == "vcf_sddc_manager_ui_app"
     ✔  File /var/log/vmware/vcf/sddc-manager-ui-app/user-logs/administrator-vsphere.local/administrator.client.log group is expected to cmp == "vcf"
  ✔  CFUI-5X-000022: The SDDC Manager UI service must offload logs to a centralized logging server.
     ✔  File /etc/rsyslog.d/stig-services-sddc-manager-ui-app.conf content is expected to eq "module(load=\"imfile\" mode=\"inotify\")\ninput(type=\"imfile\"\n      File=\"/var/log/vmware/vcf/sd...     Tag=\"vcf-sddc-manager-ui-app-user-logs\"\n      Severity=\"info\"\n      Facility=\"local0\")"
  ✔  CFUI-5X-000034: The SDDC Manager UI service must have Web Distributed Authoring (WebDAV) disabled.
     ✔  Command: `(cd /opt/vmware/vcf/sddc-manager-ui-app/server/node_modules/ && npm list 2>/dev/null | grep webdav)` stdout.strip is expected to eq ""
  ✔  CFUI-5X-000044: The SDDC Manager UI service directory tree must be secured.
     ✔  Command: `find /opt/vmware/vcf/sddc-manager-ui-app/ -xdev -type f -a '(' -perm -o+w -o -not -user vcf_sddc_manager_ui_app -o -not -group vcf ')' -exec ls -ld {} \;` stdout.strip is expected to eq ""

Profile Summary: 200 successful controls, 9 control failures, 0 controls skipped
Test Summary: 974 successful, 21 failures, 0 skipped
```

## Convert the results to CKL
If a STIG Viewer CKL file is needed then the results from the scans can be converted to CKL with the [SAF CLI](/docs/automation-tools/safcli/).

```powershell
# Converting the VCSA scan results from the prior section to CKL
saf convert hdf2ckl -i /tmp/reports/VCF_5.0.0_SDDC_Manager_STIG_Report.json -o /tmp/reports/VCF_5.0.0_SDDC_Manager_STIG_Report.ckl --hostname sddc-manager.vsphere.local --fqdn sddc-manager.vsphere.local --ip 10.2.3.4 --mac 00:00:00:00:00:00
```

Opening the CKL file in STIG Viewer will look like the screenshot below. Note the InSpec results are included in the `Finding Details` pane.
![alt text](/images/vcf_audit5_ckl_screenshot.png)