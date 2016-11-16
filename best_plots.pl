#!/usr/bin/perl -w

$USAGE = "
It plots the best N plots.

best_plots.pl IN=<RT-OUTPUT> BEST=<int> PATH=<path> BACKGROUND=<string>

IN: OUTPUT from RT-SPEXS (PLOT.txt)
BEST: Number of best lines.
PATH: where to put the plot (./)
BACKGROUND: just to put it in the title of the graph
START: the X coordinate of the plot

The best criterion is the summ of the negative logarithm of every point.
See also report_best_patterns.pl

";
$START=-4;
$PATH="./";
$YSTART="";
if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~/IN=(.*)/){$INFILE = $1;}
  elsif($args =~ /BEST=(.*)/){$BEST = $1;}
  elsif($args =~ /PATH=(.*)/){$PATH = $1;}
elsif($args =~ /BACKGROUND=(.*)/){$BACKGROUND = $1;}
  elsif($args=~ /XSTART=(.*)/i){$START = $1;}
  elsif($args =~ /YSTART=(.*)/i){$YSTART = $1;}
  else{die $USAGE."Argument $args is invalid\n";}
}

$YSTART1=1e-100;; $YSTART2=1;
if($YSTART =~ /([^,]+),([^,]+)/){$YSTART1=$1; $YSTART2=$2;}
open(IN,$INFILE) or die "Couldn'/t open $INFILE for reading\n";
@D = grep{!/^$/} <IN>;
chomp(@D);
close IN;

$MOG = 0;

map{
  $MOG = 0;
  @V = split /\s+/;
  $name = shift @V;
  $VAL{$name} = [@V];
  foreach my $val (@V){
    $MOG += -log($val);
  }
  $SC{$name} = $MOG;
} @D;

@S = sort {$SC{$b} <=> $SC{$a} } keys %SC;






foreach my $i (0..$BEST-1){
  $motif = $S[$i];
  if($i==0){ # for the first plot
    $plot = "plot [$START".":] '-' title \"$motif\" with linespoints";
    if($YSTART ne ""){ 
      $plot = "plot [$START".":] [$YSTART1:$YSTART2] '-' title \"$motif\" with linespoints";
    }
  }
  else{
    $plot .= ", '-' title \"$motif\" with linespoints";
  }
}



$outfile = $PATH."$BACKGROUND"."_best$BEST"."_PLOT".".png";
open(GNUPLOT,"|gnuplot") or die "COuldn't open gnuplot \n";
print GNUPLOT<<__EOF__;
set term png color
  set key top left
  set xtics 1
set size 1.5,1.5
  set out "$outfile"
set logscale y
$plot
__EOF__

foreach my $i (0..$BEST-1){
  @line =qw(0 0);
  $x = 0;
  foreach my $val (@{$VAL{$S[$i]}}){
    $line[0] = $x;
    $line[1] = $val;
    print GNUPLOT "@line\n";
    $x++;
  }
  print GNUPLOT "end\n";
}


