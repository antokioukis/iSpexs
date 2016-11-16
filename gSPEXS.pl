#!/usr/bin/perl -w

$AUTHORSHIP = "
Pavlos Pavlidis
PhD Student 
University of Tartu, Estonia
email: pavlidis at egeeninc.com
supervisor: Dr. Jaak Vilo
";

$USAGE = "

NAMES=<file> It is the file with the gene names of the cluster of
the species of reference. It is located in ../data/queries/<query>/

SP=<string> The name of the organism i.e. Homo_sapiens

BACKDIR=<directory> The directory with the background files
Note that in order to use the background files properly, the 
create_background.pl should be executed before

QUERYDIR=<directory> The directory with the query files. 
Every query is a cluster of genes. Each cluster belongs 
to one species, and the clusters are connected via homology.

ORGLIST=<file> A file with the name of the species in an ordered list. 
i.e.
Homo_sapiens
Pan_troglodytes
Macaca_mulatta
e.t.c.

MS0=<int> The initial value of ms parameter of spexs. ms denotes 
how many strings from the query should be matched

MS1=<int> the incremental value of ms, i.e. how much it should be 
grown in one step. This depends on the size of the query, ms denotes 
how many strings from the query should be matched


MAXMS=<int> the maximum value that ms can obtain. ms denotes how many 
strings from the query should be matched

QUERYSUFF=<string> the suffix of the query sequences. E.g if the queries (in QUERYDIR) are Gene_species.query.fa then the QUERYSUFF should be .query.fa



";

$SUFF = ".query.fa"; # This is the suffix of the fasta sequences in the query
$QUERYSUFF="";

$DEBUG = 0;
$REF="Homo_sapiens";
$MS="";
$MINSTRINGS="";
$PATH = "./";
$MS0=-1;
$MAXMS = 30;
#$BORDER = 1000;
$MODE = "DYNAMIC";

#PATHS of the programs and data

$bin="/home/pavlidis/MDI/demo/bin/";
$data="/home/pavlidis/MDI/demo/data/";

