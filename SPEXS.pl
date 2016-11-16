#!/usr/bin/perl -w

$USAGE = "SPEXS.pl Q=<file1> B=<file2> PR=<float> RATIO=<float> MS=<int> MINSTRINGS=<int> PROP=<T,F> MS2=<INT>

It runs SPEXS tool, with parameters...



";
$RATIO = 2;
$PR=1e-05;
$BFILE = "~/ENSEMBL/Rand1000_ensemble_Upstream.fa";
$MS = 5;
$MINSTRINGS = 2;
$bin = "/home/pavlidis/MDI/demo/bin/";

if($#ARGV < 0) {die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /Q=(.*)/i){$QFILE = $1;}
  elsif($args =~ /B=(.*)/i){$BFILE = $1;}
  elsif($args =~ /PR=(.*)/i){$PR = $1;}
  elsif($args =~ /RATIO=(.*)/i){$RATIO = $1;}
  elsif($args =~ /MS=(.*)/i){$MS = $1;}
  elsif($args =~ /MS2=(.*)/i){$MS2 = $1;}
  elsif($args =~ /MINSTRINGS=(.*)/i){$MINSTRINGS = $1;}
  else{die $USAGE;}
}

print STDERR "# Query:", $QFILE, "\n";
print STDERR "# Background:", $BFILE, "\n";
print STDERR "# ms: $MS\n";
print STDERR "minstrings: $MINSTRINGS\n";
print STDERR "# ms2: $MS2\n";

system("$bin"."spexs -f $QFILE -ms $MS -f $BFILE  -ms $MS2  -showratio 1 -goodratio $RATIO -minstrings $MINSTRINGS -binomial_prob $PR -freq_set 1 -genorder 2\|grep \"^[ACTG]\" |grep \"[^1e+06]\" > $QFILE".".spx");

print STDERR "## spexs -f $QFILE -ms $MS -f $BFILE  -ms $MS2  -showratio 1 -goodratio $RATIO -binomial_prob $PR -freq_set 1 -genorder 2";
