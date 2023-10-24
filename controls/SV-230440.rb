control 'SV-230440' do
  title "Successful/unsuccessful uses of the renameat command in RHEL 8 must
generate an audit record."
  desc  "Without generating audit records that are specific to the security and
mission needs of the organization, it would be difficult to establish,
correlate, and investigate the events relating to an incident or identify those
responsible for one.

    Audit records can be generated from various components within the
information system (e.g., module or policy filter). The \"renameat\" command
renames a file, moving it between directories if required.

    When a user logs on, the AUID is set to the UID of the account that is
being authenticated. Daemons are not user sessions and have the loginuid set to
\"-1\". The AUID representation is an unsigned 32-bit integer, which equals
\"4294967295\". The audit system interprets \"-1\", \"4294967295\", and
\"unset\" in the same way.


  "
  desc  'rationale', ''
  desc  'check', "
    Verify RHEL 8 generates an audit record when successful/unsuccessful
attempts to use the \"renameat\" command by performing the following command to
check the file system rules in \"/etc/audit/audit.rules\":

    $ sudo grep -w \"renameat\" /etc/audit/audit.rules

    -a always,exit -F arch=b32 -S renameat -F auid>=1000 -F auid!=unset -k
delete
    -a always,exit -F arch=b64 -S renameat -F auid>=1000 -F auid!=unset -k
delete

    If the command does not return a line, or the line is commented out, this
is a finding.
  "
  desc 'fix', "
    Configure the audit system to generate an audit event for any
successful/unsuccessful use of the \"renameat\" command by adding or updating
the following rules in the \"/etc/audit/rules.d/audit.rules\" file:

    -a always,exit -F arch=b32 -S renameat -F auid>=1000 -F auid!=unset -k
delete
    -a always,exit -F arch=b64 -S renameat -F auid>=1000 -F auid!=unset -k
delete

    The audit daemon must be restarted for the changes to take effect.
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-OS-000062-GPOS-00031'
  tag satisfies: %w(SRG-OS-000062-GPOS-00031 SRG-OS-000037-GPOS-00015
                    SRG-OS-000042-GPOS-00020 SRG-OS-000062-GPOS-00031
                    SRG-OS-000392-GPOS-00172 SRG-OS-000462-GPOS-00206
                    SRG-OS-000471-GPOS-00215)
  tag gid: 'V-230440'
  tag rid: 'SV-230440r627750_rule'
  tag stig_id: 'RHEL-08-030362'
  tag fix_id: 'F-33084r568067_fix'
  tag cci: ['CCI-000169']
  tag nist: ['AU-12 a']

  audit_syscall = 'renameat'

  if virtualization.system.eql?('docker')
    impact 0.0
    describe 'Control not applicable within a container' do
      skip 'Control not applicable within a container'
    end
  else
    describe auditd.syscall(audit_syscall) do
      its('action.uniq') { should eq ['always'] }
      its('list.uniq') { should eq ['exit'] }
      its('arch.uniq') { should include 'b32' }
      its('arch.uniq') { should include 'b64' }
      its('fields.flatten') { should include 'auid>=1000' }
      its('fields.flatten') { should include 'auid!=-1' }
      its('key.uniq') { should cmp 'delete' }
    end
  end
end
