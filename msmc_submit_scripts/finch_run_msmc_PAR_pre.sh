#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=run_msmc_par_pre_all_idx
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=28
#SBATCH --time=90:00:00
##SBATCH --gres=gpu:1
#SBATCH -o msmc_par_pre_multi_all_idx_%j.out
#SBATCH -e msmc_par_pre_multi_all_idx_%j.err
##SBATCH --constraint=hi_mem
##SBATCH --mem-per-cpu=41gb

PARAMS=/xdisk/mcnew/finches/ljvossler/finches/darwin_finches/params_base_df.sh

source /xdisk/mcnew/finches/ljvossler/finches/darwin_finches/Genomics-Main/B_Phylogenetics/msmc/msmc_3_runMSMC.sh -p "${PARAMS}" -m params_msmc_df_PAR_pre.sh -i PAR_pre
