#!/usr/bin/perl 

$USAGE = "./sequences_from_names.pl FASTA_IN=<file> NAMES_IN=<file>";

if($#ARGV<0){ die $USAGE; }
while ($args = shift @ARGV){
  if($args=~/FASTA_IN=(.*)/i){$FASTAIN = $1;}
  elsif($args=~/NAMES_IN=(.*)/i){$NAMESIN = $1;}
  else{die $USAGE;}
}

open(INF, $FASTAIN) or die "Couldn't open file $FASTAIN\n";
open(NAMES, $NAMESIN) or die "Couldnt open file $NAMESIN\n";

@names = ();
while ($name = <NAMES>){
  chomp($name);
  $name =~s/\s+//g;
  push(@names, $name);
}

close(NAMES);


# only one sequence with a given name will exist in hash %seqs
%seqs = ();
$cnt=0;
while($line = <INF>){
  chomp($line);
  $seqname = "";
  if(($line =~ /^\#/) || ($line =~ /^$/ )) {next;}
  if($line =~ /^>\s*([^\s+]+)/){$seqname = $1;}
  $cnt++;
  while(($seq = <INF>)){
    if($seq =~ /^$/){next;}
    chomp($seq); 
    $seqs{$seqname} = $seq;
    last;     
  }
}


print STDERR "# $cnt sequences in file $FASTAIN\n";
close(INF);

foreach my $name (@names){
  $c++;
  print STDERR $name, "\n";
  if($seqs{$name}){
    $cnt2++;
    print ">$name\n$seqs{$name}\n";
  }
  else{print STDERR "$name not present\n";}
}
print STDERR "#>$NAMESIN\t$c different names\n";
print STDERR "#$cnt2 associations found ($#names should be found)\n";
print STDERR "#######################################################\n";


