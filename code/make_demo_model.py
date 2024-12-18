'''
Author: <Logan Vossler>

==========================================================
Make 2-Dimensional Demography Model
==========================================================

Description:
This module makes a 2D demography model from a site frequency spectra. This module requires dadi.
It will save the optimized parameters and a comparison plot (between data and model) to the CWD.
It will also perform uncertainty analysis and save confidence intervals for a model to files.

Before running, replace the filename and object arguments in main based on your needs
If testing your workflow, then it is recommended to run only 20 optimizations to your model.
When running on an HPC, run a minimum of 100 model optimizations.

*************** This script can run any out-of-the-box model offered in DADI, provided that you specify the model and ***************
                have the correct amount of starting parameters in make_demo_model() Refer to the DADI 
                documentation for understanding how to run some models and the required parameter list lengths.
'''


# Required Modules
#==========================================================
import dadi, nlopt, glob
import matplotlib.pyplot as plt


# Function Definitions
#==========================================================
def iso_inbreeding(params, ns, pts):
    '''
    This function can be used to simulate the diverge of two diploid populations and 
    the presence of inbreeding within them. The function is outlined in DADI documentation
    but is not included in the out-of-the-box models, so we must explicity define it here.
    Parameters:
        params: A 5 element list of arbitrary parameters including (in order):
            T: Time of split
            nu1 & nu 2: Respective sizes of both populations
            F1 & F2: Respective inbreeding coefficients for both populations
        ns: Sample sizes
        pts: Number of grid points for the model when plotted
    Returns:
        fs: A frequency spectrum object
    '''
    T, nu1, nu2, F1, F2 = params
    xx = dadi.Numerics.default_grid(pts)
    phi = dadi.PhiManip.phi_1D(xx)
    phi = dadi.PhiManip.phi_1D_to_2D(xx, phi)
    phi = dadi.Integration.two_pops(phi, xx, T, nu1, nu2)
    fs = dadi.Spectrum.from_phi_inbreeding(phi, ns, (xx, xx), (F1, F2), (2, 2))
    return fs

