#!/usr/bin/perl
#
# Simple Brm::Lasic example - draw a 100x100 rectangle.

use warnings;
use strict;

use lib qw(.);
use Brm::Lasic;

my $lasic = Brm::Lasic->new(dev => '/dev/ttyUSB0');
print "reset\n";
$lasic->reset();
sleep 1;

print "focus -50\n";
$lasic->focus(-50);
sleep 1;
print "focus 50\n";
$lasic->focus(50);
sleep 1;

print "laser on\n";
$lasic->laser_on();
sleep 1;
$lasic->move(100, 0);
$lasic->move(100, 100);
$lasic->move(0, 100);
$lasic->move(0, 0);
$lasic->laser_off();
print "laser off\n";
