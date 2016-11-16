#!/usr/bin/perl -w

$USAGE = "dif_start_sites.pl IN=<file> LEFT_BORDER=<INT>, RIGHT_BORDER=<INT>\n
The input is in the format \n\n
ENSG00000159377 ENST00000290541 149610623 1\n
ENSG00000159377 ENST00000368866 149638634 1\n
ENSG00000161057 ENST00000292644 102775325 1\n
ENSG00000163636 ENST00000295901 63971271 1\n
ENSG00000165916 ENST00000298852 47396896 -1\n
ENSG00000173692 ENST00000308696 231629836 -1\n\n
It calculates the difference (Maximum or Minimum) in the third column of transcripts that have the same first column\n";


if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /IN=(.*)/i){$INPUT=$1;}
  elsif($args =~ /LEFT_BORDER=(.*)/i){$LEFT_BORDER=$1;}
  elsif($args =~ /RIGHT_BORDER=(.*)/i){$RIGHT_BORDER=$1;}
  else{die $USAGE;}
}

open(INFILE, $INPUT) or die "Couldn't open $INFILE for reading\n";

@DATA = grep {!/[#!>]/} <INFILE>;
chomp @DATA;

map{@V = split /\s+/; push @GENE, shift @V;  $transcript = shift @V; push @TRANS, $transcript; $stsite=shift @V; push @SST, $stsite; $orientation = shift @V; push @ORIENT, $orientation; $StartSite{$transcript}=$stsite;} @DATA;

foreach my $i (0..$#GENE){
  if(!$mstart{$GENE[$i]}){
    $mstart{$GENE[$i]} = $SST[$i];
  }
  else{$mstart{$GENE[$i]} .= "\t$SST[$i]";}

  $orient{$GENE[$i]}=$ORIENT[$i];

  if(!$mtrans{$GENE[$i]}){
    $mtrans{$GENE[$i]} = $TRANS[$i];
  }
  else{$mtrans{$GENE[$i]} .= "\t$TRANS[$i]";}
}


$BREAK=0;
foreach my $gene (keys %mstart){
  @V = split /\s+/, $mstart{$gene};
  @T = split /\s+/, $mtrans{$gene};


  my %SSTrans=();
  foreach my $i (0..$#T){
    $SSTrans{$T[$i]} = $V[$i];
    #print $gene, "\t", $T[$i], "  ***STARTS***  ", $SSTrans{$T[$i]}, "\n";
  }


  if($orient{$gene}==1){
    @SV = sort {$b<=>$a} @V;
    @ST = sort {$SSTrans{$b}<=>$SSTrans{$a}} keys %SSTrans;
  }
  elsif($orient{$gene}==-1){
    @SV = sort {$a<=>$b} @V;
    @ST = sort {$SSTrans{$a}<=>$SSTrans{$b}} keys %SSTrans;
  }
  else{die "Ti skata einai auta $orient{$gene} ?\n";}

  $mtrans{$gene}=""; #reset the list

  foreach my $trans (@ST){
    if($mtrans{$gene} eq ""){$mtrans{$gene} = $trans;}
    else{$mtrans{$gene} .= "\t$trans";}
  }
  #print "NEW ORDER of $gene", $mtrans{$gene}, "\n";

  #### UP TO NOW SORTED LISTS OF TRANSCRIPTS PER GENE ####	



  $BREAK=0;
  $c1=0; $c2=0;
  foreach $i(0..$#SV){
    $c2=0;
    foreach $j ($i..$#SV){
     
      $dif = abs($SV[$j] - $SV[$i]);
      #print STDERR $gene, "\t", $i, "\t", $j,"\t", $dif, "\n";
      if(($dif>$LEFT_BORDER) && ($dif<$RIGHT_BORDER)){
	$BREAK=1; # Exclude the gene from further analysis
	#print STDERR $gene, " **\n";
	last;
      }
      $c2=$j+1;
    }
    $c1=$i+1;
    if($BREAK) {#print STDERR $gene, " --\n"; 
      last;
    } # Exclude the gene from further analysis
  }

  #print STDERR "$c1,$c2\t",$c1*$c2, "\tvs ", ($#SV+1)*($#SV+1), "\n";
  if(($c1*$c2) == (($#SV+1)*($#SV+1))){ # IF ALL the distances are ok
    push @GENE_FOR_ANAL, $gene;
    #print STDERR $gene, "\n";
  }
}

@SORTED_Gene_For_Anal = sort {$a cmp $b} @GENE_FOR_ANAL;
$prev = "not equal to $SORTED_Gene_For_Anal[0]";
@UNIQ_GENE_FOR_ANAL = grep($_ ne $prev && ($prev = $_, 1), @SORTED_Gene_For_Anal);


@all_trans=();
foreach my $gene (@UNIQ_GENE_FOR_ANAL){
  @dist_trans=();
  my @transcripts = split /\s+/, $mtrans{$gene};
  #print STDERR $mtrans{$gene}, "\n";

  $TRANSCRIPT_LIST{$transcripts[0]}="";
  push @dist_trans, $transcripts[0];
  push @all_trans, $transcripts[0];

  #print $gene, "\t", $transcripts[0], " *  $mtrans{$gene} -----\n";

  foreach my $trans(@transcripts){
    foreach my $t (@dist_trans){
      if(($dif = abs($StartSite{$t} - $StartSite{$trans}))<$LEFT_BORDER){
	$all=0;
	last;
      }
      else{$all=1;}
    }
    if($all){
      push @dist_trans, $trans;
      push @all_trans, $trans;
      
      # $TRANSCRIPT_LIST{$trans}="";
      #print STDERR $gene, "\t***\t", $trans, "\n";
    }
  }
}

foreach my $trans (@all_trans){
  print $trans, "\n";
}

#print STDERR "###############################\n";
#foreach my $trans (keys %TRANSCRIPT_LIST){
  #print $trans, "\n";
#}

