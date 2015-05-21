#!/usr/bin/perl

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );
sub RemoveIfExists ( $ );

# Defines scalars needed from command line
my $fIn;
my $fOut;

# Get Command line options, exits if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Command line option checks
if(! defined $fIn)  { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: -out <FILE>"); exit; }

# File checks
if(! -e $fIn)  { Usage("Input file does not exist: $fIn"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }


# For each line, check if begins with "CDS"
# If yes, 
# take note of from where to where CDS runs, including if complement()
# If no, skip

open(INFILE, $fIn) or die "Cannot open $fIn\n";
open(OUTFILE, '>>', $fOut); #open results file
my $waitforCDS = 1;
my @genes = ();

	while ( my $line = <INFILE> )											
	{        
		if ( $waitforCDS == 1 && $line =~ m/^\s+CDS/ )
		{
			#skips faff at beginning, adds 1..123 or complement(2..234)
			$line = substr $line, 20; 
			chomp $line; 
			print OUTFILE $line;
			$waitforCDS = 0;
		}
		elsif ( $waitforCDS == 0 && $line =~ m(\/locus) )
		{
			#if locus_tag line, adds tab then Rv identified
			$line =~ m/"(.*?)"/;
			print OUTFILE "\t" . $1;
		}
		elsif ( $waitforCDS == 0 && $line =~ m(\/gene) )
		{
			#if gene or gene_synonym line, adds gene name to list
			$line =~ m/"(.*?)"/;
			push @genes, $1;
		}
		elsif ($waitforCDS == 0)
		{
			#if end of useful bit, adds tab then list of gene names
			print OUTFILE "\t" . join (';', @genes) . "\n";
			@genes = ();
			$waitforCDS = 1;
		}
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

annotation-cutdown.pl

Description: keeps only relevant lines from 

-in		<FILE> - input filename
-swap		<FILE> - input filename
-out		<FILE> - output filename
-h		- print usage instructions

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}
