#!/usr/bin/env perl

use strict;
use warnings;
use JSON::PP;

# CREDITS:
# https://www.stormconsultancy.co.uk/blog/development/code-snippets/perl-sorting-an-array-of-hashes/

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
        push @questions,
          {question_type => $question_type,
          date => $date,
          question => $question,
          answers => {
            1 => $questions->{$number}{answers}{1},
            2 => $questions->{$number}{answers}{2},
            3 => $questions->{$number}{answers}{3},
            4 => $questions->{$number}{answers}{4}
            }
          };
      } else {
        push @questions,
          {question_type => $question_type,
            date => $date,
            question => $question
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
    push @final_questions,
      {$formatted_number => {
        question_type => $question_type,
        date => $date,
        question => $question_text,
        answers => {
          1 => $question->{answers}{1},
          2 => $question->{answers}{2},
          3 => $question->{answers}{3},
          4 => $question->{answers}{4}
          }
        }
      };
  } else {
    push @final_questions,
      {$formatted_number => {
          question_type => $question_type,
          date => $date,
          question => $question_text
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
  die "File not found. Aborting";
print $output_filehandle $final_data;
close $output_filehandle;
