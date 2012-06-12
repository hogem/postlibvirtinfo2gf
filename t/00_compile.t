use Test::More tests => 3;

use strict;
use warnings;

use FindBin::libs;
use FindBin qw($Bin);
use YAML::Syck;

my $root = "$Bin/../";
my $conf = "$root/../sysvirt/conf/config.yaml";

use_ok 'MyApp';

my $yaml = LoadFile($conf) or die $!;

my $app = MyApp->new({ config => $yaml });

is( ref $app->get_config, 'HASH' );
is( ref $app->get_hv_hosts, 'ARRAY' );
