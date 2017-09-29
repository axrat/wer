#!/usr/bin/env perl
##!/bin/perl

##
use utf8;
use strict;
use warnings;
use open ":utf8";
##
use Cwd;
use FindBin;
use File::Fetch;
use File::Basename;
use File::Path 'mkpath';
use JSON;

##os
my $br;
my $sl;
#my $processnumberstring = "$$";
my $os="$^O\n";
if ($os eq "MSWin32"){
  #windows:MSWin32i
  binmode STDIN, ':encoding(cp932)';
  binmode STDOUT, ':encoding(cp932)';
  binmode STDERR, ':encoding(cp932)';
  $br = "¥n";
  $sl = "\\";
}else{
  #linux:linux
  #osx:freebsd
  $br = "\n";
  $sl = "/";
}

##const
my $bin = $sl."wer";
#my $cwd = Cwd::getcwd();#currentdirctory
my $bin_path = ($FindBin::Bin).$bin;
#print "bin:".$bin_path."\n";
my $bin_dir;
if (-l $bin_path) {#symbolic check
	#print "true";
    $bin_path = readlink($bin_path);
}
#get parent bin path
$bin_dir = dirname($bin_path).$sl;
#print "bin_path:".$bin_path."\n";
#print "bin_dir:".$bin_dir."\n";
(my $rows,my $cols)=split ' ', qx"stty size </dev/tty 2>/dev/null";
#print "screen size is $rows x $cols\n";
my @onoie = (
"                          .....",
"                     ..&ZT71zZUUUA+.",
"                   .Z6++zOrrvvwvvvvZWn,",
"                 .VC(zrvvrvvzrvvwrvwvrXW+.",
"               .d=(zvvvvvrzvrvzrwvvvvwzvZS,",
"              .KizvvZOOwwwwAwwvvrvvvzrvzvXW,",
"             .V+wwZ^`        ?7WkwvwvwvvvvvH,",
"             JIwC!               ?UmwvvvrvvZW.",
"             ??=                    7WXwvvrvXb.",
"                                      ?4mXrvvdo.",
"                  `            .JzVTTCOOVMRvzdHWa,",
"                 .C?7Ue-<I+.-v=<::<jrrrzrvvrvdHvZWNa,..(J+.",
"               .V!_~(Jv<_(JY<~:~~~:~1zvvzvvvvwXvwvrXHMh-::zo",
"              (5(+zudHZ+zC<:~~::~~:~(zvvvzvvvZWywvwvrvvWn-:vmZ=4;",
"             .3JrwqMSwAY<~:~::~::~~:(jrwvvwvwvvwXkvzrvrrXHs(dH&(vp",
"            .D(rzdHHSw3::_~:~~:~~::(zvvvwvvXvrvvd0XwvvzXvwWNxzNk+?I.",
"            J>zvwHSvwC:(jO++((_((xvjvXvvwvwvvrzrd\$vWwvvvzrvXNydHk<_+",
"           .K<wrXKvwD<(zrvvvvzvwY` .wvzrwzvzvzvvX} ?WkvvvzvvdN2dKx(d.",
"           J\$zvwW0wC<(zrrwvrvwV!    drwvXvzvzvrwK`  _WkwvrvvvMNdNI<d;",
"           X1rvdHwI~(zzvvzvvw0+gWHHMHSvvwvvvvvwdHwaJ,.vHkrvvvXNwMw<Jl",
"          .KjvvWWK>(zvrwwvzQMMSvvvzdKjXvzvvvvXWWkvzvXHmdHvvvrvMkWX>jP",
"          .fjvvwWD(jvrwvvrX#~dvrvwvwS jkwvvvwf!j0zwvwH}(HkvvrvXNWK>+b",
"          J\$zrwwHl+rvzvvvwK! (yzwrvX$  ?kvwZ!  JRvwvvW) (dvrwvvHHE><@",
"          dIzvvwH<wvXvzvvd%   ?UwOZY`    ?`     4kvvQ#!  JXvXwwdHr>(@",
"          H>zvvwHzvvwvwvwK~                       _?7`   JkvvXHwWw<(@",
"          #<jvvXqwvvrzvrX@                               JHvzvXHXX<(@",
"          #<jvrvWkwwvvrvX@.           ......            .dwrvrwMHX<jb",
"         .#<jvvrXHNkvzvvXM&        .JVT1??1vUe          (HXzvwd8Xr<j\$",
"         .#<(wrvvMHRrvvrXKW,      (6<>>?>>??+d; `      .Wdzvvd#XvZ<d{",
"         .#<:zvvvvZHwvvrX#wW-     O>>?>>?>>>+H:       .#1krvd#vvr>(d!"
);


##set default
my $default_shebang="#!/usr/bin/env ";
##cache
my $tmp_dir=$sl."tmp".$sl."wer".$sl;
my $tmp_flg=$tmp_dir."ok";
my $cache=$bin_dir."cache".$sl;
my $cache_status=$bin_dir."profile".$sl."status.json";
my $cache_werc=$bin_dir."profile".$sl."werc";

