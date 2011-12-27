package Brm::Lasic;

=head1 NAME

Brm::Lasic - interface for the brmlab lasercutter

=head1 SYNOPSIS

use Brm::Lasic;

 $lasic = Brm::Lasic->new(dev => '/dev/ttyUSB0');
 $lasic->reset();
 $lasic->focus(-3);
 $lasic->laser_on();
 $lasic->move(40, 20);
 $lasic->move(80, 0);
 $lasic->laser_off();

=cut

use Moose;
use Device::SerialPort;

use warnings;
use strict;

our $VERSION = '0.1';
$VERSION = eval $VERSION;

=head1 DESCRIPTION

Brm::Lasic instance represents a laser cutter.
You can directly use the basic functions like moving the laser,
turning the laser on/off etc.
Further add-ons provide extended functionality
like rendering a picture.

=head2 ATTRIBUTES

=over 4

=item B<dev>

Name with the tty device associated with Lasic serial port.
=cut
has 'dev' => (is => 'ro', isa => 'Str', required => 1);

=item B<port>

The tty device object. Avoid using directly.
=cut
has 'port' => (is => 'rw', isa => 'Device::SerialPort');

=item B<fd>

The tty device filehandle. Avoid using directly.
=cut
has 'fd' => (is => 'rw', isa => 'FileHandle');

=back

=head2 METHODS

=over 4

=item B<new>(dev => tty device name)

The dev attribute must be specified.
=cut

sub BUILD {
	my $self = shift;

	use Symbol qw(gensym);
	my $fd = gensym();
	my $port = tie(*$fd, "Device::SerialPort", $self->dev());
	$port or die $self->dev().": $!";
	$self->port($port);
	$self->fd($fd);

	$self->port->datatype('raw');
	$self->port->baudrate(115200);
	$self->port->databits(8);
	$self->port->parity("none");
	$self->port->stopbits(1);
	$self->port->handshake("none");
	$self->port->write_settings();
}

=item B<reset>

Reset the laser cutter. This makes the cutter re-calibrate itself
in both axes and then moves to the (0, 0) position.
=cut

sub reset {
	my $self = shift;
	$self->msg('s', 1);
}

=item B<focus>($steps)

Adjust focus. $steps (positive for down, negative for up)
denotes the number of focus adjustment steps.
=cut

sub focus {
	my $self = shift;
	my ($steps) = @_;
	if ($steps > 0) {
		$self->msg('s', 3) for (1..$steps);
	} else {
		$self->msg('s', 2) for (1..-$steps);
	}
}

=item B<laser_on>

Turn on the laser (to etching intensity).
=cut

sub laser_on {
	my $self = shift;
	$self->msg('l', 254);
}

=item B<laser_off>

Turn off the laser (to navigation intensity).
=cut

sub laser_off {
	my $self = shift;
	$self->msg('l', 0);
}

=item B<move>($x, $y)

=item B<move>($x, $y, $speed)

Move the laser to given coordinates.
If $speed is not specified (recommended), a reasonable default is used.
=cut

sub move {
	my $self = shift;
	my ($x, $y, $speed) = @_;
	defined $speed or $speed = 20;
	$self->msg('v', $speed, $x, $y);
}

=item B<msg>(...)

Send a message to the serial port and wait for its completion.
=cut

sub msg {
	my $self = shift;

	my (@args) = @_;
	push @args, 1;

	my $fd = $self->fd();
	print $fd join(' ', @args)."\r\n";
	my $msg = <$fd>;
	chomp $msg;
	print "(rep: $msg)\n";
}

=back

=head1 COPYRIGHT

(c) 2011 Petr Baudis E<lt>pasky@ucw.czE<gt>.
This module may be redistributed using the same terms as Perl itself.

=cut

1;
