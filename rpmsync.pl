#!/usr/bin/perl
# - Script to rsync update an RPM repository mirror; most useful for
#   frequently updated distributions, like Mandriva Cooker, RedHat Rawhide
#   or security updates for a specific version of an RPM-based distribution
# - Moves RPMs so you can rsync between package versions
# - Supports mirroring directories and individual files
# - Can be configured by editing variables at the top of the script,
#   or by using command-line arguments
# (C) 2003 David Walser <luigiwalser@yahoo.com>
# Newest version should be able to be found at:
# $HeadURL: svn+ssh://svn.mandriva.com/svn/packages/cooker/rpmsync/current/SOURCES/rpmsync.pl $
# The license is LGPL http://www.gnu.org/licenses/lgpl.html

use File::Basename;
use Getopt::Long;
Getopt::Long::Configure ("bundling");

my $LOCALPATH = "/pub/linux/Mandrivalinux/devel/cooker";
my $RSYNCHOST = "ftp.uninett.no";
my $RSYNCPATH = "Mandrivalinux/devel/cooker";

my $COMPRESSION = "yes";
my $HARDLINKS = "no"; # preserve hard links
my $QUIET = "no"; # Don't show rsync progress and stats
my $VERBOSE = "yes"; # Say what will be done before executing rsync
my $RATELIMIT = "no"; # Limit download bandwidth during rsync
my $RATE = "4"; # Kilobytes per second (KBps)
my $DRYRUN = "no"; # Show what will be done, w/out doing anything
my $LOOP = "no"; # loop through sources until fully synced
my $USEEXCLUDELIST = "no"; # Use files with include/exclude patterns
my $INCLUDESFILE = "include.lst"; # file include patterns for rsync
my $EXCLUDESFILE = "exclude.lst"; # file exclude patterns for rsync

# Relative to paths given above,
# Do not put leading or trailing slashes on directories
my @SOURCES = ("contrib/i586",
	       "i586");


my $compression = "";
unless ($COMPRESSION eq "no"){
    $compression = "1";}
my $hardlinks = "";
if ($HARDLINKS eq "yes"){
    $hardlinks = "1";}
my $quiet = "";
if ($QUIET eq "yes"){
    $quiet = "1";}
my $verbose = "";
unless ($VERBOSE eq "no"){
    $verbose = "1";}
my $dryrun = "";
if ($DRYRUN eq "yes"){
    $dryrun = "1";}
my $loop = "";
if ($LOOP eq "yes"){
    $loop = "1";}
my $rate = "";
my $includesfile = "";
my $excludesfile = "";

my @sources = ();

GetOptions("z" => \$compression,
	   "compress!" => \$compression,
	   "H" => \$hardlinks,
	   "hard-links!" => \$hardlinks,
	   "q" => \$quiet,
	   "quiet!" => \$quiet,
	   "v" => \$verbose,
	   "verbose!" => \$verbose,
	   "n" => \$dryrun,
	   "dryrun!" => \$dryrun,
	   "loop!" => \$loop,
	   "bwlimit:i" => \$rate,
	   "include-from=s" => \$includesfile,
	   "exclude-from=s" => \$excludesfile,
	   "source=s" => \@sources,
	   "help|h" => \&help);

