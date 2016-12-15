package PkgConfig::LibPkgConf::Client;

use strict;
use warnings;
use PkgConfig::LibPkgConf;

our $VERSION = '0.01';

=head1 NAME

PkgConfig::LibPkgConf::Client - Query installed libraries for compiling and linking software

=head1 SYNOPSIS

 use PkgConfig::LibPkgConf::Client;
 
 my $client = PkgConfig::LibPkgConf::Client->new;
 $client->env;
 
 my $pkg = $client->find('libarchive');
 my $cflags = $pkg->cflags;
 my $libs = $pkg->libs;

=head1 DESCRIPTION

The L<PkgConfig::LibPkgConf::Client> objects store all necessary state 
for C<libpkgconf> allowing for multiple instances to run in parallel.

=head1 CONSTRUCTOR

=head2 new

 my $client = PkgConfig::LibPkgConf::Client->new;

Creates an instance of L<PkgConfig::LibPkgConf::Client>.

=cut

sub new
{
  my $class = shift;
  my $args = ref $_[0] eq 'HASH' ? { %{$_[0]} } : { @_ };
  my $self = bless {}, $class;
  _init($self, $args);
  $self;
}

=head1 ATTRIBUTES

=head2 sysroot_dir

 my $dir = $client->sysroot_dir;
 $client->sysroot_dir($dir);

Get or set the sysroot directory.

=head2 buildroot_dir

 my $dir = $client->buildroot_dir;
 $client->buildroot_dir($dir);

Get or set the buildroot directory.

=head1 METHODS

=head2 env

 my $client->env;

This method loads settings for the client object from the environment using
the standard C<pkg-config> or C<pkgconf> environment variables.  It honors the
following list of environment variables:

=over 4

=item PKG_CONFIG_LOG

=back

=cut

# PKG_CONFIG_PATH
# PKG_CONFIG_LIBDIR
# PKG_CONFIG_SYSTEM_LIBRARY_PATH
# PKG_CONFIG_SYSTEM_INCLUDE_PATH
# PKG_CONFIG_DEBUG_SPEW
# PKG_CONFIG_IGNORE_CONFLICTS
# PKG_CONFIG_PURE_DEPGRAPH
# PKG_CONFIG_DISABLE_UNINSTALLED
# PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
# PKG_CONFIG_ALLOW_SYSTEM_LIBS
# PKG_CONFIG_TOP_BUILD_DIR
# PKG_CONFIG_SYSROOT_DIR

sub env
{
  my($self) = @_;
  if($ENV{PKG_CONFIG_LOG})
  {
    $self->audit_set_log($ENV{PKG_CONFIG_LOG}, "w");
  } 
}

=head2 find

 my $pkg = $client->find($package_name);

Searches the <.pc> file for the package with the given C<$package_name>. 
If found returns an instance of L<PkgConfig::LibPkgConf::Package>.  If 
not found returns C<undef>.

=cut

sub find
{
  # TODO: probably want to come up with a more Perlish interface for flags.
  my($self, $name, $flags) = @_;
  my $ptr = _find($self, $name, $flags||0);
  $ptr ? do {
    require PkgConfig::LibPkgConf::Package;
    bless {
      client => $self,
      name   => $name,
      ptr    => $ptr,
    }, 'PkgConfig::LibPkgConf::Package';
  } : ();
}

=head2 error

 my $client->error($message);

Called when C<libpkgconf> comes across a non-fatal error.  By default 
the error is simply displayed as a warning using L<Carp>.  The intention 
of this method is if you want to override that behavior, you will subclass
L<PkgConfig::LibPkgConf::Client> and implement your own version of the
C<error> method.

=cut

sub error
{
  my($self, $msg) = @_;
  require Carp;
  Carp::carp($msg);
  1;
}

1;

=head2 audit_set_log

 $client->audit_set_log($filename, $mode);

Opens a file with the C C<fopen> style C<$mode>, and uses it for the 
audit log.  The file is managed entirely by the client class and will be
closed when the object falls out of scope.  Examples:

 $client->audit_set_log("audit.log", "a"); # append to existing file
 $client->audit_set_log("audit2.log", "w"); # new or replace file

=head1 SUPPORT

IRC #native on irc.perl.org

Project GitHub tracker:

L<https://github.com/plicease/PkgConfig-LibPkgConf/issues>

If you want to contribute, please open a pull request on GitHub:

L<https://github.com/plicease/PkgConfig-LibPkgConf/pulls>

=head1 SEE ALSO

For additional related modules, see L<PkgConfig::LibPkgConf>

=head1 AUTHOR

Graham Ollis

For additional contributors see L<PkgConfig::LibPkgConf>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 Graham Ollis.

This is free software; you may redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

