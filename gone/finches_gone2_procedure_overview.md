GONE2 PROCEDURE OVERVIEW
=================================

INPUT GENERATION:
All .ped and .map files are generated from the relevant phased and sorted VCF files (located in `/xdisk/mcnew/finches/dannyjackson/finches/datafiles/vcf3/`) using `input_file_generation.sh`.

`input_file_generation.sh` is doing the following:
	1. Generating a new VCF (using vcftools) that contains only entries with no missing data from chromosomes greater than ~20 cM.
	2. Generating .ped and .map files (using plink) from this filtered VCF.
	3. Using some small python scripts to adjust the data formatting (Because they don't always generate the way gone2 wants)
=================================

GONE2 ANALYSIS:
All analyses are done with the following gone2 parameters using the .ped file and are run using 'submit_gone2.sh'

`-g 0` (All inputs are assumed to be unphased diploid individuals. Our original VCF data was phased, but reformatting into .ped/.map removes this info)
`-r 1.1` (We have no site-specific recombination rate data, so we set a constant recombination across the genome)
`-i` (Includes only a subset of individuals in analysis. This number was chosen based on the minimum number of samples we have for a species population. For example: CRA_post has 9 samples, but CRA_pre only has 5. So for both CRA analyses we use only 5 random individuals. The same filtering is applied for PAR and FOR.)
	Number of Individuals used:
		CRA: 5
		FOR: 8
		PAR: 7
=================================

All outputs plotted from POP_GONE2_Ne output file using `plot_gone2.R`