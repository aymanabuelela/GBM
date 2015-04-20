## Convert sra to fastq using fastq-dump
np=6
cnt=1
for i in *sra
	do
	if  [ $cnt -lt $np ]
		then
		echo $(date) : $i
		/home/khodieaf/ayman/sources/SRAToolkit/sratoolkit.2.4.2-ubuntu64/bin/fastq-dump -O ./fastq/ $i &
		cnt=$(($cnt+1))
		
		echo
	else
		/home/khodieaf/ayman/sources/SRAToolkit/sratoolkit.2.4.2-ubuntu64/bin/fastq-dump -O ./fastq/ $i &
		wait

		cnt=1
		echo
	fi
done

## concatenate fastq files of seq runs for one sample into one sample file
### python script
python /ake/GT_paper/DEG/rna-seq/fastq/collect_seqfiles.py


## Align reads using Tophat
np=4
count=1
refgen=/ake/GT_paper/DEG/rna-seq/RefGenomeUCSC/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf
tindex=/tmp/HumanTranscriptomeIndex
bindex=/ake/GT_paper/DEG/rna-seq/RefGenomeUCSC/Homo_sapiens/UCSC/hg19/Sequence/BowtieIndex/genome

#tophat -G $refgen --transcriptome-index=$tindex $bindex

cd /ake/GT_paper/DEG/rna-seq/samples_fastq

for sample in healthy*
do
	if [ $count -lt $np ]
		then
		cd ../tophat_out_SS/
		echo $(date) : $sample
		outdir=$sample
		mkdir -p $outdir
 		tophat -o $outdir --bowtie1 -p 2 --solexa-quals --library-type fr-secondstrand -G $refgen --transcriptome-index=$tindex $bindex ../samples_fastq/$sample &
		count=$(($count+1))
		cd ../samples_fastq
	else
		cd ../tophat_out_SS/
		echo $(date) : $sample
		outdir=$sample
                mkdir -p $outdir
 		tophat -o $outdir --bowtie1 -p 2 --solexa-quals --library-type fr-secondstrand -G $refgen --transcriptome-index=$tindex $bindex ../samples_fastq/$sample &
		cd ../samples_fastq
		count=1
		wait
	fi
done


for sample in healthy*
	do
	if [ -f $sample/align_summary.txt ]
		then continue
	
	else
		echo $sample ":" $(date)
		tophat -o $sample --bowtie1 -p 8 --solexa-quals -G $refgen --transcriptome-index=$tindex $bindex ../samples_fastq/$sample
	wait
	fi
done

## Raw counts using HTSeq
cd /ake/GT_paper/DEG/rna-seq/tophat_out_SS/
np=6
count=1
refgen=/ake/GT_paper/DEG/rna-seq/RefGenomeUCSC/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf
mkdir -p ../bams_SS
mkdir -p ../rawcounts_SS
for i in healthy-*
do
	if [ $count -lt $np ]
		then
		echo $i : $(date)
		cp $i/accepted_hits.bam ../bams_SS/
		mv ../bams_SS/accepted_hits.bam ../bams_SS/$i.bam
#		bash /ake/GT_paper/DEG/rna-seq/run_htseq.sh /ake/GT_paper/DEG/rna-seq/bams/$i.bam $refgen /ake/GT_paper/DEG/rna-seq/rawcounts/$i.txt &
		samtools sort -m 3G ../bams_SS/$i.bam ../bams_SS/"sorted_"$i \
		&& htseq-count -m union -t exon -i gene_id -f bam -r pos -s yes ../bams_SS/"sorted_"$i.bam $refgen > ../rawcounts_SS/$i.txt &
		count=$(($count+1))
	else
		echo $i : $(date)
		cp $i/accepted_hits.bam ../bams_SS/
		mv ../bams_SS/accepted_hits.bam ../bams_SS/$i.bam
#		bash /ake/GT_paper/DEG/rna-seq/run_htseq.sh /ake/GT_paper/DEG/rna-seq/bams/$i.bam $refgen /ake/GT_paper/DEG/rna-seq/rawcounts/$i.txt &
		samtools sort -m 3G ../bams_SS/$i.bam ../bams_SS/"sorted_"$i \
		&& htseq-count -m union -t exon -i gene_id -f bam -r pos -s yes ../bams_SS/"sorted_"$i.bam $refgen > ../rawcounts_SS/$i.txt &
		wait
		count=1
	fi
done


## Join raw counts files into one file
### *** make sure that all file have the same number of lines ***

cd /ake/GT_paper/DEG/rna-seq/rawcounts_txs
#echo gene_id > header.txt

for i in healthy-*
do
	if [ -f rawcounts.txt ]
		then
#		sort -t $'\t' -k 1 $i | join - rawcounts.txt > tmpo
#		sort -t $'\t' -k 1 tmpo > rawcounts.txt
		join rawcounts.txt $i > tmpo
		mv tmpo rawcounts.txt
		echo ${i%.*} >> header.txt
	else
		cp $i rawcounts.txt
#		sort -t $'\t' -k 1 $i > rawcounts.txt
		echo ${i%.*} >> header.txt
	fi
done

