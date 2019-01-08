#!/usr/bin/env perl

use strict;
use warnings;
use JSON::PP;

# To sort all files in a directory recursively:
# for file in $(find . -type f -name '*.json'); do ./testsort.pl $file; done

# CREDITS:
# https://www.stormconsultancy.co.uk/blog/development/code-snippets/perl-sorting-an-array-of-hashes/
# https://unix.stackexchange.com/questions/4382/how-to-open-multiple-files-from-find-output

my $filename = $ARGV[0];
open my $filehandle, '<', $filename or
  die "File not found. Aborting";
$/ = undef;
my $json_data = <$filehandle>;
close $filehandle;

my $json_object = new JSON::PP;
my $questions = $json_object->decode($json_data);

my @questions;

for (my $number = 1; $number <= 99; $number++) {
  $number = sprintf ("%02d", $number);
  if (defined ($questions->{$number})) {
    if (length ($questions->{$number}->{question}) > 0) {
      my $question_type = $questions->{$number}{question_type};
      my $date = $questions->{$number}{date};
      my $question = $questions->{$number}{question};

      if ($question_type =~ "closed") {
        push @questions, {
          date => $date,
          question => $question,
          question_type => $question_type,
          variants => {
            1 => $questions->{$number}{variants}{1},
            2 => $questions->{$number}{variants}{2},
            3 => $questions->{$number}{variants}{3},
            4 => $questions->{$number}{variants}{4}
          }
        };
      } else {
        push @questions, {
          date => $date,
          question => $question,
          question_type => $question_type
        };
      }
    }
  }
}

my @sorted_questions = sort {$a->{date} <=> $b->{date}} @questions;

my $number;
my @final_questions;

foreach my $question (@sorted_questions) {
  $number++;
  my $formatted_number = sprintf ("%02d", $number);

  my $question_type = $question->{question_type};
  my $date = $question->{date};
  my $question_text = $question->{question};

  if ($question_type =~ "closed") {
    push @final_questions, {
      $formatted_number => {
        date => $date,
        question => $question_text,
        question_type => $question_type,
        variants => {
          1 => $question->{variants}{1},
          2 => $question->{variants}{2},
          3 => $question->{variants}{3},
          4 => $question->{variants}{4}
        }
      }
    };
  } else {
    push @final_questions, {
      $formatted_number => {
        date => $date,
        question => $question_text,
        question_type => $question_type
      }
    };
  }
}

my $final_data;

foreach my $final_question (@final_questions) {
  my $pretty_json_data =
    $json_object->pretty->sort_by(
      sub {$JSON::PP::a cmp $JSON::PP::b})->encode($final_question);
  $final_data = $final_data.$pretty_json_data;
}

$final_data =~ s/\}\n\}\n\{/\},\n/g;

open my $output_filehandle, ">", $filename or
  die "Can not recreate file. Aborting";
print $output_filehandle $final_data;
close $output_filehandle;
