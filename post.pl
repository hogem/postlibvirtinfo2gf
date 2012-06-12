#!/usr/bin/perl

use strict;
use warnings;
use FindBin::libs;
use FindBin qw($Bin);
use YAML::Syck qw(LoadFile);
use MyApp;
use Getopt::Long;

my $root = $Bin;

GetOptions(
  \my %option => qw(verbose conf:s),
);

$option{conf} ||= "$root/config.yaml";

my $yaml = LoadFile($option{conf}) or die $!;


$option{config} = $yaml;
$option{root}   = $root;
my $app = MyApp->new(\%option);
$app->run();
