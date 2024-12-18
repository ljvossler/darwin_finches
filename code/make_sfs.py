'''
Author: <Logan Vossler>

==========================================================
Make 2-Dimensional Site Frequency Spectra
==========================================================

Description:
This module is used to make and export 2-Dimensional Allele Frequency Spectrum files
and plots from VCF files. This module requires dadi.
It will also save bootstrap data for later use in DADI uncertainty analysis.
'''


# Required Modules
#==========================================================
import dadi, random
import matplotlib.pyplot as plt


# Function Definitions
#==========================================================
def bootstrap(dd, pop_ids, num_chrom, folder_name):
    '''
    This function creates bootstrapped datasets from our SNP data dictionary.
    Parameters:
        dd: A data dictionary
        pop_ids: A 2 element list containing strings of species names for which we are generating bootstrapped datasets
        num_chrom: A 2 element list containing integers representing the number of chromosomes for each species we are bootstrapping
        folder_name: A string representing the folder name within the bootstraps directory to save the bootstraps to.
    Returns:
        None
    '''
    # State number of bootstrapped datasets desired and genome chunks
    Nboot, chunk_size = 100, 1e7
    # Break data dictionary into chunks (list of dictionary genome chunks)
    chunks = dadi.Misc.fragment_data_dict(dd, chunk_size)
    # Set any random seed so that the same random genome chunks are
    # selected for non/synonymous mutations
    random.seed(1762)
    # Get a list containing sfs from bootstrapped genomes for each pop combo
    boots = dadi.Misc.bootstraps_from_dd_chunks(chunks, Nboot, pop_ids=pop_ids, polarized=False, projections=num_chrom)
    for i in range(len(boots)):
        boots[i].to_file('post/bootstraps/' + folder_name + '/'  + '_'.join(pop_ids) + 'boots{0}.fs'.format(str(i)))

def plot_sfs(sfs, pop_ids):
    '''
    This function takes an sfs file and constructs a plot of the 2D SFS between the populations contained in the file.
    Note that the sfs file must contain a header in the form:
	"(2x Number of samples in Pop0) (2x Number of samples in Pop1) (State whether the data is folded or unfolded)"
	Pop0 will plot on the yaxis and Pop1 will plot on the xaxis.
    It will also save this plot as a png to your current working directory.
    Parameters:
        sfs: An sfs file. (MUST contain ONLY 2 populations)
	    pop_ids: A 2 element list containing strings for species being plotted. yaxis is the first list element. xaxis is the second.
    Returns:
        None
    '''
    plot_spectrum = dadi.Plotting.plot_single_2d_sfs(sfs, vmin=1, pop_ids=pop_ids)
    plt.savefig('post/spectra/' + '_'.join(pop_ids) + '_2d_spectrum.png')
    plt.clf()


def main():
    '''
    1) Make Data Dictionary
    2) Make SFS and save to files
    3) Make SFS plots
    4) Make bootstrapped datasets
    '''
    # Make Data dictionary from VCF file
    dd = dadi.Misc.make_data_dict_vcf('all_post.vcf', 'pops.txt')

    # Make Spectrum objects from Data Dictionary for each species combo
    cra_for_fs = dadi.Spectrum.from_data_dict(dd, ['CRA', 'FOR'], polarized=False, projections=[18,16])
    cra_par_fs = dadi.Spectrum.from_data_dict(dd, ['CRA', 'PAR'], polarized=False, projections=[18,14])
    for_par_fs = dadi.Spectrum.from_data_dict(dd, ['FOR', 'PAR'], polarized=False, projections=[16,14])

    # Save SFS for each species combo to files
    cra_for_fs.to_file('post/spectra/cra_for_fs')
    cra_par_fs.to_file('post/spectra/cra_par_fs')
    for_par_fs.to_file('post/spectra/for_par_fs')

    # Plot the SFS
    plot_sfs(cra_for_fs, ['CRA','FOR'])
    plot_sfs(cra_par_fs, ['CRA','PAR'])
    plot_sfs(for_par_fs, ['FOR','PAR'])

    # Make Bootstraps
    bootstrap(dd, ['CRA', 'FOR'], [18,16], 'CRA_FOR')
    bootstrap(dd, ['CRA', 'PAR'], [18,14], 'CRA_PAR')
    bootstrap(dd, ['FOR', 'PAR'], [16,14], 'FOR_PAR')




if __name__ == '__main__':
    main()
