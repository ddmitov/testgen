#!/usr/bin/perl

use strict;
use warnings;
use utf8;
binmode STDOUT, ":utf8";
use JSON::PP;

# http://blog-en.openalfa.com/how-to-read-and-write-json-files-in-perl

my $filename = $ARGV[0];
open my $input_filehandle, "<:encoding(UTF-8)", $filename or die "File not found. Aborting";
$/ = undef;
my $json_data = <$input_filehandle>;
close $input_filehandle;

my $json_object = JSON::PP->new;
my $perl_data = $json_object->decode($json_data);

print "\n";

for (my $number=1; $number <= 99; $number++) {
	$number = sprintf ("%02d", $number);
	if (defined ($perl_data->{$number})) {
		print "ID: $number\n";
		print "Question: $perl_data->{$number}{question}\n";
		print "Question type: $perl_data->{$number}{question_type}\n";
		print "Date: $perl_data->{$number}{date}\n";
		if (defined ($perl_data->{$number}{answers})) {
			print "Answers:\n";
			print "a) $perl_data->{$number}{answers}{1}\n";
			print "b) $perl_data->{$number}{answers}{2}\n";
			print "c) $perl_data->{$number}{answers}{3}\n";
			print "d) $perl_data->{$number}{answers}{4}\n";
		}
		print "\n";
	}
}
