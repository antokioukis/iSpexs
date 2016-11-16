#!/usr/bin/perl -w

$USAGE = "
Takes random selection from a list of names

random_name_selection.pl IN=<name list> NUM=<INT> OUT=<outfile>

";

if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~/IN=(.*)/i){$IN=$1;}
  elsif($args =~ /NUM=(.*)/i){$NUM=$1;}
  elsif($args =~ /OUT=(.*)/i){$OUT=$1;}
  else{die $USAGE."Argument $args is invalid\n";}
}

open(IN,$IN) or die "Couldn't open $IN for reading\n";
@D = grep{!/^$/} <IN>;
chomp(@D);
close IN;

open(OUT,">$OUT") or die "Couldn't open $OUT for writing\n";
foreach my $i(0..$NUM-1){
  $r = $D[rand @D];
  print OUT $r,"\n";
}

close OUT;
