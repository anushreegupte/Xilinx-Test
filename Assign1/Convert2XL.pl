use XML::LibXML;
use Data::Dumper;
use Excel::Writer::XLSX;                             

my $inputfilename = "Assign1/convert2xl.xml";
my $outputfilename = "Assign1/converted.xls";

print "Converting XML file $filename to Excel workbook $outputfilename";


my $workbook = Excel::Writer::XLSX->new( $outputfilename );
my $summary_ws = $workbook->add_worksheet('Summary');
my $group1_ws = $workbook->add_worksheet('Group1');
my $group2_ws = $workbook->add_worksheet('Group2');

# Add and define a header format
$format = $workbook->add_format();
$format->set_bold();
$format->set_bg_color( '#B02A2A' );
$format->set_align( 'center' );

# Add a row format
$rowformat = $workbook->add_format();
$rowformat->set_align( 'center' );

my $filename = "convert2xl.xml";


my $parser = XML::LibXML->new();
my $xmldoc = $parser->parse_file($inputfilename);

my $tcs, $group, $metric1, $metric2, $result, $suite;
my $final = {};
my $group1metric1count = 0;
my $group1metric2count = 0;
my $group1metric1total = 0;
my $group1metric1total = 0;
my $group2metric1count = 0;
my $group2metric2count = 0;
my $group2metric1total = 0;
my $group2metric1total = 0;

my $summaryrow = 1;
my $group1row = 1;
my $group2row = 1;

my @fieldstowrite=( 'Group', 'Suite', 'Total', 'Total Pass', 'Total Fail', 'Pass percentage', 'Metric1 Avg', 'Metric2 Avg' );
write_to_excel('summary', \$summaryrow, 'header', \@fieldstowrite);

for my $test ($xmldoc->findnodes('/testresults/test')) {
	
    for my $field ($test->findnodes('./*')) {
        #print $field->nodeName(), ": ", $field->textContent(), "\n";
	if($field->nodeName() eq "name"){
		$tcs=$field->textContent();	
	}else{
		${$field->nodeName()} = $field->textContent();
	}
    }
    	#print "$tcs $group $metric1 $metric2 $result $suite \n";
	$final->{$group}->{$suite}->{$tcs}={'result'=>$result, 'metric1'=>$metric1, 'metric2'=>$metric2};
	add_metric($group, $metric1, $metric2, $suite, $result);
}

my $group1metric1avg = $group1metric1total/$group1metric1count;
my $group1metric2avg = $group1metric2total/$group1metric2count;
my $group2metric1avg = $group2metric1total/$group2metric1count;
my $group2metric2avg = $group2metric2total/$group2metric2count;

#print "-----------------------------------------------------------------\n";
#print "      , AVG ,        , $group1metric1avg , $group1metric2avg \n";
@fieldstowrite=('' , 'AVG' , '' ,  $group1metric1avg , $group1metric2avg );
write_to_excel('group1', \$group1row, 'nonheader', \@fieldstowrite);

#print "-----------------------------------------------------------------\n";
#print "Suite , TCS , RESULT , METRIC1, METRIC2 \n";
@fieldstowrite=('Suite' , 'TCS' , 'RESULT' , 'METRIC1' , 'METRIC2');
write_to_excel('group1', \$group1row, 'header', \@fieldstowrite);
# Process group1
my $group1 = $final->{"group1"};
foreach my $suite (sort  keys $group1){
	my $pass = 0;
	my $fail = 0;
	my $metric1sum = 0;
	my $metric2sum = 0;
	my $count = 0;
	foreach my $tcs (sort { $a <=> $b } keys $group1->{$suite}){
		my $innerhash = $group1->{$suite}->{$tcs};
		my $result = $innerhash->{'result'};
		my $metric1 = $innerhash->{'metric1'};
		my $metric2 = $innerhash->{'metric2'};

		#print "$suite , $tcs , $result , $metric1 , $metric2 \n ";
		my @innerfieldstowrite=($suite, $tcs, $result, $metric1, $metric2);
		write_to_excel('group1', \$group1row, 'nonheader', \@innerfieldstowrite);

		# Gettting summary
		if($result eq "PASS"){
			$pass = $pass + 1;
		}else{
			$fail = $fail + 1;
		}		
		
		$metric1sum = $metric1sum + $metric1;
		$metric2sum = $metric2sum + $metric2;
		
	}
	my $total = $pass + $fail;	
	my $passpercent = ($pass/$total)*100;
	
	#print "Group1 , $suite , $total , $pass , $fail , $passpercent , ".($metric1sum/$total)." , ". ($metric2sum/$total)." \n";
	my @outerfieldstowrite=( 'Group1', $suite, $total, $pass, $fail, $passpercent, $metric1sum/$total, $metric2sum/$total );
	write_to_excel('summary', \$summaryrow, 'nonheader', \@outerfieldstowrite);

}

