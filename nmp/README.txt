
	N-gram Model Processor (NMP)
	-------------------------------
	
	28 Feb 2007
	
	Copyright 2007, Bjoern Wilmsmann
	
	
	Introduction
	-------------
	N-gram Model Processor is a command line tool (written in Perl) for creating and using language models.
	It can be used for deriving an n-gram language model from a given corpus. Furthermore, NMP sports
	an interface for application of statistical smoothing algorithms.
	Finally, it is also capable of POS-tagging a sentence supplied via command line argument, given an
	appropriately tagged corpus as input.
	
	
	Usage
	-------------
	NMP can be called with the following command line arguments, the first two of which are obligatory
	in any case (if a.) is not supplied, it defaults to 2), while c.) and d.) are both obligatory when
	using the tagging option:
	
		a.) --n N
			This argument signifies the n-gram length. When using the tagging option this should usually be
			set to 1.

		b.) --input INPUT-FILE
			This means the input corpus, which can either be a plain text file or a corpus tagged
			according to the TIGER corpus format (see http://www.ims.uni-stuttgart.de/projekte/TIGER/TIGERCorpus/
			for further information).
			
		c.) --tagging T
			This toggles between tagging on (1) or off (0). This one defaults to 0.
			
		d.) --taggingmodule TAGGING_MODULE
			This argument is obligatory if the tagging option is set to 1. It provides the name of the
			tagging module to use. The default tagging module supplied with this package is called
			Tagger.pm and implements the Viterbi Algorithm on a Hidden Markov Model.
			
		e.) --modules 0{SMOOTHING_MODULE}M
			With this argument the user can supply optional modules for smoothing the statistical values
			for the n-gram model. In order to be eligible for this interface the constructor of the
			implementing class has to take frequency classes and the total number of n-grams as arguments
			and the class must supply the methods calculateValues(), getProbabilities() and
			getNewFrequencies(). For an example, see the Statistics::Smoothing::SGT CPAN module.
			
		f.) --sentence SENTENCE
			This argument is obligatory if the application is to be used as a tagger and provides the
			sentence to be tagged according to the language model found in the input corpus.
	
	Any results will be written to a file called output.txt in the directory nmp.pl has been started in.
	
	
	Usage Examples
	-------------
	Standard mode: nmp.pl --n 2 --input corpus.txt --modules Statistics::Smoothing::SGT
					(bigrams with SGT smoothing)
	Tagging mode: perl nmp.pl --n 1 --input tiger.txt --modules Statistics::Smoothing::SGT --tagging 1
					--taggingmodule Tagger --sentence This is just a test
					(unigrams with SGT smoothing, using the standard tagging module for tagging the
					sentence 'This is just a test')
	
	
	Components
	------------
	NMP consists of the following components:
	
		a.) nmp.pl: The main program file
		b.) OptionReader.pm: A module used for storing command line arguments in an easily accessible data
		structure.
		c.) Tagger.pm: The tagging module supplied with this package.
	
	Moreover, the package obviously also contains this README file.
	The optional Statistics::Smoothing::SGT module mentioned above is highly recommended for use with NMP.

