#!/usr/bin/env perl

use strict;
use warnings;
use JSON::PP;

# http://perlmaven.com/perl-arrays
# http://perlmaven.com/splice-to-slice-and-dice-arrays-in-perl
# http://perlmaven.com/how-to-get-index-of-element-in-array
# http://www.perlmonks.org/?node_id=50396
# https://www.stormconsultancy.co.uk/blog/development/code-snippets/perl-sorting-an-array-of-hashes/

##################################################
my $wanted_tests = 10;
my $wanted_open_questions = 5;
my $wanted_closed_questions = 5;
##################################################

my $file = $ARGV[0];
open my $filehandle, '<', $file or
  die "File not found. Aborting";
$/ = undef;
my $json_data = <$filehandle>;
close $filehandle;

my $json_object = new JSON::PP;
my $questions = $json_object->decode($json_data);

my $available_closed_questions;
my $available_open_questions;
my @question_numbers;

for (my $number = 1; $number <= 99; $number++) {
  $number = sprintf ("%02d", $number);
  if (defined ($questions->{$number})) {
    if (length ($questions->{$number}->{question}) > 0) {
      my $question_type = $questions->{$number}{question_type};
      push @question_numbers, $number;

      if ($question_type =~ "closed") {
        $available_closed_questions++;
      }

      if ($question_type =~ "open") {
        $available_open_questions++;
      }
    }
  }
}

my $errors = 0;
if ($wanted_closed_questions > $available_closed_questions) {
  $errors = 1;
  my $defficient_closed_questions =
    $wanted_closed_questions - $available_closed_questions;
  print "\n";
  print "Недостигащи затворени въпроси: $defficient_closed_questions\n";
}

if ($wanted_open_questions > $available_open_questions) {
  $errors = 1;
  my $defficient_open_questions =
    $wanted_open_questions - $available_open_questions;
  print "\n";
  print "Недостигащи отворени въпроси: $defficient_open_questions\n";
}

if ($errors == 1) {
  print "\n";
  exit;
}

print "\n";
print "Затворени въпроси: $available_closed_questions\n";
print "Отворени въпроси: $available_open_questions\n";

for (my $test_number = 1; $test_number <= $wanted_tests; $test_number++) {
  print "\nВариант $test_number\n\n";

  my $test_data = $json_object->decode($json_data);
  my @questions;
  my $closed_questions = 0;
  my $open_questions = 0;

  until ($closed_questions == $wanted_closed_questions) {
    my $random_question_number = $question_numbers [rand @question_numbers];

    if (defined ($test_data->{$random_question_number})) {
      my $random_question = $test_data->{$random_question_number}{question};
      my $question_type = $test_data->{$random_question_number}{question_type};
      my $date = $test_data->{$random_question_number}{date};

      if ($question_type =~ "closed") {
        $closed_questions++;
        my $variant_a;
        my $variant_b;
        my $variant_c;
        my $variant_d;

        if ($question_type !~ "chronology") {
          my @range = (1 .. 4);
          my @uniq_numbers;
          until (scalar @uniq_numbers == scalar @range) {
            my $random_number = $range[rand(@range)];
            if (not grep /$random_number/, @uniq_numbers) {
              push @uniq_numbers, $random_number;
            }
          }

          $variant_a =
            $test_data->{$random_question_number}{answers}{$uniq_numbers[0]};
          $variant_b =
            $test_data->{$random_question_number}{answers}{$uniq_numbers[1]};
          $variant_c =
            $test_data->{$random_question_number}{answers}{$uniq_numbers[2]};
          $variant_d =
            $test_data->{$random_question_number}{answers}{$uniq_numbers[3]};
        } else {
          $variant_a = $test_data->{$random_question_number}{answers}{1};
          $variant_b = $test_data->{$random_question_number}{answers}{2};
          $variant_c = $test_data->{$random_question_number}{answers}{3};
          $variant_d = $test_data->{$random_question_number}{answers}{4};
        }

        push @questions,
              {question => $random_question,
                variant_a => $variant_a,
                variant_b => $variant_b,
                variant_c => $variant_c,
                variant_d => $variant_d,
                date => $date};

        delete $test_data->{$random_question_number};
      }
    }
  }

  until ($open_questions == $wanted_open_questions) {
    my $random_question_number = $question_numbers[rand @question_numbers];

    if (defined ($test_data->{$random_question_number})) {
      my $random_question = $test_data->{$random_question_number}{question};
      my $question_type = $test_data->{$random_question_number}{question_type};
      my $date = $test_data->{$random_question_number}{date};

      if ($question_type =~ "open") {
        $open_questions++;
        push @questions, {question => $random_question, date => $date};
      }

      delete $test_data->{$random_question_number};
    }
  }

  my @sorted_questions = sort {$a->{date} <=> $b->{date}} @questions;

  for my $question_number (0 .. $#sorted_questions) {
    my $real_question_number = $question_number + 1;
    my $question =
      $real_question_number.". ".$sorted_questions[$question_number]{question};
    print "$question\n";

    if (defined ($sorted_questions[$question_number]{variant_a})) {
      print "а) $sorted_questions[$question_number]{variant_a}, ";
    }
    if (defined ($sorted_questions[$question_number]{variant_b})) {
      print "б) $sorted_questions[$question_number]{variant_b}, ";
    }
    if (defined ($sorted_questions[$question_number]{variant_c})) {
      print "в) $sorted_questions[$question_number]{variant_c}, ";
    }
    if (defined ($sorted_questions[$question_number]{variant_d})) {
      my $answer =
        "г) ".$sorted_questions[$question_number]{variant_d}.".\n";
      $answer =~ s/\.\.\n/\.\n/;
      print $answer;
    }

    print "\n";
  }
}
