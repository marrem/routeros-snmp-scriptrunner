#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use constant AGENT => 'gateway';
use constant SCRIPT_LIST_OID => '1.3.6.1.4.1.14988.1.1.8';
use constant RUN_SCRIPT_OID_BASE => '1.3.6.1.4.1.14988.1.1.18.1.1.2';
use Getopt::Long;

my $opt_list = 0;

GetOptions (
      'list'  => \$opt_list,
) 
or die("Error in command line arguments\n");


my $script_name = $ARGV[0];

unless ($opt_list || $script_name) {
	die "Usage $0 <script name>\n" .
            "      $0 -l\n";
}

my $script_table = fetch_script_table();

if ($opt_list) {
	print(map {"$_\n"} keys(%$script_table));
	exit;
}


my $script_nr = $script_table->{$script_name};
if ($script_nr) {
	my $run_script_oid = RUN_SCRIPT_OID_BASE . '.' . $script_nr;
	my $run_script_command = 'snmpget ' . AGENT . ' ' . $run_script_oid;
	system($run_script_command);
	if ($? != 0) {
                die "Command $run_script_command exited with non zero exitcode\n"
        }
} else {
	die "Can't find script '$script_name' on " . AGENT . "\n" .
	    "Use -l to see available scripts\n";
}




sub fetch_script_table {

	my $get_script_table_command = 'snmpwalk ' . AGENT . ' ' . SCRIPT_LIST_OID;
	my @raw_script_table = `$get_script_table_command`;
	if ($? != 0) {
		die "Command $get_script_table_command exited with non zero exitcode\n"
	}
	my %script_table;
	foreach my $script_table_line (@raw_script_table) {
		chomp $script_table_line;
		my ($oid, $value) = split(/\s*=\s*/, $script_table_line);
		my $script_nr = (split(/\./, $oid))[-1];
		if ($value =~ /^STRING: "(.*)"$/) {
			$script_table{$1} = $script_nr;	
		}
	}
	return \%script_table;
}
