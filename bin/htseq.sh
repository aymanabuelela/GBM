#!/bin/bash

###############################################################################
###############################################################################
##           this script takes 2 arguments:                                  ##
##           1. Number of processors (int)                                   ##
##           2. Memory allocated per processor (int)in Gbytes                ##
###############################################################################
###############################################################################


np=$1
cnt=1
tophatdirs="/media/khodieaf/Data/GBM/tophat/out.dirs"
refgenome="/ake/GT_paper/DEG/rna-seq/RefGenomeUCSC/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf"
bamdir="/media/khodieaf/Data/GBM/tophat"
sortedbam="/media/khodieaf/Data/GBM/sorted_bam"
outdir="/media/khodieaf/Data/GBM/rawcounts"

cd $bamdir

for i in SRR*
    do
    echo "[$i] `date`"

    if [ $cnt -lt $np ]
        then
        cnt=$(($cnt+1))
        samtools sort -m $2"G" "$bamdir/$i/accepted_hits.bam" "$sortedbam/$i.sorted" \
        && htseq-count -m union -t exon -i gene_id -f bam -r pos -s yes "$sortedbam/$i.sorted.bam" $refgenome > "$outdir/$i.txt" &
    else
        samtools sort -m $2"G" "$bamdir/$i/accepted_hits.bam" "$sortedbam/$i.sorted" \
        && htseq-count -m union -t exon -i gene_id -f bam -r pos -s yes "$sortedbam/$i.sorted.bam" $refgenome > "$outdir/$i.txt" &
        wait
        $cnt=1
    fi
done 
