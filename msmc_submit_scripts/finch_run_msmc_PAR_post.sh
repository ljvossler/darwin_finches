#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=run_msmc_par_post
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=28
#SBATCH --time=30:00:00
##SBATCH --gres=gpu:1
#SBATCH -o multi_indv_data/msmc_outs/msmc_par_post_multi.out
#SBATCH -e multi_indv_data/msmc_outs/msmc_par_post_multi.err
##SBATCH --constraint=hi_mem
##SBATCH --mem-per-cpu=41gb

PARAMS=/xdisk/mcnew/finches/ljvossler/finches/darwin_finches/params_base_df.sh

source /xdisk/mcnew/finches/ljvossler/finches/darwin_finches/Genomics-Main/B_Phylogenetics/msmc/msmc_3_runMSMC.sh -p "${PARAMS}" -m params_msmc_df_PAR_post.sh -i PAR_post
