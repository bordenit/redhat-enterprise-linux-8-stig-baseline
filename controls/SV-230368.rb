control 'SV-230368' do
  title 'RHEL 8 must be configured in the password-auth file to prohibit password reuse for a minimum of five generations.'
  desc 'Password complexity, or strength, is a measure of the effectiveness of a password in resisting attempts at guessing and brute-force attacks. If the information system or application allows the user to reuse their password consecutively when that password has exceeded its defined lifetime, the end result is a password that is not changed per policy requirements.

  RHEL 8 uses "pwhistory" consecutively as a mechanism to prohibit password reuse. This is set in both:
/etc/pam.d/password-auth
/etc/pam.d/system-auth.

Note that manual changes to the listed files may be overwritten by the "authselect" program.'
  desc 'check', 'Verify the operating system is configured in the password-auth file to prohibit password reuse for a minimum of five generations.

Check for the value of the "remember" argument in "/etc/pam.d/password-auth" with the following command:

     $ sudo grep -i remember /etc/pam.d/password-auth

     password requisite pam_pwhistory.so use_authtok remember=5 retry=3

If the line containing "pam_pwhistory.so" does not have the "remember" module argument set, is commented out, or the value of the "remember" module argument is set to less than "5", this is a finding.'
  desc 'fix', 'Configure the operating system in the password-auth file to prohibit password reuse for a minimum of five generations.

Add the following line in "/etc/pam.d/password-auth" (or modify the line to have the required value):

     password requisite pam_pwhistory.so use_authtok remember=5 retry=3'
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-OS-000077-GPOS-00045'
  tag gid: 'V-230368'
  tag rid: 'SV-230368r902759_rule'
  tag stig_id: 'RHEL-08-020220'
  tag fix_id: 'F-33012r902757_fix'
  tag cci: ['CCI-000200']
  tag nist: ['IA-5 (1) (e)']
  tag 'host', 'container'

  pam_auth_files = input('pam_auth_files')

  describe pam(pam_auth_files['password-auth']) do
    its('lines') { should match_pam_rule('password (required|requisite|sufficient) pam_pwhistory.so').any_with_integer_arg('remember', '>=', input('min_reuse_generations')) }
  end
end
