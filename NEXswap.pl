#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: NEXswap.pl
# AUTHOR:  Sofia Hauck
# CREATED: 20.03.2014
# UPDATED: 24.03.2014
# VERSION: v1.10
#--------------------------------------------------------
# VERSION HISTORY
# 1.10 - now keeps ID in tag, Usage message works
#--------------------------------------------------------

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );
sub RemoveIfExists ( $ );

# Defines scalars needed from command line
my $fIn;
my $fSwap;
my $fOut;

# Get Command line options, exit if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-swap")        { $fSwap = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Command line option checks
if(! defined $fIn)  { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fSwap) { Usage("Missing Option: -swap <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: -out <FILE>"); exit; }

# File checks
if(! -e $fIn)  { Usage("Input file does not exist: $fIn"); exit; }
if(! -e $fSwap) { Usage("Input file does not exist: $fSwap"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }

# Put information from fSwap into conversion hash
my %swap = (); 

open(SWAP, $fSwap) or die "Cannot open $fSwap\n";
	while ( my $line = <SWAP> )											
	{        
		chomp $line; 
		(my $ID, my $information) = split(/\t/, $line); 
		$swap{$ID} = $information;
	}  
close(SWAP);


# For each line, check if begins with >
# If yes, 
# switch line for ">" + "ID" + "information" + "\n"
# If no, add line unchanged to OUTFILE

open(INFILE, $fIn) or die "Cannot open $fIn\n";
open(OUTFILE, '>>', $fOut); #open results file
my $insidematrix = 0;

	while ( my $line = <INFILE> )											
	{        
		if ( $insidematrix == 1 )
		{
			if ( $line =~ m/^\s/ )
			{
				$insidematrix = 0; 	
				print OUTFILE $line;
			}
			else # what actually needs to be done
			{
				my @matrixrow = split(/\t/, $line); 
				$matrixrow[0] =~ m/^(.*?)\|/; 
				if ( length( $1 // '' ) )
				{
					$matrixrow[0] = $swap{"$1"} . "_" . $1; 
				}
				else 
				{
					$matrixrow[0] = "0_" . $1; 
				}
			
				print OUTFILE join ("\t", @matrixrow);		
			}
		}	
		elsif ( $line =~ m/^MATRIX/ )
		{
			$insidematrix = 1;
			print OUTFILE $line;
		}
		
		else
		{
			print OUTFILE $line;
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

NEXswap.pl
print "Quit because: $message\n";

Description: switches labels in NEXUS format matrix files 

	
Example Conversion Format:
	14	Mycobacterium bovis, Australia
	1563	Mycobacterium tuberculosis, 98-R604_INH-RIF-EM
	

Usage:
NEXswap.pl [ options ]

-in		<FILE> - input filename
-con		<FILE> - input filename
-out		<FILE> - output filename
-h		- print usage instructions

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}
