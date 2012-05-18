#NCC Testsuite

This is a small project for testing the current NCC setup.

##Required gems / packages

* inifile / rubygem-inifile https://build.opensuse.org/project/repositories?project=devel%3Alanguages%3Aruby%3Aextensions
* xml-simple / rubygem-xml-simple https://build.opensuse.org/project/repositories?project=home%3Actso

##Registration

suse_register command is used for manual registration:

  suse_register -a email='user@e.mail' -a regcode-sles='SLES-registration-code' --restore-repos --force-registration
