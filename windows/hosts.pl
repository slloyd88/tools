#!perl
#######################################
### Perl2Exe Options
#Compile Options
#perl2exe_info CompileOptions -v
#perl2exe_info CompanyName=Steven Lloyd
#perl2exe_info FileDescription=hosts - hosts file manager
#perl2exe_info LegalCopyright=All rights Reserverd, Steven Lloyd
#perl2exe_info OriginalFilename=hosts.exe
#perl2exe_info ProductVersion=1.2.1
#perl2exe_info FileVersion=1.2.1
#perl2exe_info LegalCopyright=Copyright 2005, Steven Lloyd
#######################################
$|=1;
#set hosts file location
my $hostfile='C:\WINDOWS\system32\drivers\etc\hosts';
my %list=();
my $newname=shift;
#show help?
if($newname=~/^(\?|\/help|\-\-help)$/i){
	print "Usage\r\n";
	print "   hosts - lists entries in your hosts file\r\n";
	print "   hosts sample.com - maps sample.com to 127.0.0.1\r\n";
	print "   hosts sample.com 123.321.25.214 - maps sample.com to 123.321.25.214\r\n";
	print "   hosts search test - lists entries in your hosts file that contain the word test\r\n";
	print "Optional Arguements\r\n";
	print " - edit|open|notepad - opens hosts file in notepad\r\n";
	print " - context|cx - opens hosts file in context editor\r\n";
	print " - find|search {string} - lists entries that contain {string}\r\n";
	print " - remove|del|delete {string} - removes entries where ip or name equal {string}\r\n";
	print " - ?|/help|--help - returns this help\r\n";
	exit(0);
}
#edit hosts file?
if($newname=~/^(edit|open|notepad)$/i){
	system(1,"notepad $hostfile");
	exit(0);
}
elsif($newname=~/^(context|cx)$/i){
	system(1,"context $hostfile");
	exit(0);
}
#second arg is the IP address
my $newip=shift || '127.0.0.1';
#open the hosts file and read the lines
open(FH,$hostfile) || die $^E;
my @lines=<FH>;
close(FH);
#if no arguments given, simply lists the entries in the hosts file
if(!$newname){
	foreach my $line (@lines){
    	$line=strip($line);
    	next if $line=~/^\#/s;
    	next if !length($line);
    	print "$line\n";
    }
  	exit(0);
}
#search?
if($newname=~/^(find|search)$/i && $newip){
	print "search resulst for $newip\n";
	foreach my $line (@lines){
	    $line=strip($line);
	    next if $line=~/^\#/s;
	    next if !length($line);
	    next if $line !~/\Q$newip\E/i;
	    print "$line\n";
	}
	exit(0);
}
#Add new entry to the end of the hosts file
my $linecnt=@lines;
my $found=0;
for(my $x=0;$x<$linecnt;$x++){
	my $line=strip($lines[$x]);
	next if $line=~/^\#/s;
	next if !length($line);
	my($ip,$name)=split(/[\s\t]+/,$line);
	if($newname=~/^(remove|del|delete)$/i && ($newip=~/^\Q$ip\E$/is || $newip=~/^\Q$name\E$/is)){
		$lines[$x]='';
		$found++;
	}
	elsif($name=~/^\Q$newname\E$/is){
    	$found++;
    	if($ip!~/^\Q$newip\E$/is){
      		$lines[$x]=qq|$newip\t$newname|;
      	}
    }
}
if(!$found){push(@lines,"$newip\t$newname");}
#write the lines to the hosts file
open(FH,">$hostfile") || die $^E;
binmode(FH);
foreach my $line (@lines){
	$line=strip($line);
	$line=~s/[^a-z0-9\_]$//s;
	next if !length($line);
	print FH "$line\r\n";
}
close(FH);
exit(0);
#---------- begin sub sortTextArray--------------------
#**
# @describe sorts a text array properly
# @param array array - an array
# @return array
# @usage @arr=sortTextArray(@arr);
#/
#####################
sub sortTextArray{
	#sorts a text array properly
	my @in=@_;
	my @new = sort { $a <=> $b || $a cmp $b } @in;
	return @new;
}
#---------- begin sub strip --------------------
#**
# @describe strips off beginning and endings returns, newlines, tabs, and spaces
# @param str string
# @return string
# @usage $str=strip($str);
#/
sub strip{
	#usage: $str=strip($str);
	#info: strips off beginning and endings returns, newlines, tabs, and spaces
	my $str=shift;
	if(length($str)==0){return;}
	$str=~s/^[\r\n\s\t]+//s;
	$str=~s/[\r\n\s\t]+$//s;
	return $str;
}
#---------- begin BEGIN --------------------
#**
# @describe setup for perl2exe
# @exclude  - this is for internal use only and thus excluded from the manual
#/
BEGIN {
	($temp_dir,$progpath,$progexe,$progname)=('','','','');
	$temp_dir = ( $ENV{TEMP} || $ENV{TMP} || $ENV{WINDIR} || '/tmp' ) . "/p2xtmp-$$";
	$0 = $^X unless ($^X =~ m%(^|[/\\])(perl)|(perl.exe)$%i);
	($progpath) = $0 =~ m%^(.*)[/\\]%;
	$progpath ||= ".";
	unshift(@INC,$progpath);
	$progname=lc($0);
	if($progname=~/[\/\\]/){
		my @stmp=split(/[\/\\]/,$progname);
		$progname=pop(@stmp);
	}
	$progname=~s/\Q$progpath\E//s;
	$progname=~s/^[\\\/]+//s;
	if($progname=~/(.+?)\.(exe|pl|so)/is){$progname=$1;}
	if ($^X =~ /(perl)|(perl\.exe)$/i) {
		$progexe=$progname . '.pl';
	}
	else{
		#Compiled
		$Redirect=1;
		$IsCompiled=1;
		@INC=($progpath,"./lib","./",PERL2EXE_STORAGE,$temp_dir);
		$progexe=$progname . '.exe';
	}
}
