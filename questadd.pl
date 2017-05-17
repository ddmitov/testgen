#!/usr/bin/perl

use strict;
use warnings;
use utf8;
binmode STDOUT, ":utf8";
use JSON::PP;

# http://blog-en.openalfa.com/how-to-read-and-write-json-files-in-perl
# http://blog.endpoint.com/2011/02/json-pretty-printer.html
# https://metacpan.org/pod/JSON::PP

my $filename = $ARGV[0];
open my $input_filehandle, "<:encoding(UTF-8)", $filename or
  die "File not found. Aborting";
$/ = undef;
my $json_data = <$input_filehandle>;
close $input_filehandle;

my $json_object = JSON::PP->new;
my $questions = $json_object->decode($json_data);

my $total_number_of_questions;
for (my $number=1; $number <= 99; $number++) {
  $number = sprintf ("%02d", $number);
  if (defined ($questions->{$number})) {
    if (length ($questions->{$number}->{question}) > 0) {
      $total_number_of_questions++;
    }
  }
}

my $new_question_number = $total_number_of_questions + 1;
print "\nOld number of questions: $total_number_of_questions\n";
print "New number of questions: $new_question_number\n\n";
$new_question_number = sprintf ("%02d", $new_question_number);

$questions->{$new_question_number}{question} = "Тестов въпрос";
$questions->{$new_question_number}{question_type} = "facts";
$questions->{$new_question_number}{date} = "1300";
$questions->{$new_question_number}{answers} = "";

my $pretty_json_data =
  $json_object->pretty->sort_by(sub {$JSON::PP::a cmp $JSON::PP::b})->encode($questions);

open my $output_filehandle, ">:encoding(UTF-8)", $filename or
  die "File not found. Aborting";
print $output_filehandle $pretty_json_data;
close $output_filehandle;
