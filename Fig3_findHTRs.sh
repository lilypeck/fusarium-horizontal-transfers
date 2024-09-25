## script developed by @XX
module load anaconda3
conda create --name findHTRs --file findHTRS.text
conda activate findHTRs

cd [directory with reference genome and genomes to compare against reference]
strain="Fxyl_389563.LR" # this is name of reference genome
referencegenome="${strain}flye.fa"
referencestrain=${strain}

samtools faidx ${referencegenome}
##use bed file to generate a window based bed file which will be used to calculate the coverage and identity in these bins
window=10000
##distance for the window to move before recalculating the window
slide=0
##reformatting window and slide numbers for directory generation in kb
window2=$( echo $window | awk '{print $0/1000}' )
slide2=$( echo $slide | awk '{print $0/1000}' )
##make a window file 
##first need a reference bed file, can use the fai index
cat ${referencegenome}.fai | cut -f1-2 > ${referencegenome3}.bed
##now split it up into the above prescribed bins - remove -s if not using slide
bedtools makewindows -w ${window} -g ${referencegenome3}.bed > ${referencegenome3}.${window2}kbwindow_${slide2}kbslide.bed

## run loop to compare comparison strain to reference strain
## output is tsv file with mean % similarity in 10kb windows and 2.5kb slide
## this is because it takes the mean of 7th col of cov.tsv (which is % similarity)

ls *.fna | while read comparison; do comparisonstrain=$( echo $comparison | awk -F "/" '{print $NF}' | awk -F "." '{print $1.$2}' ); minimap2 -cx asm10 --secondary=no --cs ${referencegenome} ${comparison} | sort -k6,6 -k8,8n > ${comparisonstrain}.minimap2_${referencestrain}.paf; paftools.js splice2bed ${comparisonstrain}.minimap2_${referencestrain}.paf > ${comparisonstrain}.minimap2_${referencestrain}.bed; bedtools makewindows -w 100 -s 100 -g ${referencegenome3}.bed > ${referencegenome3}.short.bed; bedtools coverage -a ${referencegenome3}.short.bed -b ${comparisonstrain}.minimap2_${referencestrain}.bed > ${comparisonstrain}.minimap2_${referencestrain}.cov.tsv; bedtools map -b ${comparisonstrain}.minimap2_${referencestrain}.cov.tsv -a ${referencegenome3}.${window2}kbwindow_${slide2}kbslide.bed -c 7 -o mean > ${comparisonstrain}.minimap2_${referencestrain}.cov.binned.tsv; done
