package MyApp::Server;

use strict;
use warnings;



sub new {
  my ($class, $stuff) = @_;
 
  return bless $stuff, $class;
}

sub set_pid {
  my ($self) = @_;

  my $host = $self->get_host;
  my $dom  = $self->get_dom;
  my $ps   = qx{LANG=C ssh $host 'ps aux | grep "qemu-kvm .* -name $dom" | grep -v grep'};
  my $pid = (split ' ', $ps)[1];
  $self->{pid} = $pid;

}

sub get_cpu_usage {
  my ($self) = @_;

  my $pid  = $self->get_pid;
  my $host = $self->get_host;
  my $dom  = $self->get_dom;

  my $interval = 1;
  my $count    = 3;
  
  my $ps   =  qx{LANG=C ssh $host 'pidstat -p $pid $interval $count | tail -n 1'};
  my $cpu  =  (split ' ', $ps)[5];

  return "$cpu\n";

}

sub get_mem_usage {
  my ($self) = @_;

  my $pid  = $self->get_pid;
  my $host = $self->get_host;
  my $dom  = $self->get_dom;

  my $ps   = qx{LANG=C ssh $host 'ps aux | grep "qemu-kvm .* -name $dom" | grep -v grep'};
  my $mem  = (split ' ', $ps)[5];

  return "$mem\n";
}

sub get_host {
  return shift->{host};
}
sub get_user {
  return shift->{user};
}
sub get_dom {
  return shift->{dom};
}
sub get_pid {
  return shift->{pid};
}

1;