##main
#print "HelloWorld\n";
my ($cmd, $param);
my $wer_help = <<'EOS';
wer help/hello/run
wer status load/write
wer werc load/write
wer save [url]
.bashrc:+`perl $LOCAL_BIN/wer run`
EOS
if (@ARGV == 0){
  ##TmpDirectoryCheck
  if (! -d $tmp_dir){
    if(! mkpath $tmp_dir){
      print "mkpath error:$tmp_dir";
	  exit;
	}
  }
  ##TmpFlgCheck
  if ( ! -e $tmp_flg) {
    open my $fh, ">", $tmp_flg
      or die "$tmp_flg error : $!";
    close $fh;
    if($rows > (($#onoie+1)+1) ){
      foreach my $onoie_line (@onoie) {
        print $onoie_line, "\n";
      }
    }
  }
  foreach (1..$cols) {
    print "+";
  }
  print "\n";
}elsif ( @ARGV == 1 or @ARGV == 2 or @ARGV == 3 ){
  my $p1 = $ARGV[0],my $p2 = $ARGV[1],my $p3 = $ARGV[2];
  if (@ARGV == 1){
	#print "p1=$p1 $br";
    if ($p1 eq "help"){
      print "$wer_help";
    }elsif($p1 eq "status"){
      print &date()." ".&time().$br;
      print "---config---".$br;
      print "default_shebang:".$default_shebang."[cmd]$br";
      &test("bash","tool/test.sh");
      &test("perl","tool/test.pl");
      print "tmp_dir:".$tmp_dir.$br;
      print "tmp_flg:".$tmp_flg.$br;
      print "cache:".$cache.$br;
      print "cache_status:".$cache_status.$br;
      print "cache_werc:".$cache_werc.$br;
    }elsif($p1 eq "hello"){
      &hello("wer");
    }elsif($p1 eq "check"){
      if(&check($tmp_flg)){
	    print "true";
# 	my ($sec, $min, $hour, $day, $mon, $year) = localtime((stat($tmp_flg))[9]);
#    $year = $year + 1900;
#    $mon = $mon + 1;
#    print $year.$mon.$day.":".$hour.$min.$sec."\n";
	  }else{
        print "false";
	  }
    }elsif($p1 eq "run"){
      &run();
	}else{
      print "unknown simple param:$p1".$br;
	}
  }elsif(@ARGV == 2){
    print "p1=$p1,p2=$p2".$br;
    if ($p1 eq "save"){
      &save($p2);
    }elsif ($p1 eq "status"){
      ##for status.json
      if($p2 eq "load"){
        &status_load();
      }elsif($p2 eq "write"){
        &status_write();
      }
    }elsif($p1 eq "werc"){
      ##for werc
      if($p2 eq "load"){
        &werc_load();
      }elsif($p2 eq "write"){
        &werc_write();
      }
    }
  }elsif(@ARGV == 3){
    print "p1=$p1,p2=$p2,p3=$p3".$br;
  }
  exit(0);
}else{
  print "unknown param pattern$br";
  exit(0);
}


##subroutine,function
#&hello("wer");
sub hello {
	(my $str) = @_;
	print "hello,".$str."!".$br;
}
sub date {
  my @week = ('Sun', 'Mon', 'Thu', 'Wed', 'Thu', 'Fri', 'Sat');
  (my $mday,my $mon,my $year,my $wday) = (localtime(time))[3..6];
  $year += 1900;
  $mon += 1;
  return "$year/$mon/$mday($week[$wday])";
}
sub time{
  (my $sec,my $min,my $hour) = (localtime(time))[0..2];
  return "$hour:$min:$sec";
}
sub exec {
  (my $command) = @_;
  my $result = `$command 2>&1`;
  return $result;
}
sub test {
  (my $name,my $cmdpath) = @_;
  my $res = &exec($bin_dir.$cmdpath);
  my $result = $res eq "complete" ? "ok" : "ng";
  print "test_".$name." : ".$res." ==> [".$result."]".$br;
}
sub check{
  (my $filepath) = @_;
  if (-e $filepath) {
    return 1;#print "already exists".$br;
  }else {
    return 0;#print "not found".$br;
  }
}
sub status_load{
  print "load:".$cache_status.$br;
  open(DATAFILE, "< ".$cache_status) or die("Error:$!");
  while(my $line = <DATAFILE>){
    chomp($line);
    print "$line".$br;
  }
}
sub status_write{
  print "status write".$br;
}
sub werc_load{
  print "werc load".$br;
}
sub werc_write{
  print "werc write".$br;
}
sub save{
  (my $url) = @_;
#  my $url = "http://x-as.com/TransAssist.gif";
  print "save:$url".$br;
  my $ff = File::Fetch->new(uri => $url);
  my $file = $ff->fetch() or die $ff->error;
}
sub run{
#  print "run".$br;
}

