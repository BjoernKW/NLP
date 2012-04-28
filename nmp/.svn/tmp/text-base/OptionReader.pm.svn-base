## Copyright 2007, Bjoern Wilmsmann

package OptionReader;

# use strict, as we do not our variables to go haywire
use strict;

# use this for debugging purposes
use warnings;

our($VERSION);

$VERSION = '0.0.1';

# constructor
sub new {
	my %options;
	my ($class) = @_;
	my $self = {
		options => \%options
	};
	bless($self, $class);
	return $self;
}

# function for getting command line arguments
sub getCommandLineArgs {
	my $key;
	my $isValue = 0;
	my @values;
	my %splitThese;
	my ($self, $defaults, $argv) = @_;

	# go through default arguments
	foreach my $arg (@{$defaults}) {
		if ($arg =~ /^-+(.*)$/) {
			$key = $1;
			$self->{options}->{$key} = 1;
			
			# this is an option name, no value
			$isValue = 0;
		} else {
			$self->{options}->{$key} = $arg;
			
			# this is an option value, however a default one, so cardinality cannot be > 1
			$isValue = 2;
		}
	}

	# go through command line arguments
	foreach my $arg (@{$argv}) {
		if ($arg =~ /^-+(.*)$/) {
			$key = $1;
			$self->{options}->{$key} = 1;
			$isValue = 0;
		} else {
			# check if several values for one argument have been sent.
			# if yes ($isValue == 1), append them and mark them for later
			# processing 
			if ($isValue == 0) {
				$self->{options}->{$key} = $arg;
			}
			if ($isValue == 1) {
				$self->{options}->{$key} .= " " . $arg;
				$splitThese{$key} = 1;
			}

			# this is an option value, so cardinality can be > 1
			$isValue = 1;
		}
	}
	
	# go through arguments with several values
	foreach my $splitThis (keys(%splitThese)) {
		@values = split(/ /, $self->{options}->{$splitThis});
		$self->{options}->{$splitThis} = \@values;
	}

	# return options
	return $self->{options};
}

1;

__END__

