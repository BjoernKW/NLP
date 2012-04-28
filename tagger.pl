#!/usr/bin/env perl

use strict;
use Data::Dumper;

# index variable
my $i;

# variable for previous state
my $previousTag;

# variable for single word
my $word;

# variable for single tag
my $tag;

# reference for words
my $words;

# reference for tags
my $tags;

# reference for word totals
my $wordTotals;

# reference for tag totals
my $tagTotals;

# reference for tag probabilities
my $tagProbabilities;

# reference for word probabilities
my $wordProbabilities;

# if no command line arguments have been supplied, print help and die afterwards
if (@ARGV <= 1) {
	print "Usage: tagger.pl CORPUS-FILE SENTENCE\n";
	exit(0);
}


## get command line arguments

# get sentence
my @sentence = @ARGV[1..@ARGV - 1];

# open corpus file, file name given via first command line argument
open(CORPUS, $ARGV[0]);


## start of training process

# get each line from file
foreach (<CORPUS>) {
	# process only if line does not start with '#'
	unless (/^[#%]/) {
		# cut off new line character
		chomp;

		# get word and tag
		/^(.*?)\s+(.*?)\s+.*$/;
		$word = $1;
		$tag = $2;

		# if first iteration, previous tag is empty
		unless ($previousTag eq "") {
			# increment count for previousTag state and this state
			$tags->{$tag}->{$previousTag}++;
		
			# increment count for current word and current tag
			$words->{$tag}->{$word}++;
		
			# increment total counts
			$wordTotals->{$tag}++;
			$tagTotals->{$tag}++;
		}
	
		# set previousTag state for next iteration
		$previousTag = $tag;
	}
}

# close corpus file
close(CORPUS);

# iterate over tags in order to calculate probabilities
foreach $previousTag (keys(%{$tags})) {
	# iterate over 'next' tags for this state
	foreach $tag (keys(%{$tags->{$previousTag}})) {
		# set probability for current 'next' tag for this state
		$tagProbabilities->{$previousTag}->{$tag} =
			$tags->{$previousTag}->{$tag} / $tagTotals->{$previousTag};
	}
	
	# iterate over emitted words for this state
	foreach my $word (keys(%{$words->{$previousTag}})) {
		# set probability for current word emitted by this state
		$wordProbabilities->{$previousTag}->{$word} =
			$words->{$previousTag}->{$word} / $wordTotals->{$previousTag};
	}
}

## end of training process


## start actual tagging process (Viterbi algorithm)

# set counter
$i = 0;

# define variables
my $currentMaxProbability = 1;
my $jointProbability;
my $delta;
my $psi;

# iterate over words in sentence
foreach $word (@sentence) {
	# iterate over all tags
	foreach $previousTag (keys(%{$tags})) {
		# iterate over tags for each tag
		foreach $tag (keys(%{$tags->{$previousTag}})) {
			# transition probability
			$jointProbability = $currentMaxProbability *
				$wordProbabilities->{$tag}->{$word} *
				$tagProbabilities->{$previousTag}->{$tag};

			# if there is a value for $delta->{$i}->{$tag},
			# compare with joint probability. If joint probability
			# is larger or delta for this tag is non-existent,
			# use it as delta value and current tag as psi value
			# (the previous state which maximises the current delta)
			if ($delta->{$i}->{$tag} < $jointProbability) {
				$currentMaxProbability = $jointProbability;
				$delta->{$i}->{$tag} = $currentMaxProbability;
				$psi->{$i}->{$tag} = $previousTag;
			}
		}
	}
	$i++;
}

## end tagging process


## start read-out process

# define arrays for ordered sequence of tags and words
my @orderedWords;
my @orderedTags;

# define variable for error message
my $errorMessage;

# iterate over words in sentence
while ($i > 0) {
	# decrement counter
	$i--;

	# check, if tag for word is known
	unless (keys(%{$delta->{$i}}) <= 0) {
		# set tag for current word
		unshift(@orderedTags, (sort {$delta->{$i}->{$b} <=> $delta->{$i}->{$a}} keys(%{$delta->{$i}}))[0]);
		
		# get current word
		$word = pop(@sentence);
		unshift(@orderedWords, $word);
	} else {
		# write error message and leave loop
		$errorMessage = "The sentence contains unknown words and hence cannot be tagged.";
		last;
	}
}

# check if sentence was tagged without error
if ($errorMessage eq "") {
	# iterate over words
	foreach $word (@orderedWords) {
		# words and tags
		print $word . "\t" . shift(@orderedTags) . "\n";
	}
} else {
	# print error message
	print $errorMessage . "\n";
}

## end read-out process
