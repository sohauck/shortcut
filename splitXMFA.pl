#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: splitXMFA.pl
# AUTHOR:  Sofia Hauck
# CREATED: 10.12.2013
# UPDATED: ----------
# VERSION: v1.00
#--------------------------------------------------------
# VERSION HISTORY
# v1.01 (10.12.2013) created
#--------------------------------------------------------

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );

# Get Command line options, exits if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $fIn = $ARGV[0];

# Command line option checks
if(! defined $fIn) { Usage("Missing Option: input file <FILE>"); exit; }
if(! -e $fIn) { Usage("Input file does not exist: $fIn"); exit; }

# Preparing for output
my $dOut = $fIn . "-sep";
if(-e $dOut) { Usage("Output directory already exist: $dOut"); exit; }
mkdir $dOut; 

# Open infile, move to outfile directory
open(INFILE, $fIn) or die "Cannot open $fIn\n";
	chdir $dOut;
	my $firstline = <INFILE>;
	
	# For first locus, $locus filled, outfile opened, first line printed
	my ($junk, $junk2, $locus) = split (' ', $firstline);
	my ($isolate, $junk3) = split (/\|/, $firstline, 2);
	open(OUTFILE, '>>', "$locus" . ".fas");
		print OUTFILE "$isolate" . "\n";
	
	# For separating files 	
	my $needsetup = 0;
	
	
	while ( my $line = <INFILE> )											
	{
		# If the line is a separator, close the file, tick needsetup
		if ( $line eq "=\n" )
			{
				close OUTFILE;
				$needsetup = 1;
			}
		# Open the new file, write first isolate, untick needsetup
		elsif ($needsetup == 1)
			{
				my ($junk, $junk2, $locus) = split (' ', $line);
				my ($isolate, $junk3) = split (/\|/, $line, 2);

				open(OUTFILE, '>>', "$locus" . ".fas");
					print OUTFILE "$isolate" . "\n";
				$needsetup = 0;
			}
		# If it's an isolate header
		elsif ( $line =~ m/^>/ )
		{
			my ($isolate, $junk3) = split (/\|/, $line, 2);
			print OUTFILE "$isolate" . "\n";
		}
		# If it's a normal line, just print it to the current outfile
		else
			{
				print OUTFILE $line;
			}
	}
close(INFILE);

print "Finished! Results are in $dOut directory.\n";

#---------------------------------------------------------------
# Subroutines
#---------------------------------------------------------------

sub Usage( ; $ )
{
	my $message = $_[0] || '';

	print << 'EOU';

splitXMFA.pl

Description:
  Takes a XMFA file produced by BIGS GC alignment and splits into one file per locus.
     
	  
Usage:
splitXMFA.pl [ options ]

Write path to XMFA file in command line.
Results will be in folder with same name as file,
with files within the folder being named after the locus.

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}

