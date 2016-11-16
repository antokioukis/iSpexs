#!/usr/bin/perl -w

$USAGE = "grep_spexs_file.pl IN=<.spx file> NUM=<int> MINSTRINGS=<int> MS=<int> MS2=<int>

IN: SPEXS results file
NUM: an integer will be added in the end of the lines of 
each spexs results file
MINSTRINGS: SPEXS minstrings parameter
MS: SPEXS ms parameter
MS2: SPEXS ms parameter (for the second file)
";
$PATH="./";
$NUM="";
$MINSTRINGS = 1;
if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /IN=(.*)/i){$SPX = $1;}
  elsif($args =~ /NUM=(.*)/i){$NUM = $1;}
  elsif($args =~ /PATH=(.*)/i){$PATH = $1;}
  elsif($args =~ /MS=(.*)/i){$MS = $1;}
  elsif($args =~ /MS2=(.*)/i){$MS2=$1;}
  elsif($args =~ /MINSTRINGS=(.*)/i){$MINSTRINGS=$1;}
  else{die $USAGE;}
}

open(SPX, $PATH.$SPX) or die "Couldn't open $SPX file for reading\n";

print STDERR "# grep spexs MS2: $MS2 MS: $MS MINSTRINGS: $MINSTRINGS\n";
@D=grep {!/^$/} <SPX>;
chomp(@D);
close SPX;

map{
  if(!/1e\+06/){
    if(/1:([^\/]+)/){$ms = $1}
    if(/2:([^\/]+)/){$ms2 = $1}
    if(/^[^\s]+\s+([^\/]+)/){$minstrings = $1;}

    if(($ms >= $MS) && ($ms2 >= $MS2) && ($minstrings >= $MINSTRINGS)){
      $_ =~ s/[^\s]+://g;
      @V = split /\s+/;
      $SC{$V[0]} = $V[5];
      $VAL{$V[0]} = [@V];
    }
  }
} @D;
  
@S = sort{$SC{$a}<=>$SC{$b}} keys %SC;

open(SSPX, ">$PATH"."$SPX".".s.spx") or die "Couldn't open s.spx file for output \n";
foreach my $name (@S){
  print SSPX "@{$VAL{$name}}\t","$NUM\n";
}

print STDERR "Cycle $NUM is done!\n";
