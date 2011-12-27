#!/usr/bin/perl
#
# Render a PBM image using Brm::Lasic - pass it as a parameter!

use warnings;
use strict;

use lib qw(.);
use Brm::Lasic;
use Brm::Lasic::PBM;

my $lasic = Brm::Lasic->new(dev => '/dev/ttyUSB0');
$lasic->reset();

my $pbm = Brm::Lasic::PBM->new(lasic => $lasic, file => $ARGV[0]);
$pbm->render();