if($#ARGV <0){die $USAGE.$AUTHORSHIP;}

while($args = shift @ARGV){
  #the names of the genes of the cluster for the species of reference
  if($args =~/NAMES=(.*)/i){$GLIST=$1;}
  elsif($args =~/SP=(.*)/i){$REF=$1;}
  #the increment of ms parameter in every step
  elsif($args =~ /MS1=(.*)/i){$MS=$1;}
  #the initial value of ms parameter of spexs algorithm
  elsif($args =~ /MS0=(.*)/i){$MS0=$1;}
  #BACKDIR and QUERYDIR contain sequences of the species
  #BACKDIR contains the background. Normally, they need,
  #preprocessing with the program create_background.pl
  #in order to be executed properly
  #
  #QUERYDIR contains the homologue clusters of genes
  #The name of the files initiate with the name of the
  #organism e.g. Pan_troglodytes.query.fa
  elsif($args =~ /QUERYSUFF=(.*)/i){$QUERYSUFF=$1;}
  elsif($args =~ /BACKDIR=(.*)/i){$BACKDIR=$1;}
  elsif($args =~ /QUERYDIR=(.*)/i){$QUERYDIR=$1;}
  #MINSTRINGS is a parameter of spexs program
  #it denotes how many strings should be matched in background and query
  elsif($args =~ /MINSTRINGS=(.*)/i){$MINSTRINGS=$1;}
  #ORGLIST is the SORTED list of organisms
  elsif($args =~ /ORGLIST=(.*)/i){$ORGFILE = $1;}
  #a parameter of spexs. It denotes the maximum value of the ms 
  #parameter
  elsif($args =~ /MAXMS=(.*)/i){$MAXMS=$1;}
  elsif($args =~ /DEBUG=(.*)/i){$DEBUG=$1;}
  else{die $USAGE."Argument $args is invalid\n";}

}

# find the basename of the file that the list of names is located
# this path is needed in order the programm to be able to put the results
# in the right directory
if($GLIST =~ /(.*)\/[^\/]+/){$PATH=$1."/";} 

if($DEBUG){
  print STDERR "Results will be put in: $PATH\n";
}

$QUERYSUFF = ".".$QUERYSUFF;
$QUERYSUFF =~ s/\.\./\./; 

if($QUERYSUFF ne "" or $QUERYSUFF ne "."){
  $SUFF=$QUERYSUFF;
}


open(ORGF, $ORGFILE) or die "Couldn't open $ORGFILE/n";
@O = grep{!/^$/} <ORGF>;
chomp(@O);
close ORGF;


##########  COMMENT FOR THE DEMO VERSION  ###################################
#                                                                           #
# This version takes as input pre-calculated orthologue sequences           #
# the 'full' version computes the orthologues                               #
# however it is impossible to demonstrate the algorithm using the           #
# full version, since a vast amount of data from ENSEMBL is required.       #
# On the other hand this demo version requires only a small amount of data  #
#############################################################################


# START to concatenate the files. It's the APPEND function in the paper
# The results are .con files (concatenated files)

foreach my $i(0..$#O){
  $toconcatanate = "";
  foreach my $j(0..$i){
    $INDCLUSTER = $QUERYDIR.$O[$j].$SUFF;
    $toconcatanate .= $INDCLUSTER."\t";
  }
  system("$bin"."conc.pl $toconcatanate  > $PATH"."$O[$i].con");
}

$ms = $MS;
if($MS eq "") {$ms = 0};
$minstrings = $MINSTRINGS;

open(CON, "$PATH"."$O[0]".".con") or die "Couldn't open con file\n";
@CF = grep{/^>/}<CON>;
$sq = scalar @CF;
close CON;

# The main procedure that involves spexs algorithm
# It's the motif discovery procedure

if($sq < 5){$ms0=1;}
elsif($sq < 30){$ms0=2;}
elsif($sq < 60){$ms0=3;}
elsif($sq < 100){$ms0=4;}
elsif($sq < 150){$ms0=5;}
elsif($sq >= 150){$ms0=6;}


$i=0; 
if(($MS0 != -1) && ($sq >=5)){$ms0 = $MS0;}
foreach my $org(@O){
  $con = $org.".con";
  if($MS eq ""){
    $ms += $ms0;
    $ms2 = 5;
    
    if($ms > $MAXMS){$ms = $MAXMS;}
    $minstrings = $ms;
  }
  if($MODE eq "DYNAMIC"){
    $BD = $BACKDIR."/";
    $BD =~ s/\/\//\//g;
    $backcon=$org.".con";
    $BACKGROUND = $BD.$backcon;
    print STDERR "# MS: $ms\/$ms2\n";
    #The path information exists already in conlist.txt
  }
  # Here the spexs algorithm is executed
  system("$bin"."SPEXS.pl Q=$PATH"."$con MS=$ms B=$BACKGROUND PR=1e-03 RATIO=2   MINSTRINGS=$minstrings MS2=$ms2");
  # The results of spexs are parsed. This is needed for two reasons:
  # 1. In order to remove the inappropriate characters that exist there
  # 2. Because there is a bug in spexs and it doesn't return the results
  # that it should return. Speciffically, the minstrings and ms flags 
  # don't work correctly.
  system("$bin"."grep_spexs_file.pl IN=$org".".con.spx NUM=$i PATH=$PATH MS=$ms MS2=$ms2 MINSTRINGS=$minstrings");
  $i++;
}

# remove the all_1e-03_r2.allspx if exists
if(-e "all_1e-03_r2.allspx"){
  unlink($PATH."all_1e-03_r2.allspx") or print STDERR "Cannot unlink all_1e-03_r2.allspx\n";
}

system("cat $PATH"."*.s.spx >> $PATH"."all_1e-03_r2.allspx");



# RT-SPEXS.pl will take all the resutls from spexs and will create the graphs
system("$bin"."RT-SPEXS.pl IN=$PATH"."all_1e-03_r2.allspx PATH=$PATH");

# just a filter in order to get only the best 100 motifs.
system("$bin"."filter_lines.pl IN=$PATH"."PLOT.txt BEST=100 > $PATH"."all_1e-03_r2.100.dat");

# system("$bin.kmeans -c 10 -f $PATH"."all_1e-03_r2.100.dat > $PATH"."all_1e-03_r2.100.cst"); not need in this version
# system("$bin.plot_clustered_patterns.pl PATH=$PATH DATA=$PATH"."all_1e-03_r2.100.dat CLUST=$PATH"."all_1e-03_r2.100.cst MIN=1e-15");


# report the best patterns
system("$bin"."report_best_patterns.pl IN=$PATH"."all_1e-03_r2.100.dat > $PATH"."best_patterns.txt");



#CREATE DIRECTORIES

# The list of the gene names
# of the cluster will be put here
if(! -e "$PATH"."GLIST"){
  mkdir ($PATH."GLIST", 0755) || print STDERR "Cannot create directory $PATH"."GLIST\n";
}

#if(! -e $PATH."ENS_files"){
#  mkdir ($PATH."ENS_files", 0755) || print STDERR "Cannot create directory $PATH"."ENS_files\n";
#}

#if(! -e  $PATH."ANNOT_files"){
#  mkdir($PATH."ANNOT_files", 0755) || print STDERR "Cannot create directory $PATH"."ANNOT_files\n";
#}

# make a directory 
# for orthologue clusters
#if(! -e $PATH."GEN_files"){
#  mkdir($PATH."GEN_files", 0755) || print STDERR "Cannot create directory $PATH"."GEN_files\n";
#}


if(! -e $PATH."CON_files"){
  mkdir ($PATH."CON_files", 0755) || print STDERR "Cannot create directory $PATH"."CON_files\n";
}

if(! -e $PATH."SPEXS_files"){
  mkdir ($PATH."SPEXS_files",0755) || print STDERR "Cannot create directory $PATH"."SPEXS_files\n";
}

if(! -e $PATH."RESULTS"){
  mkdir($PATH."RESULTS",0755) || print STDERR  "Cannot create directory $PATH"."RESULTS\n";
}


#MOVE FILES TO THE PROPER DIRECTORIES

rename($GLIST, $PATH."GLIST");
#########     NOT NEEDED FOR DEMO VERSION   ##########
#system("mv $PATH"."*.gen $PATH"."GEN_files");
#system("mv $GLIST $PATH"."GEN_files/$REF".".gen");
#system("mv $GLIST $PATH"."$REF".".gen");
#system("mv $PATH"."*.fa $PATH"."ENS_files");
######################################################

system("mv $PATH"."*.con $PATH"."CON_files");
system("mv $PATH"."*.spx $PATH"."SPEXS_files");
system("mv $PATH"."*.s.spx $PATH"."SPEXS_files");
system("mv $PATH"."*.png $PATH"."PLOT.txt $PATH"."*.dat $PATH"."*.cst $PATH"."best_patterns.txt $PATH"."RESULTS");


