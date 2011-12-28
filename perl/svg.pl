#!/usr/bin/perl
#
# Render a SVG image using Brm::Lasic - pass it as a parameter!

use warnings;
use strict;

use lib qw(.);
use Brm::Lasic;

open my $fd, '-|', '../svg/showsvg.py', $ARGV[0] or die "showsvg.py: $!";
my @cmd = <$fd>;
chomp @cmd;
@cmd = map {
	@_ = split(/ +/, $_);
	die "bad SVG - unsupported object" if $_[0] eq 'fuck';
	pop @_;
	[ @_ ]
} @cmd;
close $fd;

print "Does the plot look good? Make sure the axes are based at/near zero!\n";
open my $plot, '|-', 'gnuplot', '-e', 'set size ratio -1; plot \'-\' u 1:(-$2) with lines; pause mouse' or die "gnuplot: $!";
foreach (@cmd) {
	my @c = @$_;
	next unless $c[0] eq 'v';
	print $plot "$c[2] $c[3]\n";
}
close $plot;
print "If the plot looked wrong, press Ctrl-C now! Waiting for a few seconds.\n";
sleep 3;

my $lasic = Brm::Lasic->new(dev => '/dev/ttyUSB0');
# $lasic->reset();

foreach (@cmd) {
	$lasic->msg(@$_);
}
$lasic->laser_off();
$lasic->move(0, 0);
