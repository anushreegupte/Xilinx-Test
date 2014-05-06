#!/usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';
use My::ReportReader qw(print_data);

my $inputfile = shift @ARGV;
print "Processing input file $inputfile \n";
print_data($inputfile);
