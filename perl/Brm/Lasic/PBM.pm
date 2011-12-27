package Brm::Lasic::PBM;

=head1 NAME

Brm::Lasic::PBM - Render PBM using Brm::Lasic

=head1 SYNOPSIS

use Brm::Lasic::PBM;

 my $lasic = Brm::Lasic->new(dev => '/dev/ttyUSB0');
 $lasic->reset();
 my $pbm = Brm::Lasic::PBM(lasic => $lasic, file => 'brm.pbm');
 $pbm->render();

=cut

use Moose;

use warnings;
use strict;

our $VERSION = '0.1';
$VERSION = eval $VERSION;

=head1 DESCRIPTION

Render a bitmap picture from PBM file using Brm::Lasic lasercutter.

=head2 ATTRIBUTES

=over 4

=item B<lasic>

Lasercutter instance.
=cut
has 'lasic' => (is => 'ro', isa => 'Brm::Lasic', required => 1);

=item B<file>

Filename of the picture.
=cut
has 'file' => (is => 'ro', isa => 'Str', required => 1);

=item B<pixeltime>

Length of etching per pixel in milliseconds;
a reasonable default is provided but this depends on the material.
=cut
has 'pixeltime' => (is => 'ro', isa => 'Num', default => 200, required => 1);

=back

=head2 METHODS

=over 4

=item B<new>(lasic => Brm::Lasic, file => bitmap filename)
=item B<new>(lasic => Brm::Lasic, file => bitmap filename, pixeltime => ms)

The lasic and file attributes must be specified.

=item B<render>

Engrave the image on the laser cutter.
=cut

sub render {
	my $self = shift;
	my ($w, $h, @bitmap);

	open my $fd, $self->file or die $self->file.": $!";
	# Two silly lines.
	<$fd>; <$fd>;
	my $dim = <$fd>; chomp $dim;
	($w, $h) = split(/ /, $dim);
	my @bits = <$fd>; chomp @bits;
	@bitmap = map { split('', $_) } @bits;
	close $fd;

	for my $y (0..$h-1) {
		for my $x (0..$w-1) {
			my $bit = $bitmap[$y * $h + $x];
			$bit or next;
			$self->lasic->move($x, $y);
			$self->lasic->laser_on();
			use Time::HiRes;
			Time::HiRes::usleep($self->pixeltime * 1000);
			$self->lasic->laser_off();
		}
	}
}

=back

=head1 COPYRIGHT

(c) 2011 Petr Baudis E<lt>pasky@ucw.czE<gt>.
This module may be redistributed using the same terms as Perl itself.

=cut

1;
