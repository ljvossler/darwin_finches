#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=run_msmc_cra_post
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=30
#SBATCH --time=24:00:00
##SBATCH --gres=gpu:1
#SBATCH -o multi_indv_data/msmc_outs/msmc_cra_post_multi_16segments.out
#SBATCH -e multi_indv_data/msmc_outs/msmc_cra_post_multi_16segments.err
##SBATCH --constraint=hi_mem
##SBATCH --mem-per-cpu=41gb

PARAMS=/xdisk/mcnew/finches/ljvossler/finches/darwin_finches/params_base_df.sh

source /xdisk/mcnew/finches/ljvossler/finches/darwin_finches/Genomics-Main/B_Phylogenetics/msmc/msmc_3_runMSMC.sh -p "${PARAMS}" -m params_msmc_df_CRA_post.sh -i CRA_post
