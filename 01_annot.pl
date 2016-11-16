#!/usr/bin/perl -w

$USAGE="./01_annot.pl IN=<file>\n";

if($#ARGV <0){die $USAGE;}
while ($args =shift @ARGV){
  if($args =~ /IN=(.*)/i){$INFILE=$1;}
  else{die $USAGE;}
}

open(IN, $INFILE) or die "Couldn't open $INFILE\n";
open(ANNOT, ">$INFILE".".annot") or die "Coulnd't open file for output\n";
open(TRANS, ">$INFILE".".trans") or die "Couldn't open file for output\n";
open(FA, ">$INFILE".".trans.fa") or die "Couldn't open file for output\n";
open(SST, ">$INFILE".".sst") or die "COuldn't open file for output\n";


while($line=<IN>){
  @INF=();
  chomp ($line);
  if($line =~ /^$/){next;}
  if($line =~ /^>(.*)/){
    print ANNOT $1, "\n";
    print STDERR $line, "\n";
    @INF = split (/\|/, $1);
    print TRANS $INF[2], "\n";
    print FA ">$INF[2]\n";

    if($INF[5]==1){print SST $INF[1], "\t", $INF[2], "\t", $INF[3], "\t", $INF[5], "\n"};
    if($INF[5]==-1){print SST $INF[1], "\t", $INF[2], "\t", $INF[4], "\t", $INF[5], "\n"};
    next;
  }
  print FA $line, "\n";
}

close IN;
close ANNOT;
close TRANS;
close FA;
