#!/usr/bin/perl
#
# Simple Brm::Lasic example - draw a 100x100 rectangle.

use warnings;
use strict;

use lib qw(.);
use Brm::Lasic;

my $lasic = Brm::Lasic->new(dev => '/dev/ttyUSB0');
$lasic->reset();

$lasic->focus(-2);
$lasic->focus(2);

$lasic->laser_on();
$lasic->move(100, 0);
$lasic->move(0, 100);
$lasic->move(-100, 0);
$lasic->move(0, -100);
$lasic->laser_off();
