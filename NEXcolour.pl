#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: NEXcolour.pl
# AUTHOR:  Sofia Hauck
# CREATED: 24.03.2014
# UPDATED: ----------
# VERSION: v1.10
#--------------------------------------------------------
# VERSION HISTORY
#--------------------------------------------------------

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );
sub RemoveIfExists ( $ );

# Defines scalars needed from command line
my $fIn;
my $fColour;
my $fOut;

# Get Command line options, exit if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-colour")     { $fColour = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Command line option checks
if(! defined $fIn)  { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fColour) { Usage("Missing Option: -colour <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: -out <FILE>"); exit; }

# File checks
if(! -e $fIn)  { Usage("Input file does not exist: $fIn"); exit; }
if(! -e $fColour) { Usage("Input file does not exist: $fColour"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }

# Put information from fColour into conversion hash
my %colour = (); 

open(COLOUR, $fColour) or die "Cannot open $fColour\n";
	while ( my $line = <COLOUR> )											
	{        
		chomp $line; 
		(my $ID, my $information) = split(/\t/, $line); 
		$colour{$ID} = $information;
	}  
close(COLOUR);


# For each line, check if begins with >
# If yes, 
# switch line for ">" + "ID" + "information" + "\n"
# If no, add line unchanged to OUTFILE

open(INFILE, $fIn) or die "Cannot open $fIn\n";
open(OUTFILE, '>>', $fOut); #open results file
my $insidevlabels = 0;

	while ( my $line = <INFILE> )											
	{        
		if ( $insidevlabels == 1 )
		{
			if ( $line =~ m/^;/ )
			{
				$insidevlabels = 0; 	
				print OUTFILE $line;
			}
			else # what actually needs to be done
			{
				chomp $line; 
				$line =~ m/'(.*?)_/; 
				my $comma = chop($line);
				print OUTFILE $line . " " . $colour{"$1"} . $comma . "\n";		
			}
		}	
		elsif ( $line =~ m/^VLABELS/ )
		{
			$insidevlabels = 1;
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

NEXcolour.pl
print "Quit because: $message\n";

Description: Switches the colour of points labels in a NEX file as per conversion list
	
Example Conversion Format:
	L1	lc=255 51 204
	L2	lc=0 51 204
	
	
Usage:
NEXcolour.pl [ options ]

-in		<FILE> - input filename
-colour		<FILE> - input filename
-out		<FILE> - output filename
-h		- print usage instructions

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}
