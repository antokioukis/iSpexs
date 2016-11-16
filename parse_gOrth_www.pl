#!/usr/bin/perl -w

$USAGE = "
Given a list of genes from an organism and the target organism
It retreives the page from the gOrth and parses it
making a file for the source and the target organisms

GENES: List of genes .
One gene per line, stored in a file

UNIQ = <T,F> default:F
It returns only the results where the o# field is .1

COMPLETE = <T,F> default:F
If it is true it creates a list 1-1 with the source genes.
That means that if there is no ortholog for a gene it will put 
N/A in the corresponding line.
It can be combined with the UNIQ flag

SOURCE: the source organism
The format should be:
agambiae > Anopheles gambiae
btaurus > Bos taurus
celegans > Caenorhabditis elegans
cfamiliaris > Canis familiaris
cintestinalis > Ciona intestinalis
csavignyi > Ciona savignyi
drerio > Danio rerio
dnovemcinctus > Dasypus novemcinctus
dmelanogaster > Drosophila melanogaster
etelfairi > Echinops telfairi
ggallus > Gallus gallus
gaculeatus > Gasterosteus aculeatus
hsapiens > Homo sapiens
lafricana > Loxodonta africana
mmulatta > Macaca mulatta
mdomestica > Monodelphis domestica
mmusculus > Mus musculus
ocuniculus > Oryctolagus cuniculus
ptroglodytes > Pan troglodytes
rnorvegicus > Rattus norvegicus
scerevisiae > Saccharomyces cerevisiae
trubripes > Takifugu rubripes
tnigroviridis > Tetraodon nigroviridis
xtropicalis > Xenopus tropicalis

TARGET: the target organisms
The format is:

AAEGYPTI  >  A.aegypti
AGAMBIAE  > A.gambiae
BTAURUS  > B.taurus
CELEGANS  > C.elegans
CFAMILIARIS  > C.familiaris
CINTESTINALIS  > C.intestinalis
CSAVIGNYI  > C.savignyi
DMELANOGASTER  > D.melanogaster
DNOVEMCINCTUS  > D.novemcinctus
DRERIO  > D.rerio
ETELFAIRI  > E.telfairi
GACULEATUS  > G.aculeatus
GGALLUS  > G.gallus
LAFRICANA  > L.africana
MDOMESTICA  > M.domestica
MMULATTA  > M.mulatta
MMUSCULUS  > M.musculus
OCUNICULUS  > O.cuniculus
OLATIPES  > O.latipes
PTROGLODYTES  > P.troglodytes
RNORVEGICUS  > R.norvegicus
SCEREVISIAE  > S.cerevisiae
TNIGROVIRIDIS  > T.nigroviridis
TRUBRIPES  > T.rubripes
XTROPICALIS  > X.tropicalis

parse_gOrth_www.pl SOURCE=<org> TARGET=<org> GENES=<file> UNIQ=<T,F> COMPLETE=<T,F>

";



$PATH="./";

$UNIQ="F";
$COMPLETE="F";

