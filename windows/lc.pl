#!perl
#######################################
### Perl2Exe Options
#Compile Options
#perl2exe_info CompileOptions -v
#perl2exe_info CompanyName=Steven Lloyd
#perl2exe_info FileDescription=lc - lowercase file names
#perl2exe_info LegalCopyright=All rights Reserverd, Steven Lloyd
#perl2exe_info OriginalFilename=lc.exe
#perl2exe_info ProductVersion=1.2.1
#perl2exe_info FileVersion=1.2.1
#perl2exe_info LegalCopyright=Copyright 2005, Steven Lloyd
#######################################
my $dir=shift || './';
#show help?
if($dir=~/^(\?|\/help|\-\-help)$/i){
	print "Usage\r\n";
	print "   lc - lowercase all filenames in the current directory\r\n";
	print "   lc d:\test - lowercase all filenames in d:\test directory\r\n";
	print "Optional Arguements\r\n";
	print " - ?|/help|--help - returns this help\r\n";
	exit(0);
}
opendir(DIR,$dir);
my @cfiles=grep(/\w/,readdir(DIR));
close(DIR);
print "$dir\r\n";
foreach my $cfile (@cfiles){
	$lcfile=lc($cfile);
	if($lcfile ne  $cfile){
		$afile="$dir/$cfile";
		$afile=~s/\/+/\//g;
		rename ("$dir/$cfile","$dir/$lcfile");
		print "   $cfile  -->  $lcfile\r\n";
	}
}
exit(0);
#---------- begin BEGIN --------------------
#**
# @describe initialize stuff for perl2exe
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