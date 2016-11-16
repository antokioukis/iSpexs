#!/usr/bin/perl -w

$USAGE = "

the input is the PLOT.txt file of RT-SPEXS.pl or some
derived from that (filtered). 
Then for every motif a measurement of goodness is calculated 
as the sum of negative logarithms. The motifs are presented 
in decreasing order


report_best_patterns IN=<file>

";

if($#ARGV < 0 ){die $USAGE;}

while($args = shift @ARGV){
  if($args =~ /IN=(.*)/){$INFILE = $1;}
  else{die $USAGE."Argument $args is invalid";}
}


open(IN, $INFILE) or die "Couldn't open $INFILE for reading\n";
@D = grep{!/^$/} <IN>;
chomp(@D);
close IN;

$MOG = 0;

map{
  $MOG = 0;
  @V = split /\s+/;
  $name = shift @V;
  foreach my $val (@V){
    $MOG += -log($val);
  }
  $SC{$name} = $MOG;
} @D;

@S = sort {$SC{$b} <=> $SC{$a} } keys %SC;

foreach my $mot (@S){
  print $mot,"\t",$SC{$mot},"\n";
}
