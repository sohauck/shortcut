#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: firstofeach.pl
# AUTHOR:  Sofia Hauck
# CREATED: 06.03.2014
# UPDATED: ----------
# VERSION: v1.01
#--------------------------------------------------------
# VERSION HISTORY
# 12.03.2014 little fixes
#--------------------------------------------------------

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );

# Defines scalars needed from command line
my $fIn;
my $fCol;
my $fOut;

# Get Command line options, exits if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-col")        { $fCol = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Command line option checks
if(! defined $fIn) { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fCol) { Usage("Missing Option: -col"); exit; }
if(! defined $fOut) { Usage("Missing Option: -out <FILE>"); exit; }

# File checks
if(! -e $fIn) { Usage("Input file does not exist: $fIn"); exit; }
if($fCol !~ m/^\d+$/) { Usage("Column number is not an integer"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }
$fCol = $fCol - 1; 

my %done = (); #hash to check uniqueness
my @results = (); 
my $voi; #value of interest, the thing you want unique in each row

# For each line, split into array
# check if specific column doesn't exist in "done" hash
# if true, add whole array to "results" array

open(INFILE, $fIn) or die "Cannot open $fIn\n";
	while ( my $line = <INFILE> )											
	{        
		$line =~ s/,/\t/g; #switch commas for tabs
		my @linedata = split(/\t/, $line); 
		if ($#linedata < $fCol)
		{ Usage("Column specific higher count than columns existing"); exit; }
		$voi = $linedata[$fCol];
		
		if ( !exists $done{"$voi"} )
		{	
			$done{$voi} = 1;
			push @results,  join ("\t", @linedata);
		}
	}  
close(INFILE);


# Prints results array
open(OUTFILE, '>>', $fOut); #open results file
	print OUTFILE @results;
close(OUTFILE); 

#---------------------------------------------------------------
# Subroutines
#---------------------------------------------------------------

sub Usage( ; $ )
{
	my $message = $_[0] || '';

	print << 'EOU';

firstofeach.pl
print "Quit because: $message\n";

Description: gives list of rows for each first occurrence of value in chosen column 

Example Input Format:
	A	1	first
	A	2	second
	B	3	third
	C	2	fourth
	
Example Output Format:
	when col = 1
		A	1	first
		B	3	third
		C	2	fourth
	when col = 2
		A	1	first
		A	2	second
		B	3	third
	
Usage:
countitems.pl [ options ]

-in        <FILE> - input filename
-col		integer - number of column wanted unique 
-out	   <FILE> - output filename
-h	       - print usage instructions

EOU

print "ARGV was " . join (", ", @ARGV) . "\n";
}
