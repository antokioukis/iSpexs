#!/usr/bin/perl -w
$USAGE = "plot_clustered_patterns.pl DATA=<file> CLUST=<file> MIN=<float>

DATA: file in the form of table where the first column
denotes the title of the motif

CLUST: file with two columns. 
The first column represents the motif, and the second one
the cluster which it belongs to.

MIN: If the min value of a line is greater than the value 
specified by MIN the the line is not presented.

";


$MIN=1;
$PATH="./";
if($#ARGV < 0) {die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /DATA=(.*)/i){$INFILE = $1;}
  elsif($args =~ /CLUST=(.*)/i){$CLUST = $1;}
  elsif($args =~ /PATH=(.*)/i){$PATH = $1;}
  elsif($args =~ /MIN=(.*)/i){$MIN = $1;}
  else{die $USAGE;}
}

print STDERR "The images are stored at $PATH\n";
open (INFILE, $INFILE) or die "Couldn't open $INFILE for reading \n";
@DATA = grep {!/\#/} <INFILE>;
chomp(@DATA);

close INFILE;


map{@V = split /\s+/; $name=shift @V; $D{$name}=[@V]; } @DATA;

open(CLUST, $CLUST) or die "Couldn't open $CLUST for reading \n";
@CLUST = grep {!/\#/} <CLUST>;
chomp (@CLUST);
close CLUST;

map{@V = split /\s+/;  $patt = shift @V; $clust = shift @V; $CLUSTER{$patt} = $clust;} @CLUST;

print STDERR "Initially there are ".keys (%D)." motifs\n";

#====== DELETE IF NOT LESS THAN MIN EVER =======###

foreach my $pat (keys %D){
  @S = sort{$a<=>$b} @{$D{$pat}};
  if($S[0]>$MIN){
    delete $D{$pat};
    delete $CLUSTER{$pat};
  }
}
print STDERR "Applying the min rule there are just ".keys (%D). " motifs\n";
#=================================================#


@SC = sort{$CLUSTER{$a} <=> $CLUSTER{$b}} keys %CLUSTER;

$prev = -1;

$cnt=0;
foreach my $pat (@SC){
  if($CLUSTER{$pat} == $prev){
    $plotcmd .= ", '-' title  \"$pat\" with linespoints";
  }
  else{
    if($cnt != 0){push @PLOTCMD, $plotcmd;} #Don't push in the beginning
    push @LABEL, $CLUSTER{$pat};
    $plotcmd = "plot [-4:] '-' title \"$pat\" with linespoints";
    $prev=$CLUSTER{$pat};
    
  }
  $cnt++;
}
push @PLOTCMD, $plotcmd; # push the last one

print STDERR $PLOTCMD[3], "\n";
print STDERR "There are ", scalar @PLOTCMD, " commands\n";


@line = qw(0 0);

$i=0;
foreach my $label(@LABEL){
  $outfile = $PATH."clust_".$label.".png";
  open(GNUPLOT, "| gnuplot") or die "Couldn't open GNUPLOT \n";
  print GNUPLOT<<__EOF__;
  set term png color
  set key top left
set xtics 1
set size 1.5,1.5
  set out "$outfile"
set logscale y
  $PLOTCMD[$i]
__EOF__

  foreach my $pat(@SC){
    $min=10;
    $x = 0;
    if($CLUSTER{$pat} == $label){
      while ($value = shift @{ $D{$pat} }){
	$line[0]=$x;
	$line[1]=$value;
	$x++;
	print GNUPLOT "@line\n";
	print STDERR "@line\n";
      }
      print GNUPLOT "end\n";
    }
    
  }
  $i++;
}

