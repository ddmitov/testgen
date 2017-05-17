#!/usr/bin/perl

use strict;
use warnings;
use utf8;
binmode STDOUT, ":utf8";
use JSON::PP;

# http://blog-en.openalfa.com/how-to-read-and-write-json-files-in-perl

my $filename = $ARGV[0];
open my $input_filehandle, "<:encoding(UTF-8)", $filename or
  die "File not found. Aborting";
$/ = undef;
my $json_data = <$input_filehandle>;
close $input_filehandle;

my $json_object = JSON::PP->new;
my $questions = $json_object->decode($json_data);

print "\n";

for (my $number=1; $number <= 99; $number++) {
  $number = sprintf ("%02d", $number);
  if (defined ($questions->{$number})) {
    print "ID: $number\n";
    print "Question: $questions->{$number}{question}\n";
    print "Question type: $questions->{$number}{question_type}\n";
    print "Date: $questions->{$number}{date}\n";
    if (defined ($questions->{$number}{answers})) {
      print "Answers:\n";
      print "a) $questions->{$number}{answers}{1}\n";
      print "b) $questions->{$number}{answers}{2}\n";
      print "c) $questions->{$number}{answers}{3}\n";
      print "d) $questions->{$number}{answers}{4}\n";
    }
    print "\n";
  }
}
