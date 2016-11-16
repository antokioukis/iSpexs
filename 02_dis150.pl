#!/usr/bin/perl -w

$bin = "/group/tmp/mdi/bin/";
$USAGE = "02_dis150.pl FASTA=<file> BORDER=<int (uniq)>";

$BORDER = 10000000;

if($#ARGV<0){die $USAGE;}

while($args = shift @ARGV){
  if($args =~/FASTA=(.*)/i){$INFASTA=$1;}
  elsif($args =~ /BORDER=(.*)/i){$BORDER=$1;}
  else{die $USAGE;}
}

if($INFASTA=~/([^\.]+)/){$root=$1;}
$DISBORDER = "dis".$BORDER;
if($BORDER == 10000000){$DISBORDER="uniq";}

system("$bin.fasta2line.pl IN=$INFASTA OUT=$INFASTA".".fa");
$INFASTA=$INFASTA.".fa";
system("$bin.01_annot.pl IN=$INFASTA");
system("$bin.dif_start_sites.pl IN=$INFASTA".".sst"." LEFT_BORDER=$BORDER RIGHT_BORDER=$BORDER > $INFASTA".".$DISBORDER".".names");
system("$bin.sequences_from_names.pl FASTA_IN=$INFASTA".".trans.fa"." NAMES_IN=$INFASTA".".$DISBORDER".".names"." > $INFASTA".".trans.$DISBORDER".".fa");
