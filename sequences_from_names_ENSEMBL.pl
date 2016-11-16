#!/usr/bin/perl 

$USAGE = "./sequences_from_names_ENSEMBL.pl FASTA_IN=<file> NAMES_IN=<file>

In this case the names are ensembl GENES or ensembl TRANSCIPTS. 
If it is genes it will return all the sequences that refer to this gene

";

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

%gseqs = ();
%tseqs = ();
$cnt=0;
while($line = <INF>){
  chomp($line);
  $seqname = "";
  if(($line =~ /^\#/) || ($line =~ /^$/ )) {next;}
  if($line =~ /^>(.*)/){# IT's the annotation line
    @ANNOT =split /\|/, $1;
    $annot=$1;
    $name = $ANNOT[1];
    $trans = $ANNOT[2];
    push @NAMES, $ANNOT[1];
    push @TRANS, $ANNOT[2];

    $cnt++;
    while(($seq = <INF>)){
      if($seq =~ /^$/){next;}
      chomp($seq);
      if(!$gseqs{$name}){ 
	$gseqs{$name} = ">".$annot."\n".$seq;
      }
      else{
	$gseqs{$name} .= "\n".">".$annot."\n".$seq;
      }
      $tseqs{$trans} = $seq;
      last;     
    }
  }
}


print STDERR "# $cnt sequences in file $FASTAIN\n";
close(INF);

%asgene=();

foreach my $name (@names){
  $c++;
  print STDERR $name, "\n";
  if($gseqs{$name}){
    $cnt2++;
    $asgene{$name}=1;
    print "$gseqs{$name}\n";
  }
  #else{print STDERR "$name not present\n";}
}
print STDERR "########### INPUT IS GENES #############################\n";
print STDERR "#>$NAMESIN\t$c different genes\n";
print STDERR "#$cnt2 associations found ($#names should be found)\n";
print STDERR "#######################################################\n";

$c=0; $cnt2=0;
foreach my $name (@names){
  $c++;
  print STDERR $name, "\n";
  if($tseqs{$name} && !$asgene{$name}){
    $cnt2++;
    print ">$name\n$tseqs{$name}\n";
  }
  #else{print STDERR "$name not present\n";}
}

print STDERR "############# INPUT IS TRANSCRIPTS #################################\n";
print STDERR "#>$NAMESIN\t$c different genes\n";
print STDERR "#$cnt2 associations found ($#names should be found)\n";
print STDERR "#######################################################\n";
