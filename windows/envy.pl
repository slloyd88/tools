#!perl
#######################################
### Perl2Exe Options
#Compile Options
#perl2exe_info CompileOptions -v
#perl2exe_info CompanyName=Steven Lloyd
our $CompanyName="Steven Lloyd";
#perl2exe_info FileDescription=envy - Environment Variable manager
our $FileDescription="envy - Environment Variable manager";
#perl2exe_info LegalCopyright=All rights Reserverd, Steven Lloyd
our $LegalCopyright="All rights Reserverd, Steven Lloyd";
#perl2exe_info OriginalFilename=envy.exe
our $OriginalFilename="envy.exe";
#perl2exe_info ProductVersion=1.625.14
our $ProductVersion="1.625.14";
#perl2exe_info FileVersion=1.1502.10
our $FileVersion="1.1502.10";
#perl2exe_info LegalCopyright=Copyright 2005, Steven Lloyd
our $LegalCopyright="Copyright 2005, Steven Lloyd";

####
### http://search.cpan.org/~rowaa/Win32-Env-0.03/lib/Win32/Env.pm
#######################################
$|=1;
binmode STDOUT;
use Win32::Env;
$|=1;
my %list=();
#show help?
if($ARGV[0]=~/^(\?|\/\?|\/help|\/h|\-\-help)$/i){
	showHelp();
}
my $group='system';
my $action='add';
my $key='';
my $val='';
my $index=0;
foreach $arg (@ARGV){
	if($arg=~/^(\/s|\-\-system)$/i){$group='system';}
	elsif($arg=~/^(\/u|\-\-user)$/i){$group='user';}
	elsif($arg=~/^(\/d|\-\-delete)$/i){$action='delete';}
	elsif($arg=~/^(\/a|\-\-add)$/i){$action='add';}
	elsif($arg=~/^(\/as|\/sa)$/i){
		$group='system';
		$action='add';
	}
	elsif($arg=~/^(\/au|\/ua)$/i){
		$group='user';
		$action='add';
	}
	elsif($arg=~/^(\/ds|\/sd)$/i){
		$group='system';
		$action='delete';
	}
	elsif($arg=~/^\d+$/){
    	$index=$arg;
	}
	elsif($arg=~/^(\/du|\/ud)$/i){
		$group='user';
		$action='delete';
	}
	elsif(length($key)==0){
    	$key=uc($arg);
	}
	elsif(length($val)==0){
    	$val=$arg;
	}
}
if(!length($val)){$action='list';}
print "Group:$group, Action:$action, Key:$key, Val:$val, Index:$index Args: @ARGV\n";
if($action eq 'list'){
	if(length($key)){showEnv($group,$key);}
	else{showEnvs($group);}
}
elsif($action eq 'add'){
	addRemoveEnvValue($group,$key,$val,$index,1);
}
elsif($action eq 'delete'){
	addRemoveEnvValue($group,$key,$val,$index,0);
}
exit(0);
##################
sub addRemoveEnvValue{
	my $group=shift;
	my $key=shift;
	my $val=shift;
	my $index=shift;
	my $add=shift || 1;
	my $cval='';
	if($group eq 'user'){
		$cval=GetEnv(ENV_USER, $key);
	}
	else{
    	$cval=GetEnv(ENV_SYSTEM, $key);
	}
	my @parts=split(/[\;]+/,strip($cval));
	#remove the value first
	my %found={};
	my $cnt=@parts;
	my @newparts=[];
	for(my $i=0;$i<$cnt;$i++){
		next if $val eq $parts[$i] || $parts[$i]=~/^ARRAY\(/ || isArray($parts[$i]) || $parts[$i]=~/\;/ || $found{$parts[$i]};
		push(@newparts,$parts[$i]);
		$found{$parts[$i]}=1;
	}
	#add the value back in at index if add is 1
	if($add==1){splice @newparts, $index, 0, $val;}
	my $newval=join(';',@newparts);
	if($group eq 'user'){
		DelEnv(ENV_USER, $key);
		SetEnv(ENV_USER, $key, $newval);
		$cval=GetEnv(ENV_USER, $key);
	}
	else{
		DelEnv(ENV_SYSTEM, $key);
		SetEnv(ENV_SYSTEM, $key, $newval);
		$cval=GetEnv(ENV_SYSTEM, $key);
	}
	BroadcastEnv();
	@parts=split(/[\;]+/,strip($cval));
	$cnt=@parts;
	for($i=0;$i<$cnt;$i++){
		next if $parts[$i]=~/^ARRAY\(/ || isArray($parts[$i]);
		my $n=$i;
		if(length($n)==1){$n=' '.$n;}
        print "  $n\. $parts[$i]\n";
	}
}
####################
sub showEnv{
	my $group=shift;
	my $key=shift;
	my $val='';
	if($group eq 'user'){
		$val=GetEnv(ENV_USER, $key);
	}
	else{
    	$val=GetEnv(ENV_SYSTEM, $key);
	}
	my @parts=split(/[\;]+/,strip($val));
	my $cnt=@parts;
	if($cnt==1){
		print "$key: $val\n";
	}
	else{
		print "$key:\n";
		for(my $i=0;$i<$cnt;$i++){
			next if !length(strip($parts[$i])) || isArray($parts[$i]) || $parts[$i]=~/^ARRAY\(/;
			my $n=$i;
			if(length($n)==1){$n=' '.$n;}
        	print "  $n\. $parts[$i]\n";
		}
	}
	print "\n";
}
####################
sub showEnvs{
	my $group=shift;
	if($group eq 'user'){
		my @keys=ListEnv(ENV_USER);
		foreach my $key(@keys){
			showEnv($group,$key);
		}
	}
	else{
		my @keys=ListEnv(ENV_SYSTEM);
		foreach my $key(@keys){
			showEnv($group,$key);
		}
	}
}
####################
sub showHelp{
	print "Usage\r\n";
	print "   envy - lists environment variables in a readable format\r\n";
	print "   envy path - lists path env value only\r\n";
	print "   envy path c:\bin - adds c:\bin to your system path (default is system)\r\n";
	print "   envy /s path c:\bin - adds c:\bin to your system path path\r\n";
	print "   envy /ds path c:\bin - deletes c:\bin to your system path path\r\n";
	print "   envy /u path c:\bin - adds c:\bin to your user path\r\n";
	print "   envy /du path c:\bin - deletes c:\bin to your user path\r\n";
	print "   envy ?|/help|/h|--help - returns this help\r\n";
	exit(0);
}
###############
sub isArray {
	#usage: if(isArray($val)){...}
	#info: return 1 if $val is an array
	#tags: validate, array
  my $a = shift;
  return (ref($a) eq 'ARRAY') ? 1 : 0;
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