def make_2d_demo_model(fs, pop_ids, folder_name):
    '''
    This function makes a 2D demographic model from a 2D site frequency spectra object
    between the populations present in the sfs.
    It will save the model parameters into an output file in the current working directory.
    Finally it will run a Godambe Uncertainty Analysis on the model and save the results to a file in the specified folder.
    ****** YOU MUST EDIT THE AMOUNT OF MODEL STARTING PARAMETERS AND MODEL TYPE TO TEST DIFFERENT MODELS ******
    Parameters:
        fs: A frequency spectra object containing data across 2 populations
        pop_ids: A 2 element list containing strings of species names (used for filename)
        folder_name: string representing the name of folder to put model outputs
    Returns:
        model_fs: SFS based on optimized model parameters
    '''
    # Get Sample Sizes
    n = fs.sample_sizes
    # Get number of grid points for the model
    pts = [max(n)+20, max(n)+30, max(n)+40]
    # Define starting model optimization parameters
    #NOTE: Since our data is FOLDED, we no longer include a misidentification parameter.
    params = [1, 1, 0.01, 0.01]
    # Define upper and lower bounds for model optimization
    # These boundaries help avoid parameters that are likely incorrect and reduce runtime
    l_bounds = [1e-2, 1e-2, 1e-3, 1e-3]
    u_bounds = [3, 3, 1, 1]

    # State our model
    model = dadi.Demographics2D.split_mig
    # Since we have FOLDED data, we should NOT wrap the model in a function that adds a parameter to estimate misidentification rate
    #model = dadi.Numerics.make_anc_state_misid_func(model)
    # Add another model wrapper that allows for the use of grid points
    model_ex = dadi.Numerics.make_extrap_func(model)

    # Create a file to store the fitted parameters in your current working directory
    try:
        output = open('post/models/' + folder_name  + '/one_chrom/' + '_'.join(pop_ids) +'_fits.txt','a')
    except:
        output = open('post/models/' + folder_name  + '/one_chrom/' + '_'.join(pop_ids) +'_fits.txt','w')
    
    # This is where we run the optimization for our arbitrary model parameters
    # By the end, we will (presumably) get some optimal parameters and the log-liklihood for how optimal they are
    for i in range(100):
        # Slightly alter parameters
        p0 = dadi.Misc.perturb_params(params, fold=1, upper_bound=u_bounds,lower_bound=l_bounds)
        popt, ll_model = dadi.Inference.opt(p0, fs, model_ex, pts, lower_bound=l_bounds, upper_bound=u_bounds,algorithm=nlopt.LN_BOBYQA,maxeval=400, verbose=0)
        # Calculate the synonymous theta
        # Also finding optimal scaling factor for data
        model_fs = model_ex(popt, n, pts)
        theta0 = dadi.Inference.optimal_sfs_scaling(model_fs, fs)

    # Write results to output file
    res = [ll_model] + list(popt) + [theta0]
    output.write('\t'.join([str(ele) for ele in res])+'\n')
    output.close()
    
    # Perform Godambe Uncertainty Analysis
    boots_fids = glob.glob('post/bootstraps/one_chrom/' + '_'.join(pop_ids) + '/' + '_'.join(pop_ids) + 'boots*.fs')
    boots_syn = [dadi.Spectrum.from_file(fid) for fid in boots_fids]

    # Godambe uncertainties
    # Will contain uncertainties for the estimated demographic parameters and theta.

    # Start a file to contain the confidence intervals
    fi = open('post/models/'+ folder_name  + '/one_chrom/' + '_'.join(pop_ids) +'confidence_intervals.txt','w')
    fi.write('Optimized parameters: {0}\n\n'.format(popt))

    # Get optimzed parameters * 100 (possibly can solve low parameter values leading to floating point arithmetic errors)
    popt_100 = [param * 100 for param in popt]

    # we want to try a few different step sizes (eps) to see if uncertainties very wildly with changes to step size.
    for eps in [0.1, 0.01, 0.001, 0.0001, 0.00001]:
        # Do normal uncertainty analysis
        uncerts_adj = dadi.Godambe.GIM_uncert(func_ex=model_ex, grid_pts=pts, all_boot=boots_syn, p0=popt, data=fs, eps=eps)
        fi.write('================Default Uncertainty Analysis================')
        fi.write('Estimated 95% uncerts (with step size '+str(eps)+'): {0}\n'.format(1.96*uncerts_adj[:-1]))
        fi.write('Lower bounds of 95% confidence interval : {0}\n'.format(popt-1.96*uncerts_adj[:-1]))
        fi.write('Upper bounds of 95% confidence interval : {0}\n\n'.format(popt+1.96*uncerts_adj[:-1]))

        # Do Logarithmic Uncertainty Analysis
        #uncerts_adj = dadi.Godambe.GIM_uncert(func_ex=model_ex, grid_pts=pts, all_boot=boots_syn, p0=popt, data=fs, eps=eps, log=True)
        #fi.write('================Logarithimc Uncertainty Analysis================')
        #fi.write('Estimated 95% uncerts (with step size '+str(eps)+'): {0}\n'.format(1.96*uncerts_adj[:-1]))
        #fi.write('Lower bounds of 95% confidence interval : {0}\n'.format(popt-1.96*uncerts_adj[:-1]))
        #fi.write('Upper bounds of 95% confidence interval : {0}\n\n'.format(popt+1.96*uncerts_adj[:-1]))

        # Do POPTx100 Uncertainty Analysis
        #uncerts_adj_100 = dadi.Godambe.GIM_uncert(func_ex=model_ex, grid_pts=pts, all_boot=boots_syn, p0=popt_100, data=fs, eps=eps)
        #uncerts_adj = [param / 100 for param in uncerts_adj_100]
        #fi.write('================Popt * 100 Uncertainty Analysis================')
        #fi.write('Estimated 95% uncerts (with step size '+str(eps)+'): {0}\n'.format(1.96*uncerts_adj[:-1]))
        #fi.write('Lower bounds of 95% confidence interval : {0}\n'.format(popt-1.96*uncerts_adj[:-1]))
        #fi.write('Upper bounds of 95% confidence interval : {0}\n\n'.format(popt+1.96*uncerts_adj[:-1]))

        # Do POPTx100 and Logarithmic Uncertainty Analysis
        #uncerts_adj = dadi.Godambe.GIM_uncert(func_ex=model_ex, grid_pts=pts, all_boot=boots_syn, p0=popt_100, data=fs, eps=eps, log=True)
        #uncerts_adj = [param / 100 for param in uncerts_adj_100]
        #fi.write('================Popt * 100 with Logarithmic Uncertainty Analysis================')
        #fi.write('Estimated 95% uncerts (with step size '+str(eps)+'): {0}\n'.format(1.96*uncerts_adj[:-1]))
        #fi.write('Lower bounds of 95% confidence interval : {0}\n'.format(popt-1.96*uncerts_adj[:-1]))
        #fi.write('Upper bounds of 95% confidence interval : {0}\n\n'.format(popt+1.96*uncerts_adj[:-1]))
        
    fi.close()

    return model_fs

