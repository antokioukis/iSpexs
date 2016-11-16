#!/usr/bin/perl -w

$USAGE = "
From RT-SPEXS.pl I create a PLOT.txt file with the
name of every pattern and the points.
This file sometimes contain too many lines.
With this program I would like to filter them,
either basen on a threshold value, or on a best value 
criterion

filter_lines.pl IN=<file> THR=<float> BEST=<int> 

IN: the PLOT.txt file
THR: the minimum threshold SCORE (100) that lines should cross
BEST: Give only the best sequences

NOTE: In every case the best 30000 lines are printed
in a sorted order

";

$THR = 100;
$BEST = 30000;

if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /IN=(.*)/){$INFILE = $1;}
  elsif($args =~/THR=(.*)/){$THR=$1;}
  elsif($args =~/BEST=(.*)/){$BEST=$1;}
}

open(INFILE, $INFILE) or die "couldn't open $INFILE for reading\n";

@D=grep{!/^$/} <INFILE>;
chomp(@D);
close INFILE;

map{
  $score = 0;
  @V=split /\s+/;
  $motif = shift @V;
  $VALUES{$motif} = [@V];
  foreach my $val (@V){
    $score += -(log($val));
  }
  $SCORE{$motif} = $score;
  #print STDERR $score, "\n";
} @D;

@SKEYS = sort{$SCORE{$b} <=> $SCORE{$a}} keys %SCORE;

$i=0;
foreach my $key (@SKEYS){
  $i++;
  if(($i<=$BEST) && ($SCORE{$key} >=$THR)){
    print $key, "\t", "@{$VALUES{$key}}\n";
  }
}

