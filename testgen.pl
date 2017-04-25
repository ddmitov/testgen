#!/usr/bin/env perl

use strict;
use warnings;
use List::MoreUtils qw(first_index);
use JSON::PP;

# http://perlmaven.com/perl-arrays
# http://perlmaven.com/splice-to-slice-and-dice-arrays-in-perl
# http://perlmaven.com/how-to-get-index-of-element-in-array
# http://www.perlmonks.org/?node_id=50396
# https://www.stormconsultancy.co.uk/blog/development/code-snippets/perl-sorting-an-array-of-hashes/

##################################################

my $number_of_wanted_tests = 10;
my $number_of_wanted_open_questions_per_test = 5;
my $number_of_wanted_closed_questions_per_test = 5;

##################################################

my $file = $ARGV[0];
open my $filehandle, '<', $file or die;
$/ = undef;
my $json_data = <$filehandle>;
close $filehandle;

my $json_object = new JSON::PP;
my $perl_data = $json_object->decode($json_data);

my $number_of_available_closed_questions;
my $number_of_available_open_questions;
my @all_valid_question_numbers;

for (my $number=1; $number <= 99; $number++) {
	$number = sprintf ("%02d", $number);
	if (defined ($perl_data->{$number})) {
		if (length ($perl_data->{$number}->{question}) > 0) {
			my $question_type = $perl_data->{$number}{question_type};

			if ($question_type =~ "closed") {
				$number_of_available_closed_questions++;
				push @all_valid_question_numbers, $number;
			}

			if ($question_type =~ "open") {
				$number_of_available_open_questions++;
				push @all_valid_question_numbers, $number;
			}
		}
	}
}

my $errors = 0;
if ($number_of_wanted_closed_questions_per_test > $number_of_available_closed_questions) {
	$errors = 1;
	my $number_of_defficient_closed_questions =
		$number_of_wanted_closed_questions_per_test - $number_of_available_closed_questions;
	print "\n";
	print "Недостигащи затворени въпроси: $number_of_defficient_closed_questions\n";
}

if ($number_of_wanted_open_questions_per_test > $number_of_available_open_questions) {
	$errors = 1;
	my $number_of_defficient_open_questions =
		$number_of_wanted_open_questions_per_test - $number_of_available_open_questions;
	print "\n";
	print "Недостигащи отворени въпроси: $number_of_defficient_open_questions\n";
}

if ($errors == 1) {
	print "\n";
	exit;
}

print "\n";
print "Затворени въпроси: $number_of_available_closed_questions\n";
print "Отворени въпроси: $number_of_available_open_questions\n";

for (my $test_number=1; $test_number <= $number_of_wanted_tests; $test_number++) {
	print "\nВариант $test_number\n\n";

	my @questions;
	my @all_question_numbers = @all_valid_question_numbers;
	my $number_of_closed_questions = 0;
	my $number_of_open_questions = 0;

	until ($number_of_closed_questions == $number_of_wanted_closed_questions_per_test) {
		my $random_question_number = $all_question_numbers [rand @all_question_numbers];
		my $random_question;
		my $question_type;
		my $date;

		if (defined ($perl_data->{$random_question_number})) {
			$random_question = $perl_data->{$random_question_number}{question};
			$question_type = $perl_data->{$random_question_number}{question_type};
			$date = $perl_data->{$random_question_number}{date};

			if ($question_type =~ "closed") {
				$number_of_closed_questions++;
				my @all_variant_numbers = 1..4;
				my $variant_a;
				my $variant_b;
				my $variant_c;
				my $variant_d;

				if ($question_type !~ "chronology") {
					for (my $answer_number = 1; $answer_number <= 4; $answer_number++) {
						my $random_answer_number = $all_variant_numbers [rand @all_variant_numbers];

						my $random_answer_index = first_index {$_ eq $random_answer_number} @all_variant_numbers;
						if (scalar @all_variant_numbers > 1) {
							splice @all_variant_numbers, $random_answer_index, 1;
						}

						my $random_answer = $perl_data->{$random_question_number}{answers}{$random_answer_number};

						if ($answer_number == 1) {
							$variant_a = $random_answer;
						}
						if ($answer_number == 2) {
							$variant_b = $random_answer;
						}
						if ($answer_number == 3) {
							$variant_c = $random_answer;
						}
						if ($answer_number == 4) {
							$variant_d = $random_answer;
						}
					}
				} else {
					$variant_a = $perl_data->{$random_question_number}{answers}{1};
					$variant_b = $perl_data->{$random_question_number}{answers}{2};
					$variant_c = $perl_data->{$random_question_number}{answers}{3};
					$variant_d = $perl_data->{$random_question_number}{answers}{4};
				}

				push @questions, {question => $random_question,
								variant_a => $variant_a,
								variant_b => $variant_b,
								variant_c => $variant_c,
								variant_d => $variant_d,
								date => $date};

				my $random_question_index = first_index {$_ eq $random_question_number} @all_question_numbers;
				if (scalar @all_question_numbers > 1) {
					splice @all_question_numbers, $random_question_index, 1;
				}
			}
		}
	}

	until ($number_of_open_questions == $number_of_wanted_open_questions_per_test) {
		my $random_question_number = $all_question_numbers[rand @all_question_numbers];
		my $random_question;
		my $question_type;
		my $date;

		if (defined ($perl_data->{$random_question_number})) {
			$random_question = $perl_data->{$random_question_number}{question};
			$question_type = $perl_data->{$random_question_number}{question_type};
			$date = $perl_data->{$random_question_number}{date};

			if ($question_type =~ "open") {
				$number_of_open_questions++;
				push @questions, {question => $random_question, date => $date};

				my $random_question_index = first_index {$_ eq $random_question_number} @all_question_numbers;
				if (scalar @all_question_numbers > 1) {
					splice @all_question_numbers, $random_question_index, 1;
				}
			}
		}
	}

	my @sorted_questions =  sort {$a->{date} <=> $b->{date}} @questions;

	for my $sorted_question_number (0 .. $#sorted_questions) {
		my $real_question_number = $sorted_question_number + 1;
		print "$real_question_number. $sorted_questions[$sorted_question_number]{question}\n";
		if (defined ($sorted_questions[$sorted_question_number]{variant_a})) {
			print "а) $sorted_questions[$sorted_question_number]{variant_a}, ";
		}
		if (defined ($sorted_questions[$sorted_question_number]{variant_b})) {
			print "б) $sorted_questions[$sorted_question_number]{variant_b}, ";
		}
		if (defined ($sorted_questions[$sorted_question_number]{variant_c})) {
			print "в) $sorted_questions[$sorted_question_number]{variant_c}, ";
		}
		if (defined ($sorted_questions[$sorted_question_number]{variant_d})) {
			my $answer = "г) ".$sorted_questions[$sorted_question_number]{variant_a}.".\n";
			$answer =~ s/\.\.\n/\.\n/;
			print $answer;
		}
		print "\n";
	}
}
