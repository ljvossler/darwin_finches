#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=ldhelmet_input_generation
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --ntasks-per-node=1
#SBATCH --output ldhelmet_input_generation.out


PARAMS=params_ldhelmet.sh

VCFFILE=par_pre.recode.vcf

CHR_LST=/xdisk/mcnew/finches/ljvossler/finches/SCAFFOLDS.txt


source Genomics-Main/B_Phylogenetics/ldhelmet/ldhelmet_input_generation.sh -p $PARAMS -v $VCFFILE -c $CHR_LST