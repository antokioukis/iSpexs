#!/usr/bin/perl 
$AUTHOR="
Pavlos Pavlidis
PhD Student
University of Tartu, Estonia
pavlidis at egeeninc.com
";

$USAGE="
It creates the background files given
the sequences of the individual species
and the order of the organisms.
Basically it is a concatanation of ordered files


This should be ran before the iSPEXS.pl in order to create the
background files

create_background.pl ORDER=../data/distances/Homo_sapiens.org 
SUFFIX=.background.fa PATH=../data/background/

ORDER=<file> the ordered list of organisms. Usually it is located 
in ../data/distances/

SUFFIX=<string> the suffix of the background containing files 
i.e. in Homo_sapiens.background.fa the suffix is .background.fa 
(background.fa should work also)

PATH=<directory> the directory where the background files 
are located. In the same place the *.con files will be created. 
The *.con files are the concatenated background files which will
 be used later in the analysis


";


if($#ARGV < 0){die $AUTHOR.$USAGE;}

$bin = "/home/pavlidis/MDI/demo/bin/";
$path = "./";
while($args = shift @ARGV){
  if($args =~ /ORDER=(.*)/i){$order=$1;}
  elsif($args =~ /SUFFIX=(.*)/i){$suffix=$1;}
  elsif($args =~ /PATH=(.*)/i){$path=$1;}
}

$path .= "/";
$suffix = ".".$suffix;

$suffix =~ s/^\.\./\./;

#print STDERR "#$suffix\n";

open(ORD, $order) or die "Couldn't open the species-ordered file $ord\n";
@O = grep {!/^$/} <ORD>;
chomp(@O);
close ORD;

#check if files exist
$i=0;
foreach my $org(@O){
  $file = $path.$org.$suffix;
  if(! -e $file){ warn "$file does not exist in $path\n";}
  $toconcatanate = "";
  foreach my $j(0..$i){
    $f = $path.$O[$j].$suffix;
    $toconcatanate .= $f."\t";
  }
  system("$bin"."conc.pl $toconcatanate > $path"."$org.con");
  $i++;
}
