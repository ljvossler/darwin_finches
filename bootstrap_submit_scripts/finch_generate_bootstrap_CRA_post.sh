#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=generate_bootstrap_cra_post
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
##SBATCH --gres=gpu:1
#SBATCH -o /xdisk/mcnew/finches/ljvossler/finches/msmc/start_bootstrapping_cra_post.out
#SBATCH -e /xdisk/mcnew/finches/ljvossler/finches/msmc/start_bootstrapping_cra_post.err
##SBATCH --constraint=hi_mem
##SBATCH --mem-per-cpu=41gb

PARAMS=/xdisk/mcnew/finches/ljvossler/finches/darwin_finches/params_base_df.sh

source /xdisk/mcnew/finches/ljvossler/finches/darwin_finches/Genomics-Main/B_Phylogenetics/msmc/msmc_4_generate_bootstraps.sh -p "${PARAMS}" -m params_msmc_df_CRA_post.sh -i CRA_post
