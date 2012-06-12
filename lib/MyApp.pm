package MyApp;

use strict;
use warnings;
use Carp;
use MyApp::KVM;
use MyApp::Server;
use Parallel::ForkManager;
use LWP::UserAgent;

sub new {
  my ($class, $option) = @_;

  $option ||= {};

  return bless $option, $class;
}


sub run {
  my ($self) = @_;

  my $hosts = $self->get_hv_hosts;

  for my $host ( @$hosts ) {
    my $kvm = MyApp::KVM->new({ user => $self->get_user, host => $host});
    print "hypervisor: $host\n" if $self->is_verbose;

    my @domains = $kvm->get_alived_domain;

    my $max_proc = 5;
    my $pm = Parallel::ForkManager->new($max_proc) or die;

    for my $dom ( @domains ) {
      $pm->start and next;

      my $srv = MyApp::Server->new({ user => $self->get_user, host => $host, dom => $dom });
      $srv->set_pid;
      my $cpu = sprintf "%d", $srv->get_cpu_usage;
      $self->post_to_growthforecast($dom, 'cpu', $cpu);
      my $mem = sprintf "%d", $srv->get_mem_usage;
      $self->post_to_growthforecast($dom, 'memory', $mem);
      print "  $dom, cpu:$cpu, memory:$mem\n" if $self->is_verbose;

      $pm->finish;
    }
    $pm->wait_all_children;
  }
}

sub post_to_growthforecast {
  my ($self, $dom, $graph, $number) = @_;

  my $ua = LWP::UserAgent->new;

  my %color = (
    'cpu'    => '#66cc99',
    'memory' => '#cc6699',
  );

  my $service = 'kvm';
  my $uri = sprintf "%s/%s/%s/%s", $self->get_gf_api, $service, $dom, $graph;
  my $res = $ua->post($uri, {
      number => $number,
      color  => $color{$graph},
  });
  if ($res->is_success) {

  }
  else {
    carp "$uri: ", $res->status_line;
  }
}

sub get_gf_api {
  return shift->get_config->{gf_api};
}

sub get_hv_hosts {
  my ($self) = @_;

  my @hosts = @{ $self->get_config->{hosts} };

  croak "\$self->get_config must return array" if not ref \@hosts eq 'ARRAY';

  return $self->get_config->{hosts};
}

sub is_verbose {
  return shift->{verbose};
}

sub get_user {
  return shift->get_config->{user};
}

sub get_config {
  return shift->{config};
}

1;
