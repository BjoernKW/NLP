#!/usr/bin/env perl

## N-Gram Model Processor
## Copyright 2007 by Bjoern Wilmsmann

# use packages for debugging
use strict;
use Data::Dumper;

# use option reader
use OptionReader;

# index variable
my $i;

# n-gram
my @ngram;

# tokens
my @tokens;

# last n - 1 tokens of a line
my @last;

# reference for n-grams
my $ngrams;

# n-gram total
my $ngramTotal;
my $nBar;

# reference for frequency classes
my $frequencyClasses;

# reference for probabilities
my $probabilities;

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

# reference for tag frequency classes
my $tagFrequencyClasses;

# reference for word frequency classes
my $wordFrequencyClasses;

# initialise option reader
my $optionReader = new OptionReader();
my $options;

# if no command line arguments have been supplied, print help and die afterwards
if (@ARGV <= 1) {
	print "Usage: nmp.pl --n N --input INPUT-FILE --tagging T --modules 0{SMOOTHING_MODULE}M --taggingmodule TAGGING_MODULE --sentence SENTENCE\n";
	exit(0);
} else {
	# set default options
	my @defaults = ("--n", 2, "--tagging", 0);

	# get options
	$options = $optionReader->getCommandLineArgs(\@defaults, \@ARGV);
}

# if one of the options required for tagging has not been set.
unless (defined($options->{input}) && defined($options->{n})) {
	print "Please set all obligatory options (--n and --input).\n";
	exit(0);
}

# if one of the options required for tagging has not been set.
unless (-e $options->{input}) {
	print "No valid input file has been provided.\n";
	exit(0);
}

# if one of the options required for tagging has not been set.
if (($options->{tagging} == 1 && ($options->{taggingmodule} eq "" || $options->{sentence} eq "")) ||
	($options->{tagging} != 1 && $options->{taggingmodule} ne "")) {
	print "Please set all options required for tagging (--tagging, --taggingmodule and --sentence).\n";
	exit(0);
}


## START: Read corpus and build n-gram model

# open input file, file name given via second command line argument
open(INPUT, $options->{input});

