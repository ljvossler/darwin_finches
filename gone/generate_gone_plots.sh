#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file>

This uses GONE2 to generate estimates of recent Ne from plink (.ped/.map)files.
I recommend running it as a slurm array to pass individuals to sbatch jobs for maximum efficiency

Required argument:
  -d  Directory containing the input files.
  -p  Population/Species code.
  -t  Plot Title.
  -c  Color for the plot lines.
  -n  Number of replicates to plot.
  -r  Boolean flag to indicate whether to plot replicates."
    exit 1
fi

PLOT_REPLICATES=false
NUM_REPLICATES=10

# Parse command-line arguments
while getopts d:p:t:c:n:r option; do
    case "${option}" in
        d) FILEDIR=${OPTARG};;
        p) POPCODE=${OPTARG};;
        t) TITLE=${OPTARG};;
        c) COLOR=${OPTARG};;
        n) NUM_REPLICATES=${OPTARG};;
        r) PLOT_REPLICATES=true;;
        *) echo "Invalid option: -${OPTARG}" >&2; exit 1;;
    esac
done

if [ "$PLOT_REPLICATES" = true ]; then
    echo "Plotting Replicate GONE outputs for ${POPCODE}..."
    echo "Ensure that all replicate GONE outputs for ${POPCODE} are in the directory: ${FILEDIR}"
    Rscript /xdisk/mcnew/finches/ljvossler/finches/darwin_finches/gone/gone_3_plot_replicates_finches.R -d ${FILEDIR} -p ${POPCODE} -t "${TITLE}" -c ${COLOR} -n ${NUM_REPLICATES}
    else
    echo "Plotting single GONE output for ${POPCODE}..."
fi