if($#ARGV < 0){die $USAGE;}
while($args = shift @ARGV){
  if($args =~ /GENES=(.*)/){$GENEFILE = $1;}
  elsif($args =~ /SOURCE=(.*)/){$SOURCE = $1;}
  elsif($args =~ /TARGET=(.*)/){$TARGET = $1;}
  elsif($args =~ /COMPLETE=(.*)/){$COMPLETE=$1;}
  elsif($args =~ /UNIQ=(.*)/i){$UNIQ = $1;}
  elsif($args =~ /PATH=(.*)/i){$PATH = $1;}
  else{die $USAGE."\n# Option $args is not correct\n";}
}


### MAP THE TARGET NAMES TO gORTH names #####
if($TARGET eq "Homo_sapiens"){$TARGET = "HSAPIENS";}
elsif($TARGET eq "Pan_troglodytes"){$TARGET ="PTROGLODYTES";}
elsif($TARGET eq "Macaca_mulatta"){$TARGET = "MMULATTA";}
elsif($TARGET eq "Mus_musculus"){$TARGET ="MMUSCULUS";}
elsif($TARGET eq "Rattus_norvegicus"){$TARGET ="RNORVEGICUS";}
elsif($TARGET eq "Oryctolagus_cuniculus"){$TARGET ="OCUNICULUS";}
elsif($TARGET eq "Canis_familiaris"){$TARGET ="CFAMILIARIS";}
elsif($TARGET eq "Bos_taurus"){$TARGET ="BTAURUS";}
elsif($TARGET eq "Dasypus_novemcinctus"){$TARGET ="DNOVEMCINCTUS";}
elsif($TARGET eq "Loxodonta_africana"){$TARGET ="LAFRICANA";}
elsif($TARGET eq "Echinops_telfairi"){$TARGET ="ETELFAIRI";}
elsif($TARGET eq "Monodelphis_domestica"){$TARGET ="MDOMESTICA";}
elsif($TARGET eq "Gallus_gallus"){$TARGET ="GGALLUS";}
elsif($TARGET eq "Xenopus_tropicalis"){$TARGET ="XTROPICALIS";}
elsif($TARGET eq "Danio_rerio"){$TARGET ="DRERIO";}
elsif($TARGET eq "Takifugu_rubripes"){$TARGET ="TRUBRIPES";}
elsif($TARGET eq "Tetraodon_nigroviridis"){$TARGET ="TNIGROVIRIDIS";}
elsif($TARGET eq "Gasterosteus_aculeatus"){$TARGET ="GACULEATUS";}
elsif($TARGET eq "Ciona_intestinalis"){$TARGET ="CINTESTINALIS";}
elsif($TARGET eq "Ciona_savignyi"){$TARGET ="CSAVIGNYI";}
elsif($TARGET eq "Drosophila_melanogaster"){$TARGET ="DMELANOGASTER";}
elsif($TARGET eq "Anopheles_gambiae"){$TARGET ="AGAMBIAE";}
elsif($TARGET eq "Aedes_aegypti"){$TARGET ="AAEGYPTI";}
elsif($TARGET eq "Caenorhabditis_elegans"){$TARGET ="CELEGANS";}
elsif($TARGET eq "Saccharomyces_cerevisiae"){$TARGET ="SCEREVISIAE";}


if($SOURCE eq "Homo_sapiens"){$SOURCE = "hsapiens";}
elsif($SOURCE eq "Pan_troglodytes"){$SOURCE ="ptroglodytes";}
elsif($SOURCE eq "Macaca_mulatta"){$SOURCE = "mmulata";}
elsif($SOURCE eq "Mus_musculus"){$SOURCE ="mmusculus";}
elsif($SOURCE eq "Rattus_norvegicus"){$SOURCE ="rnorvegicus";}
elsif($SOURCE eq "Oryctolagus_cuniculus"){$SOURCE ="ocuniculus";}
elsif($SOURCE eq "Canis_familiaris"){$SOURCE ="cfamiliaris";}
elsif($SOURCE eq "Bos_taurus"){$SOURCE ="btaurus";}
elsif($SOURCE eq "Dasypus_novemcinctus"){$SOURCE ="dnovemcinctus";}
elsif($SOURCE eq "Loxodonta_africana"){$SOURCE ="lafricana";}
elsif($SOURCE eq "Echinops_telfairi"){$SOURCE ="etelfairi";}
elsif($SOURCE eq "Monodelphis_domestica"){$SOURCE ="mdomestica";}
elsif($SOURCE eq "Gallus_gallus"){$SOURCE ="ggallus";}
elsif($SOURCE eq "Xenopus_tropicalis"){$SOURCE ="xtropicalis";}
elsif($SOURCE eq "Danio_rerio"){$SOURCE ="drerio";}
elsif($SOURCE eq "Takifugu_rubripes"){$SOURCE ="trubripes";}
elsif($SOURCE eq "Tetraodon_nigroviridis"){$SOURCE ="tnigroviridis";}
elsif($SOURCE eq "Gasterosteus_aculeatus"){$SOURCE ="gaculeatus";}
elsif($SOURCE eq "Ciona_intestinalis"){$SOURCE ="cintestinalis";}
elsif($SOURCE eq "Ciona_savignyi"){$SOURCE ="csavignyi";}
elsif($SOURCE eq "Drosophila_melanogaster"){$SOURCE ="dmelanogaster";}
elsif($SOURCE eq "Anopheles_gambiae"){$SOURCE ="agambiae";}
elsif($SOURCE eq "Aedes_aegypti"){$SOURCE ="aaegypti";}
elsif($SOURCE eq "Caenorhabditis_elegans"){$SOURCE ="celegans";}
elsif($SOURCE eq "Saccharomyces_cerevisiae"){$SOURCE ="scerevisiae";}



open(GENEFILE, $GENEFILE) or die "Couldn't open $GENEFILE\n";
@GENES = grep{!/^$/} <GENEFILE>;
chomp(@GENES);
close GENEFILE;
print STDERR "The GENES file has ".scalar @GENES." genes\n";
$TOTAL=0;
$servlim = 400;
$Q = "";
$SUC++;

while(($g = shift @GENES) || ($Q ne "")){
  if(($cnt < $servlim) && (length($g)!=0)){
    $Q .= $g."+";
    $cnt++;
    $TOTAL++;
    next;
  }
  @IND=();
  @SORT=();
  @TARGET=();
  $Q =~ s/\+$//;
  print STDERR "# Query length = ", $cnt,"\n";
  $gOrth = "http://www.bioinf.ebc.ee/GOST/gorth.cgi?query=$Q"."&organism=$SOURCE"."&target=$TARGET"."&output=txt&hidden=1"; 
  

  system("wget -q \"$gOrth\" -O $SOURCE"."_$TARGET".".html");
  
  
  $GORTHFILE = $SOURCE."_$TARGET".".html";
  open(GORTH, $GORTHFILE) or die "Couldn't open $GORTHFILE for reading\n";
  @G = grep{!/^$/} <GORTH>;
  chomp(@G);
  close GORTH;

  
  
  while($line = shift @G ) {
    @V=split/\s+/,$line;
    push @IND, shift @V;
    shift @V;
    shift @V;
    push @SORT, shift @V;
    push @TARGET, shift @V;
  }
  
  if($COMPLETE =~/^F/i){
    foreach my $i (0..$#IND){
      if($UNIQ =~ /^T/i){
	if($SORT[$i] =~ /\.1$/){print $TARGET[$i],"\n"; $SUC++;}
      }
      elsif($TARGET[$i] !~ /N\/A/){ 
	print $TARGET[$i],"\n";
	$SUC++;
      }
    }
  }
  elsif($COMPLETE=~/^T/i){
    foreach my $i (0..$#IND){
      if($UNIQ =~ /^T/i){
	if(($SORT[$i] =~ /\.1$/) || ($SORT[$i] =~ /N\/A/)){$SUC++; print $TARGET[$i],"\n";}
      }
      else{ 
	print $TARGET[$i],"\n"; $SUC++;
      }
    }
  }
  $Q="";
  $cnt=0;
}

print STDERR "# $SOURCE ==> $TARGET ($TOTAL ==> $SUC) #\n";
  

