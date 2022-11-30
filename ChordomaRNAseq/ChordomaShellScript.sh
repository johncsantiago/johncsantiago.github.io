#!/bin/bash

#SBATCH -J Ch4_STAR.sh

#Submit cmd: sbatch -n 8 -t 16:00:00 --mem=30G Ch4_STAR.sh

##the above code to run a batch was not working and I didn't take time to fix it
##Instead I ran the batch file using the line sbatch -n 32 -t 8:00:00 --mem=64G Ch4_STAR-1.sh
workingDir="/gpfs/data/jasander/Chordoma_Data/"
sample="Ch4.NoRibosome"

cd $workingDir"star/first_pass"
module load star/2.6.1b
STAR --genomeDir "/gpfs/data/jasander/Human_Pipeline/Homo_Sapiens.r102" --readFilesIn $workingDir$sample".fastq" --runThreadN 20
STAR --runMode genomeGenerate --genomeDir $workingDir"star/second_index" --genomeFastaFiles "/gpfs/data/jasander/Human_Pipeline/Homo_Sapiens.r102/fasta/Homo_sapiens.GRCh38.dna.chromosome."* --sjdbFileChrStartEnd $workingDir"star/first_pass/SJ.out.tab" --sjdbOverhang 75 --runThreadN 20

cd $workingDir"star/second_pass"
STAR --genomeDir $workingDir"star/second_index" --readFilesIn $workingDir$sample".fastq" --runThreadN 20 --outSAMtype BAM SortedByCoordinate --outFileNamePrefix $workingDir"Output_Files/BAM/"$sample

module load samtools/1.3.1
samtools index $workingDir"Output_Files/BAM/"$sample"Aligned.sortedByCoord.out.bam"

module load python/3.7.4
module load htseq/0.11.1
htseq-count $workingDir"Output_Files/BAM/"$sample"Aligned.sortedByCoord.out.bam" "/gpfs/data/jasander/Human_Pipeline/Homo_Sapiens.r102/Homo_sapiens.GRCh38.102.gtf" -t exon -s no -r pos -i gene_id -f bam > $workingDir"Output_Files/Count_Tables/"$sample"_CountTable.txt"

