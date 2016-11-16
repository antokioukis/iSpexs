#!/usr/bin/perl -w

if($#ARGV<0) {die ("Usage: ./fasta2line IN=<fastafile> OUT=<fasta_in_one_line_output>\n");}

while($ARG=shift @ARGV){
    if($ARG=~/IN=(.*)/i){$IN=$1;print $1, "\n";}
    elsif($ARG=~/OUT=(.*)/i){$OUT=$1;print $1, "\n";}
    else {die "Usage: ./fasta2line IN=<fastafile> OUT=<fasta_in_one_line_output>\n"}
}

open(IN, $IN) or die ("Could't open $IN \n");
open(OUT, ">$OUT") or die("Couldn't open $OUT \n");

$start=0;
while($line = <IN>){
  
  chomp($line);
  if($line =~ m/^$/){ next;}
  #if(/^>\s*NM_([^_]+)/) {$fs=0; $seq=""; print OUT "\n>NM_$1\n"; next;}
  if($line=~ m/^>\s*([^\s]+)/){
    if(!$start){print OUT ">$1\n"; }
    else{print OUT "\n>$1\n";}
    $start=1;
    next;
  }
  print OUT $line;
 
}
print OUT "\n";

close IN;
close OUT; 

