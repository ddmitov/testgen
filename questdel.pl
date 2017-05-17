#!/usr/bin/perl

use strict;
use warnings;
use utf8;
binmode STDOUT, ":utf8";
use JSON::PP;

# http://blog-en.openalfa.com/how-to-read-and-write-json-files-in-perl
# http://blog.endpoint.com/2011/02/json-pretty-printer.html
# https://metacpan.org/pod/JSON::PP
# http://stackoverflow.com/questions/1490356/how-to-replace-a-perl-hash-key

my $filename = $ARGV[0];
open my $input_filehandle, "<:encoding(UTF-8)", $filename or
  die "File not found. Aborting";
$/ = undef;
my $old_json_data = <$input_filehandle>;
close $input_filehandle;

my $old_json_object = JSON::PP->new;
my $old_questions = $old_json_object->decode($old_json_data);

delete $old_questions->{"04"};

my $minimal_json_data = "{}";
my $new_json_object = JSON::PP->new;
my $new_questions = $old_json_object->decode($minimal_json_data);

my $real_number;
for (my $number = 1; $number <= 99; $number++) {
  $number = sprintf ("%02d", $number);
  if (defined ($old_questions->{$number})) {
    if (length ($old_questions->{$number}->{question}) > 0) {
      $real_number++;
      $real_number = sprintf ("%02d", $real_number);
      $new_questions->{$real_number} = $old_questions->{$number};
    }
  }
}

my $pretty_json_data =
  $new_json_object->pretty->sort_by(sub {$JSON::PP::a cmp $JSON::PP::b})->encode($new_questions);

open my $output_filehandle, ">:encoding(UTF-8)", $filename or
  die "File not found. Aborting";
print $output_filehandle $pretty_json_data;
close $output_filehandle;
