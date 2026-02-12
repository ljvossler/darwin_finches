#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=gone_input_generation
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --ntasks-per-node=1
#SBATCH --output %x_%a.out
#SBATCH --array=1-6


PARAMS=params_base.sh

ARRAY_NAME=input_run1 # Be sure to rename this parameter if you wish to keep mulitple inputs. Otherwise, all files in an existing array folder will be overwritten.

POPPARAMS="$( sed "${SLURM_ARRAY_TASK_ID}q;d" GONEINPUTPOPS )"


source input_generation.sh -p $PARAMS -s $POPPARAMS -r $ARRAY_NAME