#!/usr/bin/perl

package My::ReportReader;
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

use Exporter qw(import);
our @EXPORT_OK = qw(print_data);

my %meta = ();
my $data = {};
my @dataarr =();
my %final = ();
my $datafilled = 0;

sub read_report{
	my $inputFile= shift @_;
	my @textArray = read_file($inputFile);
	initialize_meta_hash();
	initialize_data_hash();
	foreach my $string ( @textArray ) {
		chomp $string;
		my @lineSplit= split(/:/, $string, 2);
		if(scalar @lineSplit > 1){
			my $key= extract_key(lc($lineSplit[0]));
			if($key =~ m/^slack/ and $datafilled == 1){
				push @dataarr, $data;
				initialize_data_hash();
			}
			my $value = extract_value($lineSplit[1]);		
			my $flag= insert_into_meta($key, $value);
			if($flag!=1){
				insert_into_data($key, $value);
			}

		}
	}
	push @dataarr, $data;
	$meta{'count'}=scalar @dataarr;
	$final{'data'}= \@dataarr;
	$final{'meta'}= \%meta;
}


sub print_data{
	my $inputFile= shift @_;
	read_report($inputFile);
	print Dumper(\%final);
}

sub insert_into_meta{
	my $key= $_[0];
	my $value= $_[1];
	if($key eq "part"){
		my @partarr = split(/\s+/, $value);
		my @device = split(/=/, $partarr[0]);	
		my @package = split(/=/, $partarr[1]);
		my @speed = split(/=/, $partarr[2]);
		$meta{'device'}=$device[1];
		$meta{'package'}=$package[1];
		$meta{'speed'}=$speed[1];
		return 1;
	}elsif($key eq "version"){
		my @versionarr = split(/.*Build\s([0-9]+)\s.*/, $value);
		$meta{'version'}=$value;
		$meta{'build'}=$versionarr[1];
		return 1;
	}elsif (exists $meta{$key}){
		$meta{"$key"}=$value;	
		return 1;
	}
}

sub insert_into_data{
	my $key= $_[0];
	my $value= $_[1];
	if ($key eq 'slack_violated'){
		$datafilled = 1;
		$data->{'slack'}=$value;
		$data->{'status'}="VIOLATED";	
	} elsif ($key eq 'slack'){
		$data->{'slack'}=$value;	
	} elsif ($key eq 'requirement'){
		if($value =~ m/penalty/){
			my @requirementarr = split(/\s+/, $value);
			$data->{'penalty'}=$requirementarr[2];		
			$value=$requirementarr[0];
		}	
		$data->{$key}=$value;
	}elsif($key eq "clock_uncertainty" or $key eq "clock_path_skew"){
		$data->{"$key"}=get_cleaned_value($value);
	} elsif (exists $data->{$key}){
		$data->{"$key"}=$value;
	}
}

sub get_cleaned_value{
	my $value = shift @_;
	my @valuearr = split(/\s+/, $value);
	return $valuearr[0];
}

sub extract_key{
	my $inputkey = shift @_;
	$inputkey =~ s/^\W+//g;
	$inputkey =~ s/\W+$//g;
	$inputkey =~ s/\s+/_/g;
	$inputkey =~ s/[^\w\n]//g;
	return $inputkey;
}

sub extract_value{
	my $input = shift @_;
	$input =~ s/^\s+//g;
	$input =~ s/\s+$//g;
	return $input;
}

sub initialize_data_hash{
	$data= {  
        'clock_uncertainty' => '',
        'source' => '',
        'logic_levels' => '',
        'destination' => '',
        'status' => '',
        'data_path_delay' => '',
        'path_group' => '',
        'requirement' => '',
        'path_type' => '',
        'clock_path_skew' => '',
        'slack' => ''
	};
}

sub initialize_meta_hash{
	 %meta= ('count' => 0,
           'date' => '',
           'version' => '',
           'build' => '',
           'device' => '',
           'package' => '',
           'design' => '',
           'report' => '',
           'speed' => '',
            'command' => ''
	);
}


#Testing
#read_report("postroute_timing_max.rpt");
#print_data();

1;

