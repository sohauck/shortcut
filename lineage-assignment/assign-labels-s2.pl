#!/usr/bin/perl

#--------------------------------------------------------
# PROGRAM: assign-labels-s2.pl
# AUTHOR:  Sofia Hauck
# CREATED: 07.03.2015
# UPDATED: ----------
# VERSION: v1.2
#--------------------------------------------------------
# VERSION HISTORY
# 04.06.2015 updates plus changing from lineage to less specific label
#--------------------------------------------------------

use strict;
use warnings;

# Declares subroutines
sub Usage( ; $ );

# Defines scalars needed from command line
my $fPairs;
my $fLabel;
my $fOut;
my $cutoff;

# Get Command line options, exit if conditions don't look right
if( scalar(@ARGV) < 1 ) { Usage("Not enough command line options"); exit; }
my $i = 0;
my $arg_cnt = 0; 
for ($i=0; $i<=$#ARGV; $i++)
{
	if($ARGV[$i] eq "-h")	       { Usage("You asked for help"); exit; }
	if($ARGV[$i] eq "-in")         { $fPairs = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-label")     { $fLabel = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-out")        { $fOut = $ARGV[$i+1] || ''; $arg_cnt++; }
	if($ARGV[$i] eq "-cutoff")        { $cutoff = $ARGV[$i+1] || ''; $arg_cnt++; }
}

# Command line option checks
if(! defined $fPairs)  { Usage("Missing Option: -in <FILE>"); exit; }
if(! defined $fLabel) { Usage("Missing Option: -label <FILE>"); exit; }
if(! defined $fOut) { Usage("Missing Option: -out <FILE>"); exit; }
if(! defined $cutoff) { Usage("Did not specificy cutoff count: -cutoff"); exit; }

# File checks
if(! -e $fPairs)  { Usage("Input file does not exist: $fPairs"); exit; }
if(! -e $fLabel) { Usage("Input file does not exist: $fLabel"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }
if(-e $fOut)  { Usage("Output file already exists: $fOut"); exit; }
if(($cutoff * 1) != $cutoff)   { Usage("Cutoff isn't a number: $cutoff"); exit; }

# Put information from fLabel into conversion hash
my %labels = (); 
my %foundlabels = ();

open(LABELS, $fLabel) or die "Cannot open $fLabel\n";
	while ( my $line = <LABELS> )											
	{        
		chomp $line; 
		(my $ID, my $information) = split(/\t/, $line); 
		$labels{$ID} = $information;
	}  
close(LABELS);

#print "Reference labels were\n";
#	my @checkkeys = keys(%labels);
#	@checkkeys = sort(@checkkeys); 
#	
#	foreach my $key ( @checkkeys )
#	{
#		my $value = $labels{$key};
#		print "$key\t$value\n";
#	}

# For each line, separate the values
# Only do anything when value is below cutoff
# Stop everything if mismatch is found
# Assign lineage to other id if one lineage defined per match 
open(INFILE, $fPairs) or die "Cannot open $fPairs\n";
	<INFILE>;
	while ( my $line = <INFILE> )											
	{        
		chomp($line);
		my ($useless, $firstid, $secondid, $dissvalue) = split(/,/, $line);

		if ( $dissvalue <= $cutoff )
		{
			if ( exists $labels{$firstid} && exists $labels{$secondid} )
			{
				#print "$firstid and $secondid both already defined. Lineages are $labels{$secondid} and $labels{$firstid}.\n";
				if ( $labels{$firstid}  =! $labels{$secondid} )
				{ print "Mismatch for ids $firstid and $secondid"; exit; }
			}
			elsif ( exists $labels{$firstid} )
			{
				#print "Only $firstid defined.\n";
				$foundlabels{$secondid} = $labels{$firstid};
			}
			elsif ( exists $labels{$secondid} )
			{
				#print "Only $secondid defined.\n";
				$foundlabels{$firstid} = $labels{$secondid};
			}
			else 
			{
				# print "Both undefined, nothing happens.\n";
			}
	       	}
	       	else 
		{
			# print "Match for $firstid and $secondid had value $dissvalue above cutoff $cutoff.\n";
		}
	}  
close(INFILE);

# printing out the resulting hash
my @hashkeys = keys(%foundlabels);
@hashkeys = sort(@hashkeys); 

open(OUTFILE, '>>', $fOut); 
	foreach my $key ( @hashkeys )
	{
		my $value = $foundlabels{$key};
		print OUTFILE "$key\t$value\n";
	}
close(OUTFILE); 

print "All done! Results are at $fOut.\n";

#---------------------------------------------------------------
# Subroutines
#---------------------------------------------------------------

sub Usage( ; $ )
{
	my $message = $_[0] || '';

	print << 'EOU';

assign-labels-s2.pl
print "Quit because: $message\n";

Description: assigns labels based on pairwise distances, cutoff and known labels 
	
	
Usage:
assign-labels-s2.pl [ options ]

-in		<FILE> - input filename
-label		<FILE> - input filename
-out		<FILE> - output filename
-cutoff		number where groups cut off in dissimilarity matrix
-h		- print usage instructions

EOU

print "Quit because: $message\n";
print "ARGV was " . join (", ", @ARGV) . "\n";
}
