#!/usr/bin/perl

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );

# Defines scalars needed from command line
my $fIn;
my $fFAS;
my $fOut;

# Get Command line options, exits if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-FAS")        { $fFAS = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Command line option checks
if(! defined $fIn)  { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fFAS) { Usage("Missing Option: -FAS <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: -out <FILE>"); exit; }

# File checks
if(! -e $fIn)  { Usage("Input file does not exist: $fIn"); exit; }
if(! -e $fFAS) { Usage("Input file does not exist: $fFAS"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }

# Put information from fFAS into conversion hash
my $genome = ""; 

open(FAS, $fFAS) or die "Cannot open $fFAS\n";
	my $line; 
	while ( $line = <FAS> )											
	{        
		chomp $line;
		$genome .= $line;
	}  
close(FAS);

print "Genome is " . length($genome) . " bases long.\n"; 


open(INFILE, $fIn) or die "Cannot open $fIn\n";
open(OUTFILE, '>>', $fOut); #open results file
my $CDS = undef; 

	while ( my $line = <INFILE> )											
	{        
		(my $ID, my $start, my $length) = split ("\t", $line); 
		$CDS = substr ($genome, $start, $length);
		print OUTFILE $ID . "\t" . $CDS . "\n";
	}  
close(INFILE);
close(OUTFILE); 


#---------------------------------------------------------------
# Subroutines
#---------------------------------------------------------------

sub Usage( ; $ )
{
	my $message = $_[0] || '';

	print << 'EOU';

FASTAextract.pl

Description: splits concatenated FASTA into ID tab CDS 

Example Input Format:
	>ERR001
	ATGGTA
	GCGCTC
	
Example FAS Format:
	R0014	12313	654
	R0015	14524	203

Example Output Format:
	R0014	ATGGTAGCGCTC
	R0015	ATCGCGCTAGCC
	
Usage:
FASTAextract.pl [ options ]

-in		<FILE> - input filename
-FAS		<FILE> - input filename
-out		<FILE> - output filename
-h		- print usage instructions

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}