#print "-----------------------------------------------------------------\n";
#print "-----------------------------------------------------------------\n";
#print "-----------------------------------------------------------------\n";
#print "      , AVG ,        , $group2metric1avg , $group2metric2avg \n";
@fieldstowrite=('' , 'AVG' , '' ,  $group1metric1avg , $group1metric2avg);
write_to_excel('group2', \$group2row, 'nonheader', \@fieldstowrite);

#print "-----------------------------------------------------------------\n";
@fieldstowrite=('Suite' , 'TCS' , 'RESULT' , 'METRIC1' , 'METRIC2');
write_to_excel('group2', \$group2row, 'header', \@fieldstowrite);
# Process group2
my $group2 = $final->{"group2"};

foreach my $suite (sort keys $group2){
	my $pass = 0;
	my $fail = 0;
	my $metric1sum = 0;
	my $metric2sum = 0;
	my $count = 0;
	
	foreach my $tcs (sort keys $group2->{$suite}){
		my $innerhash = $group2->{$suite}->{$tcs};
		my $result = $innerhash->{'result'};
		my $metric1 = $innerhash->{'metric1'};
		my $metric2 = $innerhash->{'metric2'};

		#print "$suite , $tcs , $result , $metric1 , $metric2 \n ";
		my @innerfieldstowrite=($suite, $tcs, $result, $metric1, $metric2);
		write_to_excel('group2', \$group2row, 'nonheader', \@innerfieldstowrite);

		# Gettting summary
		if($result eq "PASS"){
			$pass = $pass + 1;
		}else{
			$fail = $fail + 1;
		}		
		
		$metric1sum = $metric1sum + $metric1;
		$metric2sum = $metric2sum + $metric2;
	}

	my $total = $pass + $fail;	
	my $passpercent = ($pass/$total)*100;

	#print "Group1 , $suite , $total , $pass , $fail , $passpercent , ".($metric1sum/$total)." , ". ($metric2sum/$total)." \n";
	my @outerfieldstowrite=('Group2', $suite, $total, $pass, $fail, $passpercent, $metric1sum/$total, $metric2sum/$total);
	write_to_excel('summary', \$summaryrow, 'nonheader', \@outerfieldstowrite );
}

#print "-----------------------------------------------------------------\n";

sub add_metric{
	my $group = $_[0];
	my $metric1value = $_[1];
	my $metric2value = $_[2];

	if($group eq "group1"){
		$group1metric1count = $group1metric1count + 1;
		$group1metric1total = $group1metric1total + $metric1value;
		$group1metric2count = $group1metric2count + 1;
		$group1metric2total = $group1metric2total + $metric2value;
	}elsif($group eq "group2"){
		$group2metric1count = $group2metric1count + 1;
		$group2metric1total = $group2metric1total + $metric1value;
		$group2metric2count = $group2metric2count + 1;
		$group2metric2total = $group2metric2total + $metric2value;
	}
}

sub write_to_excel{
	my $worksheet = $_[0];
	my $row = $_[1];
	my $type = $_[2];
	my @fields = @{$_[3]};

	my $col = 0;
	my $worksheet_ref = \$summary;

	if($worksheet eq 'group1'){
                $worksheet_ref = \$group1;
        }elsif($worksheet eq 'group2'){
                $worksheet_ref = \$group2;
        }
	my $headerformat = $rowformat;
	if($type eq 'header'){
		$headerformat = $format;
	}

	for(my $i=0; $i< scalar @fields; $i=$i+1){
		if($worksheet eq 'summary'){
			$summary_ws->write($$row, $col, $fields[$i], $headerformat);
		}elsif($worksheet eq 'group1'){
			$group1_ws->write($$row, $col, $fields[$i], $headerformat);
		}elsif($worksheet eq 'group2'){
			$group2_ws->write($$row, $col, $fields[$i], $headerformat);
		}
		$col = $col + 1;
	}
	$$row = $$row + 1;

}
# Process group2

#print Dumper($final);