def compare_sfs_plots(data_fs, model_fs, pop_ids, folder_name):
    '''
    This function plots a comparison spectra between the data and model.
    Will be useful in visually determining model accuracy.
    Parameters:
        data_fs: The actual allele frequency spectra from our samples
        model_fs: The proposed allele frequency spectra from our samples
        pop_ids: A 2 element list containing strings for species being plotted. yaxis is the first list element. xaxis is the second.
        folder_name: string representing the name of folder to put model outputs
    Returns:
        None
    '''
    comp_plot = dadi.Plotting.plot_2d_comp_multinom(model_fs, data_fs, pop_ids=pop_ids)
    plt.savefig('post/models/' + folder_name  +  '/one_chrom/' + '_'.join(pop_ids) + '_comp_plot.png')
    plt.clf()


# Main
#==========================================================
def main():
    '''
    1) Make the spectrum objects for each species comparison
    2) Make spectrum objects from a demography model and save fits to files
    3) Save model SFS to files
    4) Compare data and model sfs plots
    5) Perform uncertainty analysis on all models and save them to files
    '''
    # Read data SFS files and save to variables
    cf_fs = dadi.Spectrum.from_file('post/spectra/one_chrom/cra_for_fs')
    cp_fs = dadi.Spectrum.from_file('post/spectra/one_chrom/cra_par_fs')
    fp_fs = dadi.Spectrum.from_file('post/spectra/one_chrom/for_par_fs')

    # Make model SFS objects for each species comparison
    cf_model_fs = make_2d_demo_model(cf_fs, ['CRA','FOR'], 'split_mig')
    cp_model_fs = make_2d_demo_model(cp_fs, ['CRA','PAR'], 'split_mig')
    fp_model_fs = make_2d_demo_model(fp_fs, ['FOR','PAR'], 'split_mig')

    # Save model SFS to files
    cf_model_fs.to_file('post/models/split_mig/one_chrom/cra_for_model_fs')
    cp_model_fs.to_file('post/models/split_mig/one_chrom/cra_par_model_fs')
    fp_model_fs.to_file('post/models/split_mig/one_chrom/for_par_model_fs')

    # Plot SFS model/data comparison
    compare_sfs_plots(cf_fs, cf_model_fs, ['CRA','FOR'], 'split_mig')
    compare_sfs_plots(cp_fs, cp_model_fs, ['CRA','PAR'], 'split_mig')
    compare_sfs_plots(fp_fs, fp_model_fs, ['FOR','PAR'], 'split_mig')


if __name__ == '__main__':
    main()
