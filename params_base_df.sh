module load R/4.4.0
module load htslib/1.19.1
module load bedtools2/2.29.2
module load python/3.11/3.11.4
module load bwa/0.7.18
module load bcftools/1.19
module load vcftools/0.1.16
module load plink/1.9
module load samtools/1.19.2



# Define variables
# all
OUTDIR=/xdisk/mcnew/finches/ljvossler/finches    # main directory for output files
PROGDIR=/xdisk/mcnew/finches/ljvossler/programs  # path to directory for all installed programs
INDIR=/xdisk/mcnew/finches/dannyjackson/finches  # path to input files (if collaborating and input files are not near same directories as where you will be outputting)
BAMDIR=/path/to/bam/files
PROJHUB=darwin_finches
SCRIPTDIR=${OUTDIR}/${PROJHUB}
PATH=$PATH:$SCRIPTDIR # this adds the workshop script directory to our path, so that executable scripts in it can be called without using the full path
PATH=$PATH:$PROGDIR # Also adding program directory to path
ID=name_of_project
FILENAME_LIST=/xdisk/mcnew/finches/ljvossler/finches/speciescodes2.txt # list with sample or species codes associated with each file in dataset, one per line

# define aspects of the reference genome
CHRLEAD=NC_0 # characters at the start of a chromosome number (excluding scaffolds)
SEXCHR=NC_044601
REF=/path/to/reference/genome/file.fna # path to reference genome
GFF=/path/to/reference/genome/gff/genomic.gff # path to gff file

# define the path for the chromosome conversion file (converts chromosome ascension names to numbers)
CHR_FILE=/xdisk/mcnew/dannyjackson/cardinals/referencelists/GCF_901933205_chromconversion.txt

source /xdisk/mcnew/finches/ljvossler/finches/darwin_finches/base_setup_df.sh