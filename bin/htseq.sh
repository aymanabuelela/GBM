#!/bin/bash

np=$1
cnt=1

if [ $# -lt 7 ]; then
    echo "ERROR: one or more arguments are missing!!

This script takes 7 arguments:
        1. Number of processors                     (int)
        2. Memory allocated per processor in Gb     (int)
        3. tophat output folders to be processed    (text file)
        4. tophat folder                            (full path)
        5. sorted bam folder                        (full path)
        6. reference genome gtf file                (full path)
        7. rawcounts folder                         (full path)"
    exit 0
fi

htseqFun () 
{       
    samtools sort -m $2"G" $4/$i/"accepted_hits.bam" $5/$i".sorted" \
    && htseq-count -m union -t exon -i gene_id -f bam -r pos -s yes \
        $5/$i".sorted.bam" $6 > $7/$i".txt" \
    && rm $5/$i".sorted.bam" &
}

while read i; do
    echo "[$i] `date`"

    if [ $cnt -lt $np ]; then
        htseqFun
        cnt=$(($cnt+1))
    else
        htseqFun
        wait
        cnt=1
    fi
done < $3
