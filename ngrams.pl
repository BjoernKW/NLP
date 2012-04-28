#!/usr/bin/env perl

use strict;
use Data::Dumper;

# index variable
my $i;

# n-gram
my @ngram;

# tokens
my @tokens;

# last n - 1 tokens of a line
my @last;

# n-grams
my %ngrams;

# if no command line arguments have been supplied, print help and die afterwards
if (@ARGV <= 1) {
	print "Usage: ngram.pl N INPUT-FILE\n";
	exit(0);
}

# get requested n-gram size from first command line argument
my $ngramSize = $ARGV[0];

# open input file, file name given via second command line argument
open(INPUT, $ARGV[1]);

# get each line from file
foreach my $line (<INPUT>) {

	# cut off new line character
	chomp($line);

	# remove blank spaces at beginning of line
	$line =~ s/^\s+//g;

	# only process line if it is not empty and it does not only consist
	# of blank spaces
	unless ($line eq "") {

		# remove punctuation
		$line =~ s/[:;.,?!]//g;

		# write last tokens of previous line to tokens and reset @last array
		@tokens = @last;
		@last   = ();

		# reset n-grams array
		@ngram = ();

		# split line and push it to token array
		push(@tokens, split( /\s+/, $line ));

		# initialise index variable
		$i = 0;

		# go through tokens
		foreach my $token (@tokens) {

			# push token to n-gram and increment index
			push(@ngram, $token);
			$i++;

			# if final token of this n-gram
			if (@ngram == $ngramSize) {

				# write n-gram to hash
				$ngrams{"@ngram"}++;

				# shift from n-gram
				shift(@ngram);
			}

		  	# push current token to @last if there are not enough tokens to form
		  	# another n-gram anymore, which then have to be moved to the following
		  	# line
			if (@tokens - $i < $ngramSize - 1) {
				push(@last, $token);
			}
		}
	}
}

# close input file
close(INPUT);

# open output file
open(OUTPUT, ">output.txt");

# output n-grams
foreach my $ngramToken (keys(%ngrams)) {
	print OUTPUT $ngramToken . "\t" . $ngrams{$ngramToken} . "\n";
}

# close output file
close(OUTPUT);

