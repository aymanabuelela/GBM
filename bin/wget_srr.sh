#!/bin/bash
target=$1
link="ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByStudy/sra/SRP/SRP027/SRP027383"
log="wget_sra.log"

## Form a file of links
while read file
do
echo "$link/${file%.*}/$file" >> $target/wget_links.txt
done < $2 ## text file contains sra file names with .sra ext

cd $target                
wget -nd -r --no-parent --reject "index.html*" -c -o $log -i $target/wget_links.txt 