sub help {
    print "$0 (C) 2003 David Walser <luigiwalser\@yahoo.com>
$Id: rpmsync.pl 189535 2008-03-22 23:00:41Z fhimpe $
<$HeadURL: svn+ssh://svn.mandriva.com/svn/packages/cooker/rpmsync/current/SOURCES/rpmsync.pl $>
- Script to rsync update an RPM repository mirror; most useful for
  frequently updated distributions, like Mandriva Cooker, RedHat Rawhide
  or security updates for a specific version of an RPM-based distribution
- Moves RPMs so you can rsync between package versions
- Supports mirroring directories and individual files

$0 comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
are welcome to redistribute it under certain conditions.  See the GNU
LGPL <http://www.gnu.org/licenses/lgpl.html> for details.

Usage:\t$0 [OPTIONS] [rsync://[HOST]/[SRC] [DEST]]
  or\t$0 [OPTIONS] --source=SRC [rsync://[HOST]/[PATH] [DEST]]

No command-line arguments are required, and defaults can be changed by editing
the variables that appear at the top of the script.

Script Options (default ones can be disabled by preceding long option with no
\t\t Ex: --nocompress)
 -z, --compress\t\tCompress file data during transfer";
    unless ($COMPRESSION eq "no"){ print "\t(default)" }
    print "\n -H, --hard-links\tpreserve hard links";
    if ($HARDLINKS eq "yes"){print "\t(default)" }
    print "\n -q, --quiet\t\tDon't show rsync progress and stats";
    if ($QUIET eq "yes"){ print "\t(default)" }
    print "\n -v, --verbose\t\tSay what will be done before executing rsync";
    unless ($VERBOSE eq "no"){ print "   (default)" }
    print "\n -n, --dryrun\t\tShow what will be done, w/out doing anything";
    if ($DRYRUN eq "yes"){ print "   (default)" }
    print "\n --loop\t\t\tloop through sources until fully synced";
    if ($LOOP eq "yes"){ print "   (default)" }
    print "\n\nRsync Options
 --bwlimit=KBps\t\tLimit download bandwidth during rsync, KBytes per second";
    if ($RATELIMIT eq "yes"){ print "\n\t\t\t\t(default=$RATE, Can be disabled with --bwlimit=0)" } else { print "\n\t\t\t\t(If KBps argument is not given, e.g. --bwlimit,\n\t\t\t\t rate will be set to $RATE KBps)" }
    print "\n --include-from=File\tfile include patterns for rsync listed in File";
    if ($USEEXCLUDELIST eq "yes"){ print "\n\t\t\t\t(default=$INCLUDESFILE)" }
    print "\n --exclude-from=File\tfile exclude patterns for rsync listed in File";
    if ($USEEXCLUDELIST eq "yes"){ print "\n\t\t\t\t(default=$EXCLUDESFILE)" }
    print "\n -h, --help\t\tshow this help screen

Source option
 --source=SRC\t\tSpecify directory(s) or file(s) to download
\t\t\tOption may be called multiple times, or you can give
\t\t\tone call a comma seperated list of sources.
\t\t\tDo not put leading or trailing slashes on directories.
\t\t\tFiles are downloaded from the rsync HOST given,
\t\t\tfrom the SRC location relative to the PATH given,
\t\t\tand saved under SRC relative to the local DEST.\n\n";
    exit }

if ($compression) { $COMPRESSION = "yes" } else { $COMPRESSION = "no" }
if ($hardlinks) { $HARDLINKS = "yes" } else { $HARDLINKS = "no" }
if ($quiet) { $QUIET = "yes" } else { $QUIET = "no" }
if ($verbose) { $VERBOSE = "yes" } else { $VERBOSE = "no" }
if ($dryrun) { $DRYRUN = "yes" } else { $DRYRUN = "no" }
if ($loop) { $LOOP = "yes" } else { $LOOP = "no" }
if ($rate) { $RATE = $rate; $RATELIMIT = "yes" }
if ($rate eq "0" && $RATELIMIT == "yes") { $RATELIMIT = "no" }
if ($rate eq "0" && $RATELIMIT == "no") { $RATELIMIT = "yes" }
if ($includesfile) { $INCLUDESFILE = $includesfile; $USEEXCLUDELIST = "yes" }
if ($excludesfile) { $EXCLUDESFILE = $excludesfile; $USEEXCLUDELIST = "yes" }

@sources = split(/,/,join(',',@sources));

$RSYNCPATH = $RSYNCPATH . "/";

$ARGV[0] =~ m|^(.*)::(.*)$|;
$ARGV[0] =~ m|^rsync://([^/]*)/(.*)$|;
my $rsynchost = $1;
my $rsyncpath;
my $source;
if ($2){
    if (@sources){ $rsyncpath = $2 . "/" }
    else {
	($source, $rsyncpath) = fileparse($2);
	if ($rsyncpath eq "./") { $rsyncpath="/" }
	@sources = ($source);}}
my $localpath = $ARGV[1];

if ($rsynchost) { $RSYNCHOST = $rsynchost }
if ($rsyncpath) { $RSYNCPATH = $rsyncpath }
if (@sources) { @SOURCES = @sources }
if ($localpath) { $LOCALPATH = $localpath }

if ($RSYNCPATH eq "/") { $RSYNCPATH = "" }

chdir $LOCALPATH or die "Invalid local path:\n\t$LOCALPATH\n";
my $rsync_short_args = "-av";
unless ($COMPRESSION eq "no"){
    $rsync_short_args .= "z";}
if ($HARDLINKS eq "yes"){
    $rsync_short_args .= "H";}
my $rsync_long_args = " --delete --delete-after --partial";
my $rsync_exclude = "";
unless ($QUIET eq "yes"){
    $rsync_long_args .= " --stats";
    $rsync_long_args .= " --progress" if (-t STDIN);}
if ($RATELIMIT eq "yes"){
    $rsync_long_args .= " --bwlimit=" . $RATE;}
if ($USEEXCLUDELIST eq "yes"){
    if (-e $INCLUDESFILE){
	$rsync_exclude .= " --include-from=" . $INCLUDESFILE;}
    if (-e $EXCLUDESFILE){
	$rsync_exclude .= " --exclude-from=" . $EXCLUDESFILE;}}


my @synced = ();
my $i;
my $doneonce = 0;

for ($i = 0;$i < @SOURCES;$i++){
    $synced[$i] = 1;}
$i = 0;

until ($i == @SOURCES){
    unless ($doneonce){
	my %update_candidates = ();
	my %new_rpms = ();
	my @old_files = ();
	my @new_files = ();
	my $line = "";

	foreach (@SOURCES){
	    open RSYNC, "rsync ". $rsync_short_args . "n" . " --delete --delete-before" . $rsync_exclude . " rsync://" . $RSYNCHOST . "/" . $RSYNCPATH . $_ . " " . dirname($_) . "|" or die "can't launch rsync";

	    chomp($line = <RSYNC>);
	    until ($line =~ /^receiving / || !defined($line)){
		chomp($line = <RSYNC>);}
	    chomp($line = <RSYNC>);     
	    if ($line =~ /^done$/){
		chomp($line = <RSYNC>);}

	    while ($line =~ /^deleting (.*)$/){
		$name = ( (dirname($_) eq ".")?"":(dirname($_) . "/") ) . $1;
		if ((basename $name) =~ /(.*?)-[0-9].*\.([^.]+)\.rpm/){
		    $update_candidates{$2 . ":" . $1} = $name;}
		else {
		    push @old_files, $name;}

		chomp($line = <RSYNC>);}

	    until ($line =~ /^wrote / || !$line){
		$line = ( (dirname($_) eq ".")?"":(dirname($_) . "/") ) . $line;
		if ((basename $line) =~ /(.*?)-[0-9].*\.([^.]+)\.rpm/){
		    $new_rpms{$2 . ":" . $1} = $line;}
		else {
		    push @new_files, $line;}

		chomp($line = <RSYNC>);}

	    close RSYNC or die "rsync error";}

        for ($i = 0;$i < @SOURCES; $i++){
            foreach (values %new_rpms){
                if (/^($SOURCES[$i])/){
                    $synced[$i] = 0;
                    last;}}}

	unless ($VERBOSE eq "no"){
	    print "To be done:\n";}
	foreach (sort keys %update_candidates){
	    if (exists $new_rpms{$_}){
		unless ($VERBOSE eq "no"){
		    print "Update " . join(" ", split /:/, $_) . " RPM \n(" . $update_candidates{$_} . " =>\n\t" . $new_rpms{$_} . ")\n";}
		unless ($DRYRUN eq "yes"){
		    system "mv -f " . $update_candidates{$_} . " " . $new_rpms{$_};}
		delete $new_rpms{$_};}
	    else {
		push @old_files, $update_candidates{$_};}}
	unless ($VERBOSE eq "no"){
	    foreach ((sort values %new_rpms), @new_files){
		if (-e $_){
		    print "Update " . $_ . "\n";}
		else {
		    print "Get " . $_ . "\n";}}
	    foreach (@old_files){
		print "Delete " . $_ . "\n";}}

        for ($i = 0;$i < @SOURCES; $i++){
            if ($synced[$i]){
                foreach (@old_files, @new_files){
                    if (/^($SOURCES[$i])/){
                        $synced[$i] = 0;
                        last;}}}}

        unless ($LOOP eq "yes"){
            $doneonce = 1;}
        if ($DRYRUN eq "yes"){
            $doneonce = 1;}}

    for ($i = 0; $i != @SOURCES && $synced[$i]; $i++){}

unless ($i == @SOURCES){
    unless ($VERBOSE eq "no"){
	print "Executing:\nrsync ". $rsync_short_args . $rsync_long_args . $rsync_exclude . " rsync://" . $RSYNCHOST . "/" . $RSYNCPATH . $SOURCES[$i] . " " . $LOCALPATH . ( (dirname($SOURCES[$i]) eq ".")?"":("/" . dirname($SOURCES[$i])) ) . "\n";}
    unless ($DRYRUN eq "yes"){
	system "rsync ". $rsync_short_args . $rsync_long_args . $rsync_exclude . " rsync://" . $RSYNCHOST . "/" . $RSYNCPATH . $SOURCES[$i] . " " . dirname($SOURCES[$i]);}
    $synced[$i] = 1;}}

#if ($USEEXCLUDELIST eq "yes"){
#    `gendistrib --distrib cooker/i586 cooker/i586/Mandriva/RPMS*`;}