# get each line from file
foreach my $line (<INPUT>) {
	# cut off new line character
	chomp($line);

	# remove blank spaces at beginning of line
	$line =~ s/^\s+//g;

	# only process line if it is not empty and it does not only consist
	# of blank spaces
	unless ($line eq "") {
		# if tagging option was selected, use each line as a token
		# otherwise split line and push it to token array
		if ($options->{tagging} == 1) {
			# process only if line does not start with '#'
			unless ($line =~ /^[#%]/) {
				# cut off new line character
				chomp($line);
		
				# get word and tag
				$line =~ /^(.*?)\s+(.*?)\s+.*$/;
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
		} else {
			# remove punctuation
			$line =~ s/[:;.,?!]//g;
	
			# write last tokens of previous line to tokens and reset @last array
			@tokens = @last;
			@last   = ();
	
			# reset n-grams array
			@ngram = ();
	
			# push to token array
			push(@tokens, split(/\s+/, $line));
		}

		# initialise index variable
		$i = 0;

		# go through tokens
		foreach my $token (@tokens) {
			# push token to n-gram and increment index
			push(@ngram, $token);
			$i++;

			# if final token of this n-gram
			if (@ngram == $options->{n}) {
				# write n-gram to hash
				$ngrams->{"@ngram"}++;

				# shift from n-gram
				shift(@ngram);
				
				# increment n-gram total
				$ngramTotal++;
			}

		  	# push current token to @last if there are not enough tokens to form
		  	# another n-gram anymore, which then have to be moved to the following
		  	# line
			if (@tokens - $i < $options->{n} - 1) {
				push(@last, $token);
			}
		}
	}
}

# close input file
close(INPUT);

# iterate over n-grams for calculating equivalence classes
foreach my $ngramToken (keys(%{$ngrams})) {
	# increment cardinality of equivalence class
	$frequencyClasses->{$ngrams->{$ngramToken}}++;
}

# iterate over frequency classes to get un-smoothed probabilities
foreach my $frequency (keys(%{$frequencyClasses})) {
	$probabilities->{$frequency} = $frequency / $ngramTotal;
}

## END: Read corpus and build n-gram model


## START: training for tagging process

# if tagging option is set
if ($options->{tagging} == 1) {
	# iterate over tags in order to calculate probabilities
	foreach $previousTag (keys(%{$tags})) {
		# iterate over 'next' tags for this state
		foreach $tag (keys(%{$tags->{$previousTag}})) {
			# set probability for current 'next' tag for this state
			$tagProbabilities->{$previousTag}->{$tag} =
				$tags->{$previousTag}->{$tag} / $tagTotals->{$previousTag};
				
		# increment cardinality of frequency class for this state and its previous sate
			$tagFrequencyClasses->{$previousTag}->{$tags->{$previousTag}->{$tag}}++;
		}
		
		# iterate over emitted words for this state
		foreach $word (keys(%{$words->{$previousTag}})) {
			# set probability for current word emitted by this state
			$wordProbabilities->{$previousTag}->{$word} =
				$words->{$previousTag}->{$word} / $wordTotals->{$previousTag};
				
			# increment cardinality of frequency class for this state and its previous sate
			$wordFrequencyClasses->{$previousTag}->{$words->{$previousTag}->{$word}}++
		}
	}
}

## END: training for tagging process


## START: smoothing

# variable for package file names
my $includeName;

# get requested modules from command-line
my @smoothingModules = $options->{modules};

# iterate over modules
foreach my $moduleName (@smoothingModules) {
	# if module name is not empty
	unless ($moduleName eq"") {
		# build file name for package inclusion;
		$includeName = $moduleName;
		$includeName =~ s/::/\//g;
		$includeName .= ".pm";
	
		# use smoothing library
		require $includeName;
		import $moduleName;
	
		# if tagging option is set, perform smoothing on tag and word
		# probabilities, otherwise just smooth n-gram probabilitiees
		if ($options->{tagging} == 1) {
			# reserve module name
			my $moduleWord;
			my $moduleTag;
	
			# iterate over tags in order to calculate new probabilities for each state
			foreach $previousTag (keys(%{$tags})) {
				# only perform smoothing if more than or equal to 5 classes
				if (scalar(keys(%{$wordFrequencyClasses->{$previousTag}})) >= 5) {
					# instantiate class for word probabilities
					$moduleWord = new $moduleName($wordFrequencyClasses->{$previousTag}, $wordTotals->{$previousTag});
					
					# calculate smoothed values
					$moduleWord->calculateValues();
					
					# get smoothed values
					$probabilities = $moduleWord->getProbabilities();
					$frequencyClasses = $moduleWord->getNewFrequencies();
					
					# get pZero
					$wordProbabilities->{$previousTag}->{"pZero"} = $probabilities->{0};
					
					# iterate over emitted words for this state
					foreach $word (keys(%{$wordProbabilities->{$previousTag}})) {
						# adjust probability
						$wordProbabilities->{$previousTag}->{$word} = $probabilities->{$words->{$previousTag}->{$word}};
					}
				}
				
				# only perform smoothing if more than or equal to 5 classes
				if (scalar(keys(%{$tagFrequencyClasses->{$previousTag}})) >= 5) {
					# instantiate class for tag probabilities
					$moduleTag = new $moduleName($tagFrequencyClasses->{$previousTag}, $tagTotals->{$previousTag});
					
					# calculate smoothed values
					$moduleTag->calculateValues();
					
					# get smoothed values
					$probabilities = $moduleTag->getProbabilities();
					$frequencyClasses = $moduleTag->getNewFrequencies();
					
					# iterate over 'next' tags for this state
					foreach $tag (keys(%{$tagProbabilities->{$previousTag}})) {
						# adjust probability
						$tagProbabilities->{$previousTag}->{$tag} = $probabilities->{$tags->{$previousTag}->{$tag}};
					}
				}
			}
		} else {
			# reserve module name
			my $module;
	
			# instantiate class
			$module = new $moduleName($frequencyClasses, $ngramTotal);
			
			# calculate smoothed values
			$module->calculateValues();
			
			# get smoothed values
			$probabilities = $module->getProbabilities();
			$frequencyClasses = $module->getNewFrequencies();
		}
	}
}

## END: smoothing


## START: tagging

# define reference for delta values
my $delta;

# variable for package file name
my $includeNameTagging;

# if tagging option was selected
if ($options->{tagging} == 1) {
	# get taggin module from command-line
	my $taggingModule = $options->{taggingmodule};
	
	# build file name for package inclusion;
	$includeNameTagging = $taggingModule;
	$includeNameTagging =~ s/::/\//g;
	$includeNameTagging .= ".pm";

	# use tagging library
	require $includeNameTagging;
	import $taggingModule;
	
	# create new tagger
	my $tagger = new $taggingModule($options->{sentence}, $tagProbabilities, $wordProbabilities);
	
	# perform tagging
	$delta = $tagger->process();
}

## END: tagging


# open output file
open(OUTPUT, ">output.txt");

# if tagging option is set, print most likely tag sequences,
# otherwise print smoothed n-gram model
if ($options->{tagging} == 1) {
	# start output
	print OUTPUT "Result of tagging process:\n\n";
	
	## start read-out process
	
	# define arrays for ordered sequence of tags and words
	my @orderedWords;
	my @orderedTags;
	
	# define variable for error message
	my $errorMessage;
	
	# iterate over words in sentence
	$i = @{$options->{sentence}};
	while ($i > 0) {
		# decrement counter
		$i--;
	
		# check, if tag for word is known
		unless (keys(%{$delta->{$i}}) <= 0) {
			# set tag for current word
			unshift(@orderedTags, (sort {$delta->{$i}->{$b} <=> $delta->{$i}->{$a}} keys(%{$delta->{$i}}))[0]);
			
			# get current word
			$word = pop(@{$options->{sentence}});
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
			print OUTPUT $word . "\t" . shift(@orderedTags) . "\n";
		}
	} else {
		# print error message
		print OUTPUT $errorMessage . "\n";
	}
	
	## end read-out process
	
	
} else {
	# output n-gram model
	print OUTPUT "N: " . $options->{n}. "\n";
	print OUTPUT "N-gram;Frequency class;Cardinality;Probability;\n";
	foreach my $ngram (sort {$ngrams->{$b} <=> $ngrams->{$a}} keys(%{$ngrams})) {
		print OUTPUT $ngram . ";" . $ngrams->{$ngram} . ";" . $frequencyClasses->{$ngrams->{$ngram}} . ";" . $probabilities->{$ngrams->{$ngram}} . ";" . "\n";
	}
}

# close output file
close(OUTPUT);
