#!/usr/bin/perl

use strict;
use warnings;

use MARC::Batch;

my $batch = MARC::Batch->new('USMARC', '_data/open_access_books.mrc');
$batch->strict_off();

my $counter = 0;

while (my $record = $batch->next()) {
	# crop the dataset down to 10 for now
	$counter = $counter + 1;
	if ($counter > 10) {
		last;
	}

	my $field = $record->field("245");
	my $control_number = $record->field("001")->as_string();
	my $title = $field->subfield('a') . $field->subfield('b');
	my $notes_summary = $record->field("520");
	if (defined $notes_summary) {
		$notes_summary = $notes_summary->as_string();
	} else {
		$notes_summary = '';
	}

	{
		open my $fh, '>', '_site/' . $control_number . '.html';
		print {$fh} '<!doctype HTML><html><body><h1>' . $title . '</h1><h2>Summary</h2><p>' . $notes_summary . '</p></body></html>';
		close $fh;
	}
	print $counter,"\t",$control_number,"\t",$title,"\n";
}

if (my @warnings = $batch->warnings()) {
	print "\nWarnings were detected!\n", @warnings;
}
