#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=gone2
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --output %x_%a.out
#SBATCH --array=1-6


PARAMS=params_base.sh

ARRAY_NAME=gone_run1 # Be sure to rename this parameter if you wish to keep mulitple gone2 runs. Otherwise, all files in an existing array folder will be overwritten.

POPPARAMS="$( sed "${SLURM_ARRAY_TASK_ID}q;d" GONEINPUTPOPS )"


source run_gone2.sh -p $PARAMS -s $POPPARAMS -r $ARRAY_NAME