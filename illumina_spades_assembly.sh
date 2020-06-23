#! /bin/sh

#This script performs de novo spades assembly, bowtie2 alignment and computs genome coverage. 
#Input files are fastq reads obtained from a paired-ends illumina sequencing platform (provided as _R1.fastq and _R2.fastq).

#Please read and understand this script before running your assemblies, just in case you may need to change some parameters


echo "Script usage illumina_spades_assembly.sh output_prefix"


#specify genome name
genome="$1"

mkdir -p $genome ;
cd $genome ;

spades.py -k 33,55,77,99,127 --pe1-1 ../*_R1.fastq --pe1-2 ../*_R2.fastq --careful -o $genome ;
cat ../*.fastq > input ;
cd $genome ;

quast.py contigs.fasta ;

#Perform bowtie2 alignment
bowtie2-alignment-single.sh contigs.fasta $genome input ;

#Obtain statistics
samtools depth $genome-sorted.bam |  awk '{sum+=$3} END { print "Average coverage = ",sum/NR}' > assembly_coverage ;
var=$(samtools view -c -F 260 $genome-sorted.bam); echo "Number of mapped reads = $var" >> assembly_coverage ;

#Filter-small-contigs
reformat.sh in=contigs.fasta out=$genome-contigs-filtered.fa minlength=1000 ;

#Cleanup
#rm assembly_coverage ;
rm $genome.sam ;
rm $genome.bam ;
rm input ;
cd .. ;

#Copy  assembly statistics
cat $genome/assembly_coverage $genome/quast_results/latest/report.txt > assembly_stats.txt ;

#Return to starting directory
cd .. ;

echo "Done!"
