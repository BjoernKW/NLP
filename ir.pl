#!/usr/bin/env perl

use strict;
use Data::Dumper;

# one sentence
my @sentence;

# all sentences in a corpus
my @sentences;

# n-gram
my @ngram;

# tokens
my @tokens;

# model
my $model;

# similarity
my $similarity;

# n-grams
my $ngrams;
my $exampleNgrams;

# total values
my $totals;
my $exampleTotals;

# if insufficient command line arguments have been supplied, print help and die afterwards
if (@ARGV < 5) {
	print "Usage: ir.pl N THRESHOLD(-1 = NONE) MAX.RESULTS(-1 = UNLIMITED) INPUT-FILE EXAMPLE\n";
  	exit(0);
}

# get requested n-gram size from first command line argument
my $ngramSize = $ARGV[0];

# get requested threshold from second command line argument
my $threshold = $ARGV[1];

# get requested maximum number of results from third command line argument
my $maxResults = $ARGV[2];

# get input file from fourth command line argument
my $inputFile = $ARGV[3];

# get example from remaining command line arguments, convert them to lower-case
my $example = lc("@ARGV[4 .. @ARGV - 1]");

# remove punctuation from example
$example =~ s/[:;.,?!]//g;

# process example sentence
foreach my $sentenceToken (split(/\s+/, $example)) {
	# push token to n-gram
	push(@ngram, $sentenceToken);

	# if final token of this n-gram
	if (@ngram == $ngramSize) {
	    # increment n-gram frequency
		$exampleNgrams->{"@ngram[0 .. @ngram - 2]"}->{$ngram[@ngram - 1]}++;
			
		# increment total count
		$exampleTotals->{"@ngram[0 .. @ngram - 2]"}++;

		# shift from n-gram
		shift(@ngram);
	}
}

# open input file, file name given via second command line argument
open(INPUT, $inputFile);

# get each line from file
foreach my $line (<INPUT>) {
	# empty tokens array
	@tokens = ();
	
  	# cut off new line character
  	chomp($line);

 	# remove blank spaces at beginning of line
  	$line =~ s/^\s+//g;

  	# only process line if it is not empty and it does not only consist
 	# of blank spaces
  	unless ($line eq "") {
    	# split lower-case line and push it to token array
    	push(@tokens, split(/\s+/, lc($line)));

    	# go through tokens
    	foreach my $token (@tokens) {
    		# unless token contains punctuation
    		unless ($token =~ /(^.*)([.!?;:,])$/) {
				# push token to sentence
    	 		push(@sentence, $token);
    		} else {
    			# push token without punctuation to sentence 
    			push(@sentence, $1);
    			
    			# push this sentence to sentences array
    			push(@sentences, "@sentence");
    			
    			# reset n-gram and total values
    			$ngrams = {};
				$totals = {};
				@ngram = ();
				
				# iterate over each token in sentence
    			foreach my $sentenceToken (@sentence) {
					# push token to n-gram
	    			push(@ngram, $sentenceToken);

					# if final token of this n-gram
				    if (@ngram == $ngramSize) {
	    				# increment n-gram frequency
						$ngrams->{"@ngram[0 .. @ngram - 2]"}->{$ngram[@ngram - 1]}++;
			
						# increment total count
						$totals->{"@ngram[0 .. @ngram - 2]"}++;

						# shift from n-gram
						shift(@ngram);
					}
				}

				# initialise variables for cosine similarity
				my $scalarProductProb1Prob2 = 0;
				my $sumOfSquareProb1 = 0;
				my $sumOfSquareProb2 = 0;

				# iterate over all y's of P(x|y) in this sentence
				foreach my $given (keys(%{$ngrams})) {
					# iterate over all x's for given y
					foreach my $word (keys(%{$ngrams->{$given}})) {
						# update statistical model for this sentence with current x given y
						$model->{"@sentence"}->{$given . " " . $word} = $ngrams->{$given}->{$word} / $totals->{$given};
						
						# evaluate in order to catch division by zero
						eval {
							# calculate sums for cosine similarity
							$scalarProductProb1Prob2 += $model->{"@sentence"}->{$given . " " . $word} * $exampleNgrams->{$given}->{$word} / $exampleTotals->{$given};
							$sumOfSquareProb1 += $model->{"@sentence"}->{$given . " " . $word} ** 2;
							$sumOfSquareProb2 += ($exampleNgrams->{$given}->{$word} / $exampleTotals->{$given}) ** 2;
						};
					}
				}

				# evaluate in order to catch division by zero
				eval {
					# calculate cosine similarity for this sentence
					$similarity->{"@sentence"} = $scalarProductProb1Prob2 / sqrt ($sumOfSquareProb1 * $sumOfSquareProb2);
				};
				unless ($@ eq "") {
					# if division by zero (i.e. value not defined), similarity is 0
					$similarity->{"@sentence"} = 0;
				}
    			
    			# empty this sentence for next iteration
    			@sentence = ();
    		}
    	}
  	}
}

# close input file
close(INPUT);

# open output file
open(OUTPUT, ">output.txt");

# output sentences
if ($maxResults != -1) {
	# iterate over sorted sentences, using only $maxResults best results
	foreach my $sentence ((sort {$similarity->{$b} <=> $similarity->{$a}} @sentences)[0 .. $maxResults - 1]) {
 		# if similarity is lower than treshold value
 		if ($threshold != -1 && $similarity->{$sentence} < $threshold) {
 			last;
		}
 		print OUTPUT $sentence . ": " . $similarity->{$sentence} . "\n";
	}
} else {
	# iterate over sorted sentences
	foreach my $sentence (sort {$similarity->{$b} <=> $similarity->{$a}} @sentences) {
 		# if similarity is lower than treshold value
 		if ($threshold != -1 && $similarity->{$sentence} < $threshold) {
 			last;
		}
 		print OUTPUT $sentence . ": " . $similarity->{$sentence} . "\n";
	}
}

# close output file
close(OUTPUT);

