
# you need the 'Homo_sapiens.names'
#generate the random files (10x188) 
# mkdir the folders and cp each one in its folder
m=0; for i in `cat sizes.txt `; do m=$(($m+1)); for j in `seq 10`; do /group/tmp/mdi/bin/random_name_selection.pl IN=Homo_sapiens.names NUM=$i OUT=rand_${m}_${j}.txt; mkdir RAND_${m}_${j}; cp rand_${m}_${j}.txt RAND_${m}_${j}; done; done;

# first check out for only one run (You should run this in /group/tmp/mdi/query/random_01
mkdir test;
cp -r RAND_1_1/ test/

gSPEXS.pl NAMES=test/RAND_1_1/rand_1_1.txt BACKDIR=/group/tmp/mdi/data/BACKGROUND_files/Homo_sapiens/DYNAMIC/RAND/BGRD/ BORDER=1000 MODE=DYNAMIC SP=Homo_sapiens MS0=2

# for each one run gSPEXS.pl (You should run this in /group/tmp/mdi/query/random_01

#for i in `seq 188`; do for j in `seq 10`; do /group/tmp/mdi/bin/gSPEXS.pl NAMES=RAND_${i}_${j}/rand_${i}_${j}.txt BACKDIR=/group/tmp/mdi/data/BACKGROUND_files/Homo_sapiens/DYNAMIC/RAND/BGRD/ BORDER=1000 MODE=DYNAMIC SP=Homo_sapiens MS0=2; done; done;

#if we need to run this for a different set of parameteres that we must generate again the random files


