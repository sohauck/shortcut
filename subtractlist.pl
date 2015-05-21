#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: subtractlist.pl
# AUTHOR:  Sofia Hauck
# CREATED: 26.11.2013
# UPDATED: ----------
# VERSION: v1.00
#--------------------------------------------------------
# VERSION HISTORY
# v1.01 (26.11.2013) created
#--------------------------------------------------------

use strict;
use warnings;
use English qw( -no_match_vars );
use Getopt::Long;
require "dumpvar.pl";

# Declares subroutines
sub Usage( ; $ );
sub RemoveIfExists ( $ );

# Defines scalars needed from command line
my $fIn;
my $fSubtract;
my $fOut;

# Get Command line options, exits if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fIn = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-sub")        { $fSubtract = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
}
my @subtractions = split (",", $fSubtract);

# Command line option checks
if(! defined $fIn) { Usage("Missing Option: -i|--in <FILE>"); exit; }
if(! defined $fSubtract) { Usage("Missing Option: --sub <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: -o|--out <FILE>"); exit; }

# File checks
if(! -e $fIn) { Usage("Input file does not exist: $fIn"); exit; }
foreach my $file (@subtractions) {	
	if(! defined $file) { Usage("Input file does not exist: $file"); exit; }
}
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }


# Puts information from input file into hash %process, items as key with value = 1 
my %process = (); 
open(INFILE, $fIn) or die "Cannot open $fIn\n";
	while ( my $line = <INFILE> )											
	{        
		chomp($line); 
		$process{$line} = 1; 
	}  
close(INFILE);

# Assigns value = 0 to any key that exists as an item in any of the subtract files
foreach my $file (@subtractions)
{
	RemoveIfExists ( $file ); 
}

# Deletes key/value pairs when value = 0
foreach my $key (keys %process) 
{
	if ( $process{$key} == 0 )
	{
		delete $process{$key};
	}
}

#prints all the keys remaining in hash
open(OUTFILE, '>>', $fOut); #open results file
	foreach my $key (keys %process) 
	{
		print OUTFILE "$key\n";
	}

close(OUTFILE); 

#---------------------------------------------------------------
# Subroutines
#---------------------------------------------------------------

sub RemoveIfExists( $ )
{
	my $subtract_file = $_[0];
	open (SUBTRACT, $subtract_file) or die "Cannot open $subtract_file";
		while ( my $line = <SUBTRACT> )											
		{        
			chomp($line); 
			if ( exists $process{$line} ) 
			{
				$process{$line} = 0;
			} 
		}  
	close (SUBTRACT);
}

