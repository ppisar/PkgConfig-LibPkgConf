package PkgConfig::LibPkgConf::Test;

use strict;
use warnings;
use base qw( Exporter );
use PkgConfig::LibPkgConf::XS;

our $VERSION = '0.01';
our @EXPORT_OK = qw( send_error send_log );

# This class used only for testing and debugging PkgConfig::LibPkgConf.
# You probably do not need to bother with it.

1;
