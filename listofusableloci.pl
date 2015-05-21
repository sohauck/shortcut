#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: listofusableloci.pl
# AUTHOR:  Sofia Hauck
# CREATED: 26.11.2013
# UPDATED: ----------
# VERSION: v1.00
#--------------------------------------------------------
# VERSION HISTORY
# v1.01 (27.11.2013) created
#--------------------------------------------------------

use strict;
use warnings;
use Getopt::Long;

# Declares subroutines
sub Usage( ; $ );

# Receives command line options
my $fIn;
my $fOut;
my $i = 0;
my $arg_cnt = 0; 

for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Checks if infiles and outfiles are define, exist/don't exist
if(! defined $fIn) { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: --out <FILE>"); exit; }

if(! -e $fIn) { Usage("Input file does not exist: $fIn"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }


open(INFILE, $fIn) or die "Cannot open $fIn\n";

	<INFILE>; # ignores header

	while ( my $line = <INFILE> ) 		
	{
		# Removes any sort of line break, and splits into array by tab delimited
	    chomp($line); 
		$line =~ s/\r\n?|\n//g; 
        my @linedata = split(/\t/, $line);

		# Removes first array item (header) and puts it in $locus 
        my $locus = shift(@linedata); 
		
		# Checks if each allele is composed only of numbers
    	my $allAllelesOkay = 1;
    	
    	foreach my $allele (@linedata) 
    	{
    		print "Locus: $locus and allele: $allele";
    		if ( ! $allele  =~ m/^\d+$/ )
    		{ 
    			$allAllelesOkay = 0;
    			print "found a problem.";
    		}
    		print "\n";
		}
		
		# If no alleles were mismatches, then print locus name to outfile
		if ($allAllelesOkay == 1)
		{	
			open(OUTFILE, '>>', $fOut) or die "Cannot open $fOut\n"; 
				print OUTFILE $locus . "\n";
			close(OUTFILE);
		}
	} 
close(INFILE);

print "All done!\n";

sub Usage( ; $ )
{
	my $message = $_[0] || '';

	print << 'EOU';

listofusableloci.pl

Description: Removes loci where not every entry is an integer.

Example Input Format:
	Locus		A		B		C	
	BACT01		3		73		23
	BACT02		new#1	72		20
	BACT03		4				22
	
Example Output Format:
	BACT01
	  
Usage:
Program.pl [ options ]

-in        <FILE> - input filename
-out       <FILE> - output filename
-h	       - print usage instructions

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}

