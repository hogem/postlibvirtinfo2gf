package MyApp::KVM;


use strict;
use warnings;
use Sys::Virt;
use IO::Socket;


sub new  {
  my ($class, $stuff) = @_;

  return bless $stuff, $class;
}

sub get_alived_domain {
  my ($self) = @_;

  my $active = $self->is_ssh_active( $self->get_host );
  return if not $active;

  my $uri = sprintf "qemu+ssh://%s\@%s/system", $self->get_user, $self->get_host;
  my $vmm; eval {
    $vmm = Sys::Virt->new(uri => $uri, readonly => 1);
  };

  return if not $vmm;

  my @domains;
  for my $dom ( $vmm->list_domains ) {
    push @domains, $dom->get_name;
  }
  return @domains;

}

sub get_host {
  return shift->{host};
}

sub get_user {
  return shift->{user}; 
}

sub is_ssh_active {
  my ($self, $host) = @_;

  my $socket = IO::Socket::INET->new(
    PeerAddr => $host,  PeerPort => 22,
    Proto    => 'tcp',  Timeout  => 1,
  );
  if ($socket) {
    return 1;
  }
  else {
    return;
  }
}

1;
