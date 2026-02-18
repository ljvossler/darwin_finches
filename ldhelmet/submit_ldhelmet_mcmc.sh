#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=run_ldhelmet
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --ntasks-per-node=1
#SBATCH --output run_ldhelmet.out
#SBATCH --output %x_%a.out
#SBATCH --array=1-3


PARAMS=params_ldhelmet.sh

VCFFILE=par_pre.recode.vcf

CHR_LST=/xdisk/mcnew/finches/ljvossler/finches/SCAFFOLDS.txt

CHR="$( sed "${SLURM_ARRAY_TASK_ID}q;d" ${CHR_LST} )"

source ../Genomics-Main/B_Phylogenetics/ldhelmet/ldhelmet_run_mcmc.sh -p $PARAMS -d par_pre.recode -c $CHR -f .snps