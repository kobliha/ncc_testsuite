# NCC Testsuite #

This is a small project for testing the current NCC setup.

## Required gems / packages ##

* inifile / rubygem-inifile https://build.opensuse.org/project/repositories?project=devel%3Alanguages%3Aruby%3Aextensions
* xml-simple / rubygem-xml-simple https://build.opensuse.org/project/repositories?project=devel%3Alanguages%3Aruby%3Aextensions

## Required packages ##

* suseRegister
* git - to get the sources and for development

## Scripts in /bin/ directory ##

### cleanup ###

Prepares the system to a 'clean' state. All previous registrations are removed
by deleting NCC Credentials.

### install_products ###

Installs some products into the system and marks one as the base one.

### register ###

Runs registration using /etc/suseRegister.conf and /etc/ncc_registration.conf

### list_all ###

Lists all currently used repositories, services and applicable patches.

## Registration ##

suse_register command is used for manual registration:

    suse_register -a email='user@e.mail' -a regcode-sles='SLES-registration-code' --restore-repos --force-registration

The current solution in 'register' script uses registration data entered into
/etc/ncc_registration.conf file which you have to create on your system using
default_registration.conf in the base directory of this project.

## Preparing a Chroot Directory ##

NCC Testsuite can be called in chroot (not to destroy your system). To prepare
a chroot with openSUSE 12.1 as the base system, run the following commands.
In this example, */chroot-1/* is used for the chroot directory.

### Libzypp Repositories ###

    mkdir -pv /chroot-1/
    zypper --root=/chroot-1/ ar --refresh http://download.opensuse.org/distribution/12.1/repo/oss/ openSUSE_12.1_OSS

### Prepare for Installation ###

    mkdir -pv /chroot-1/proc
    mount --bind /proc/ /chroot-1/proc/

### Installing the Base Software ####

    zypper --no-gpg-checks --root=/chroot-1/ install suseRegister ca-certificates-cacert ca-certificates-mozilla

### Prepare the Changed Root ###

    ln --force /etc/resolv.conf /chroot-1/etc/
