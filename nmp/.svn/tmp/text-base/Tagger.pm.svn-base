## Copyright 2007, Bjoern Wilmsmann

package Tagger;

# use strict, as we do not our variables to go haywire
use strict;

# use these for debugging purposes
use warnings;
use Data::Dumper;

our ($VERSION);

$VERSION = '0.0.1';

# constructor
sub new {
	my ($class, $sentence, $tagProbabilities, $wordProbabilities) = @_;
	my $self = {
		sentence => $sentence,
		tagProbabilities => $tagProbabilities,
		wordProbabilities => $wordProbabilities
	};
	bless($self, $class);
	return $self;
}

# tagging method
sub process {
	my ($self) = @_;

	# index variable
	my $i;
	
	# variable for previous state
	my $previousTag;
	
	# variable for single word
	my $word;
	
	# variable for single tag
	my $tag;
	
	
	## start actual tagging process (Viterbi algorithm)
	
	# set counter
	$i = 0;
	
	# define variables
	my $currentMaxProbability = 1;
	my $wordProbability;
	my $jointProbability;
	my $delta;
	my $psi;
	
	# iterate over words in sentence
	foreach $word (@{$self->{sentence}}) {
		# iterate over all tags
		foreach $previousTag (keys(%{$self->{tagProbabilities}})) {
			# iterate over tags for each tag
			foreach $tag (keys(%{$self->{tagProbabilities}->{$previousTag}})) {
				# initialise delta value;
				unless (defined($delta->{$i}->{$tag})) {
					$delta->{$i}->{$tag} = 0;
				}

				# check if word is known for this tag, otherwise use
				# pZero value
				if (defined($self->{wordProbabilities}->{$tag}->{$word})) {
					$wordProbability = $self->{wordProbabilities}->{$tag}->{$word};
				} else {
					if (defined($self->{wordProbabilities}->{$tag}->{"pZero"})) {
						$wordProbability = $self->{wordProbabilities}->{$tag}->{"pZero"};
					} else {
						$wordProbability = 0;
					}
				}
				
				# transition probability
				$jointProbability = $currentMaxProbability * $wordProbability *
					$self->{tagProbabilities}->{$previousTag}->{$tag};
	
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
	
	
	# return
	return $delta;
}
