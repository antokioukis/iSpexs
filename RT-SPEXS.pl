#!/usr/bin/perl -w

$USAGE = "RT-SPEXS.pl IN=<file> PPR=<int> PATH=<path for output>\n

It tries to create a graph in order to inspect the progress of a motif through the results of SPEXS.

";
$PPR = 0; # plots per graph

if($#ARGV <0){ die $USAGE;}
while ($args = shift @ARGV){
  if($args =~ /IN=(.*)/){$INFILE =$1;}
  elsif($args =~ /PPR=(.*)/){$PPR = $1;}
  elsif($args =~ /PATH=(.*)/){$PATH=$1;}
  else{die $USAGE;}
}

open(INFILE, $INFILE) or die "Couldn't open $INFILE for reading\n";

@A = grep {!/^$/} <INFILE>;
chomp(@A);

$MAX=0;
$MAXP=0;
foreach my $line(@A){
  @V = split /\s+/, $line;
  if($V[7]>$MAX){$MAX=$V[7];}
  if($V[5] > $MAXP){$MAXP=$V[5];}
  if(!$M{$V[0]}){
    $M{$V[0]}=$V[5];
    $S{$V[0]}=$V[7];
  }
  else{
    $M{$V[0]}.="\t".$V[5];
    $S{$V[0]}.="\t".$V[7];
  }
}


@AD =();




  
@line =();

@PLOT=();
@PATTERN = ();
$plot= "plot 0";
$plotcmd = "plot  0";

$cnt = 1;
$cnt2 = 1;

print STDERR "There are ". keys (%M)." different motifs\n";

foreach my $m (keys %M){
#  if($m ne "ACTTCCG"){next;}#print STDERR $M{$m}, "\n", $S{$m},"\n"; die;}
  $cnt2++;
  $cnt++;
  @G=();
  @P=();
  %GP=();
  
  my @R=();
  
  @G = split /\t/, $M{$m}; # split the bp
  @P = split /\t/, $S{$m}; # split the con order
  #There is 1-1 association between these two arrays. 
  #The first denotes the Y axe and the second the X axe
  
  foreach my $i(0..$#P){
    $GP{$P[$i]} = $G[$i];
  }
  
  foreach my $i(0..$MAX){
    if($GP{$i}){
      push @R, $GP{$i};
    }
    else{ push @R, $MAXP; }
  }

  $plotcmd .= ", '-' title \"$m\" with linespoints"; 
  push @PATTERN, $m;
  if(($PPR!=0) && ($cnt <=$PPR) && ($cnt2 <=keys (%M))){
    $plot.=", '-' title \"$m\" with linespoints";
  }
  elsif($PPR!=0){
    $plot.=", '-' title \"$m\" with linespoints";
    #print STDERR "Counter: ", $cnt, "\n";
    #print STDERR "Counter 2: ", $cnt2, "\n";
    push @PLOT, $plot;
    $plot = "plot [-4:] 0";
    $cnt = 1;
  }

  
  push @AD, [@R];
}

print STDERR "There are ".scalar @PLOT." commands for plotting", "\n";


$plfile = $PATH."plot.png";
open(GNUPLOT, "| gnuplot") or die "open: $!\n";
print GNUPLOT<<__EOF__;
set term png color
set out "$plfile"
set logscale y
set nokey
$plotcmd
__EOF__

open(OUTF, ">$PATH"."PLOT.txt") or die "open: $!\n";


foreach my $i (0..$#AD){
  print OUTF $PATTERN[$i], "\t";
  foreach my $j (0..$MAX){
    $line[0]=$j;
    $line[1]=$AD[$i][$j];
    print GNUPLOT "@line\n";
    print OUTF "$AD[$i][$j]\t";
  }
  print GNUPLOT "end\n";
  print OUTF "\n";
}


#print GNUPLOT "pause 100\n";
close GNUPLOT;
close OUTF;

if($PPR==1){

  open (GNPL, "| gnuplot") or die "Couldn't open: $!\n";
  
  print STDERR "############   Multiple Plots ############\n\n";
  foreach my $i (1..scalar @PLOT){
    $plot = $PLOT[$i-1];
    #print "plot size: ", scalar @PLOT, "\n";sleep(1);
    #print STDERR $plot, "\n"; 
    if($PPR==1){
      if($plot =~ /\"(.*)\"/){
	$file=$PATH.$1.".png"; 
	print STDERR $file, "\n"; 
      }
    }
    
    
  
    print STDERR $plot, "\n\n";
    print GNPL<<__EOF__;
set term png color
set out "$file"
set key top left
set y2tics
set logscale y
$plot
__EOF__
    
    $last=0;
    
    foreach my $j (1..$PPR){
      foreach my $k (0..$MAX-1){
	$li = ($i-1)*$PPR+$j-1;
	if($li >= keys (%M)){$last=1;last;}
	#print STDERR "X coordinate: ", $li,"\n";
	$line[0]=$k+1;
	$line[1]=$AD[$li][$k];
	print GNPL "@line\n";
      }
      if($last){last;}
      print GNPL "end\n";
  }
    
    
  }
  print GNPL "set term X11\n";
  #print GNPL "pause 200\n";
  close GNPL;
}



