#!/usr/bin/perl -w

$USAGE = "./conc.pl LIST=<ordered file list> SUFFIX=<.smt>\n

It concatanates files from an ordered list. If there
are N files it creats N new files like that:

cat file1 file2 > file1.2
cat file1 file2 file3 > file1.2.3 etc

SUFFIX = the suffix of the specific file that you would like 
to concatenate in case that this is not specified in the list
";
use lib "/home/pavlidis/MDI/bin/perl_modules";
use cat;

if($#ARGV < 0){die $USAGE;}

cat::perlcat(@ARGV);

exit;

# to test if it works until here

if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /LIST=(.*)/i){ $FILE=$1;}
  elsif($args =~ /SUFFIX=(.*)/i){ $SUFFIX=$1;}
  else{die $USAGE;}
}

$PATH .="/";
$PATH =~ s/\/\//\//g;

open (IN, $FILE) or die "Couldn't open file $FILE for reading $!\n";

@D = grep{!/^$/} <IN>;
chomp(@D);

map{print $_, "\n";} @D;

if($SUFFIX ne ""){
  foreach my $name (@D){
    push @DM,$name.$SUFFIX;
  }
}


#$f = $DM[0];

foreach my $i(0..$#D){
  @TOCONC = ();
  foreach my $j(0..$i){
    push(@TOCONC, $DM[$j])
  }
  perlcat(@TOCONC);
}

close IN;

