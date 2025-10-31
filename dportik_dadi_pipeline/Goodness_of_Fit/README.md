# Performing Simulations and Goodness of Fit Tests Using dadi

---------------------------------

Perform goodness of fit tests for demographic models. This workflow is a component of the `dadi_pipeline` package.


## General Overview:

This is meant to be a general use script to run `dadi` to perform simulations and goodness of fit tests for any model on an afs/jsfs with one to three populations. To use this workflow, you'll need a SNPs input text file to create an allele frequency or joint site frequency spectrum object. Alternatively, you can import a frequency spectrum of your own creation, editing the script appropriately (see dadi manual). The user will have to edit information about their allele frequency spectrum, and a #************** marks lines in the `Simulate_and_Optimize.py` that will have to be edited. 
The frequency spectrum object can be unfolded or folded, which requires minimal script changes (see Caveats section).

The user provides a model and the previously optimized parameters for their empirical 
data. The model is fit using these parameters, and the resulting model SFS is used to
generate a user-selected number of Poisson-sampled SFS (ie simulated data). If the SNPs
are unlinked, these simulations represent parametric bootstraps. For each of 
the simulated SFS, the optimization routine is performed and the best scoring replicate
is saved. The important results for such replicates include the log-likelihood and 
Pearson's chi-squared test statistic, which are used to generate a distribution of the
simulated data values to compare the empirical values to. In addition, theta, the sum of 
the SFS, and the optimized parameters are also saved.

For a general discussion on this workflow, please see the thread [here](https://groups.google.com/forum/#!topic/dadi-user/cjBOopEhIlQ).

**UPDATE (8/15/21):** The code has been fixed to account for sampling from JSFS where 
down-projections are used. You must now provide the original projection sizes used when 
you optimized the model on your data, as well as the maximum projection sizes of your dataset. The down-projected SFS is used to obtain theta, the model fit is repeated using the "full" JSFS, and it is scaled by the original theta. During the simulations, the simulated JSFS are then down-projected to match the correct numbers used. This prevents odd behavior, such as when the empirical data fit better than the simulated data. See discussion [here](https://groups.google.com/g/dadi-user/c/kSszi_bTB0g/m/M4mZCtOSAAAJ).

The `Simulate_and_Optimize.py` script and `Optimize_Functions_GOF.py` script must be in the same working directory to run properly.

## Importing the Site Frequency Spectrum:
In the new version you will create two JSFS, one with the desired down-projection sizes and one with the maximum projection sizes. Both are needed to correctly perform the simulations. You'll need to edit the projection sections appropriately:
```
#**************
#projection sizes, in ALLELES not individuals.
#These values should match those you used for the
#original model-fitting optimizations.
proj = [16,32]

#Convert this dictionary into folded AFS object based on
#down-projection sizes
#[polarized = False] creates folded spectrum object
fs = dadi.Spectrum.from_data_dict(dd, pop_ids=pop_ids, projections = proj, polarized = False)


#**************
#MAXIMUM projection sizes, in ALLELES not individuals.
#This should represent the maximum alleles per population,
#in other words the sizes for the "full" frequency spectrum.
#This is used to generate the simulations, and then those
#simulations are in turn down-projected to the projection
#sizes listed above (which you have used for your actual model-fitting).
#If your max and preferred projection sizes are the same,
#that is fine too.
max_proj = [22,46]

#Convert this dictionary into folded AFS object based on
#MAXIMUM projection sizes
#[polarized = False] creates folded spectrum object
max_fs = dadi.Spectrum.from_data_dict(dd, pop_ids=pop_ids, projections = max_proj, polarized = False)
```

## Empirical Data Optimization:

Within the `Simulate_and_Optimize.py` script, let's assume you've supplied the correct information about your SNPs input file, population IDs, projection sizes, and are using the model in the script (sym_mig).

The model will first be fit to the empirical data using the following function:

`Get_Empirical(fs, max_fs, pts, outfile, model_name, func, in_params, proj, fs_folded)`
 
***Mandatory Arguments:***

+ **fs**:  spectrum object created with original down-projections
+ **max_fs**:  spectrum object created with MAXIMUM projections
+ **pts**: grid size for extrapolation, list of three values
+ **outfile**:  prefix for output naming
+ **model_name**: a label help name the output files; ex. "sym_mig"
+ **func**: access the model function from within 'Simulate_and_Optimize.py' or from a separate model script
+ **in_params**: the previously optimized parameter values to use
+ **proj**: the original down-projection sizes
+ **fs_folded**: A Boolean value indicating whether the empirical fs is folded (True) or not (False)

***Example Usage:***

In the script you will need to define the extrapolation grid size and the parameter values. The 
number of parameter values must match the number in the model. 

```
#Make sure to define your extrapolation grid size.
pts = [50,60,70]
    
#Provide best optimized parameter set for empirical data.
#These will come from previous analyses you have already completed
emp_params = [0.1487,0.1352,0.2477,0.1877]
    
#Indicate whether your frequency spectrum object is folded (True) or unfolded (False)
fs_folded = True

#Fit the model using these parameters and return the folded or unfolded model SFS (scaled by theta).
#This will account for potential differences between the max-projection sizes and the projections
#used for your actual model fitting, to allow correct simulations of the sfs.
#Here, you will want to change the "sym_mig" and sym_mig arguments to match your model, but
#everything else can stay as it is. See above for argument explanations.
#The log-likelihood returned from this should match what you found with your empirical optimizations.
fs_for_sims = Optimize_Functions_GOF.Get_Empirical(fs, max_fs, pts, "Empirical", "sym_mig", sym_mig, emp_params, proj, fs_folded=fs_folded)
```
	
## Performing Simulations and Model Optimizations:

After the model is fit to the empirical data, the model SFS can be used to generate a user-selected number of Poisson-sampled SFS,
in other words, the simulated data. Note that the model SFS is based on the "full" JSFS which is scaled by theta obtained from the down-projected JSFS model-fit. Each simulation is created from this "full" JSFS model fit, but then the simulated JSFS is down-projected to the correct value. For each simulation, an optimization routine is performed that is similar in structure
to that described in the original model-fitting script [here](https://github.com/dportik/dadi_pipeline). The routine contains a 
user-defined number of rounds, each with a user-defined or default number of replicates. The starting parameters are initially random, 
but after each round is complete the parameters of the best scoring replicate from that round are used to generate perturbed starting 
parameters for the replicates of the subsequent round. The arguments controlling steps of the optimization algorithm (maxiter) and 
perturbation of starting parameters (fold) can be supplied by the user for more control across rounds. 

The simulations and optimizations are performed with the following function:

`Perform_Sims(sim_number, model_fs, pts, model_name, func, rounds, param_number, fs_folded, reps=None, maxiters=None, folds=None, in_params=None, in_upper=None, in_lower=None, param_labels=None, optimizer="log_fmin")`
 
***Mandatory Arguments:***

+ **sim_number**: the number of simulations to perform
+ **fs_for_sims**: the scaled model spectrum object name (from the "full" JSFS, scaled by correct theta)
+ **pts**: grid size for extrapolation, list of three values
+ **model_name**: a name to help label on the output files; ex. "sym_mig"
+ **func**: access the model function from within this script
+ **rounds**: number of optimization rounds to perform
+ **param_number**: number of parameters in the model to fit
+ **proj**: the original down-projection sizes
+ **fs_folded**: A Boolean value indicating whether the empirical fs is folded (True) or not (False)

***Optional Arguments:***

+ **reps**: a list of integers controlling the number of replicates in each of the optimization rounds
+ **maxiters**: a list of integers controlling the maxiter argument in each of the optimization rounds
+ **folds**: a list of integers controlling the fold argument when perturbing input parameter values
+ **in_params**: a list of parameter values (allows starting parameters to be specified, useful when setting upper and lower bounds for specific models)
+ **in_upper**: a list of upper bound values (will constrain the upper bounds in simulations)
+ **in_lower**: a list of lower bound values (will constrain the lower bounds in simulations)
+ **param_labels**: list of labels for parameters that will be written to the output file to keep track of their order
+ **optimizer**: a string, to select the optimizer. Choices include: "log" (BFGS method), "log_lbfgsb" (L-BFGS-B method), "log_fmin" (Nelder-Mead method), and "log_powell" (Powell's method).


***Example Usage:***

The important arguments will need to be defined in the script. Below shows how to perform
100 simulations and define an optimization routine. 

```
#Set the number of simulations to perform here. This should be ~100 or more.
sims = 100
    
#Enter the number of parameters found in the model to test.
p_num = 4
    
#Set the number of rounds here.
rounds = 3
    
#I strongly recommend defining the lists for optional arguments to control the settings 
#of the optimization routine for all the simulated data.
reps = [20,30,50]
maxiters = [5,10,20]
folds = [3,2,1]
    
#Execute the optimization routine for each of the simulated SFS.
#Here, you will want to change the "sym_mig" and sym_mig arguments to match your model 
#function name, but everything else can stay as it is.
Optimize_Functions_GOF.Perform_Sims(sims, fs_for_sims, pts, "sym_mig", sym_mig, rounds, pnum, proj, fs_folded=fs_folded, reps=reps, maxiters=maxiters, folds=folds, param_labels=p_labels)
```

The optimization routine set here will have the following settings:

| Argument | Round 1 | Round 2  | Round 3|
| ------ |------:| -----:| -----:|
| reps    | 20 | 30 | 50 |
| maxiter | 5 |  10  | 20 |
| fold |  3 |  2   | 1 |

If only the number of rounds is provided, but no additional optional arguments, the optimization
routine will use the default values for each round described [here](https://github.com/dportik/dadi_pipeline).

Because it may take some time to optimize each simulated SFS, the elapsed time is provided along
the way which can help provide an estimate of the total time necessary. You may choose to adjust
the optimization routine accordingly, or change the number of simulations. In general, it is much easier to fit models to the simulated data, so I have created default settings for the optimization routine that are less stringent than the 2D or 3D pipelines.

## Analysis Outputs:

The `Optimize_Empirical` function will produce an output file for the empirical fit, which will be in tab-delimited format:

     Model	Replicate	log-likelihood	theta	sfs_sum	chi-squared
     sym_mig	1	-591.21	619.83	1552.44	758.21

This is based on the parameter values supplied, as no optimization routine is performed. 

The `Perform_Sims` function will produce many output files.
For each simulation performed, a log file and optimization summary output file will be produced 
with a prefix matching the simulation number. The optimization summary output file will be in tab-delimited format:

     Model	Replicate	log-likelihood	AIC	chi-squared	theta	optimized_params( )
     sym_mig	Round_1_Replicate_1	-476.15	960.3	571.75	429.99	0.33,0.2753,0.2759,0.8528
     sym_mig	Round_1_Replicate_2	-7182.39	14372.78	40146874463.2	52.58	2.72,7.1758,4.8034,4.7965
     sym_mig	Round_1_Replicate_3	-2221.59	4451.18	58293.74	109.05	4.5185,0.6713,0.4644,3.7992
     sym_mig	Round_2_Replicate_1	-570.25	1148.5	893.16	401.4	0.2539,0.4217,0.0744,0.4792
     sym_mig	Round_2_Replicate_2	-1201.35	2410.7	3134.15	340.21	1.2311,0.1402,0.4655,0.3826
     sym_mig	Round_2_Replicate_3	-621.59	1251.18	1813.97	332.51	0.5275,0.3393,0.0769,1.1639
     sym_mig	Round_3_Replicate_1	-490.62	989.24	680.65	382.17	0.4025,0.3321,0.1819,0.8315
     sym_mig	Round_3_Replicate_2	-509.41	1026.82	705.95	339.42	0.5187,0.3782,0.1482,0.8757
     sym_mig	Round_3_Replicate_3	-467.93	943.86	474.19	513.94	0.2516,0.2106,0.4328,0.8059

After all simulations are complete, the main output file `Simulation_Results_[model name].txt` will be created.
This file contains the best scoring replicate for each simulation, and contains the 
log-likelihood, theta, sum of sfs, Pearson's chi-squared test statistic, and optimized parameter
values. It will also be in tab-delimited format:

     Simulation	Best_Replicate	log-likelihood	theta	sfs_sum	chi-squared	optimized_params
     1	Round_3_Replicate_3	-467.93	513.94	1497.0	474.19	0.2516,0.2106,0.4328,0.8059
     2	Round_3_Replicate_1	-907.83	250.22	1494.0	1757.27	1.6895,0.3219,0.0868,0.7076
     3	Round_3_Replicate_2	-458.62	315.17	1508.0	455.3	0.4111,0.3406,0.2915,3.5104
     4	Round_3_Replicate_3	-488.11	133.42	1568.0	688.36	1.175,1.0293,0.0753,5.6391
     5	Round_3_Replicate_3	-456.46	621.48	1522.0	397.07	0.1981,0.164,0.631,1.8222

## Plotting Goodness of Fit Results:

The R-script `Plot_GOF.R `can be used to quickly visualize the main results. Essentially, the simulations will
be used to create a distribution of values to which the empirical value will be
compared. The script will create a histogram of the simulated data values, and a blue line will
be plotted showing the empirical value. This will be done for the log-likelihood scores and for 
the log-transformed Pearson's chi-squared test statistic. 

The script will need to be edited to indicate the path to the `Simulation_Results_[model name].txt` file and the 
output file for the empirical data. The script will also need to be tailored to create histograms that match the empirical distributions 
for your data set. This can be done by editing the `seq()` function to create an appropriate range of 
bin sizes and overall number of bins for the histograms. The `seq()` function takes three arguments: a 
minimum range value, maximum range value, and increment value. So, `seq(0,20,1)` will created bins ranging 
from zero to twenty by increments of one. You'll need to adjust the range to include the values
from the simulations (and the empirical data, if it falls outside this range!). In general,
if the empirical value falls outside the simulated value distribution in the direction of worse values, the goodness of fit
test is not considered passed. 

## Using Folded vs. Unfolded Spectra:

 To change whether the frequency spectrum is folded vs. unfolded requires two changes in the script. First, change `polarized = False` to `polarized = True` when creating both JSFS spectrum objects. Second, set the following argument to `False`:
 
 ```
 #**************
#Indicate whether your frequency spectrum object is folded (True) or unfolded (False)
fs_folded = True
```
      
It will be clear if either argument has been misspecified because the calculation of certain statistics will cause a crash with the following error:

     ValueError: Cannot operate with a folded Spectrum and an unfolded one.


## Caveats:

 The data are simulated using the `fs.sample()` method in dadi, which is equivalent to a 
 parametric boostrap ONLY if SNPs are unlinked across loci. For ddRADseq data where a 
 single SNP is selected per locus, this is generally true, and this workflow is valid. However, there is also debate about whether we should be using nonparametric bootstraps instead (see the discussion thread [here](https://groups.google.com/forum/#!topic/dadi-user/e7MI1-wU98Q)). To reiterate, this workflow only performs parametric bootstraps, and you will need to decide if this is appropriate for your particular data set.
 

## Example Data Set:

In the folder labeled *Example_Data* you will find a SNPs input file that will run with the `Simulate_and_Optimize.py` script.
You will only need to edit the path to the file in the script, and then the script should run normally. The 
outputs for five simulations (from truncated optimizations) are contained within the *Example_Data* folder, in a separate folder labeled *Example_Outputs*.
Running the `Simulate_and_Optimize.py` script as is will actually produce 100 simulations, rather than five. 
You may choose to test the script using these data to ensure everything is working properly before examining your own empirical data. 


## Citation Information:

The optimization strategy and the scripts associated with `dadi_pipeline` were originally published as part of the following work:

+ *Portik, D.M., Leache, A.D., Rivera, D., Blackburn, D.C., Rodel, M.-O., Barej, M.F., Hirschfeld, M., Burger, M., and M.K. Fujita. 2017. Evaluating mechanisms of diversification in a Guineo-Congolian forest frog using demographic model selection. Molecular Ecology 26: 5245-5263. https://doi.org/10.1111/mec.14266*

If you use the 2D, 3D, or custom demographic modeling pipelines for your work, or modify these scripts for your own purposes, please cite this publication.

The goodness of fit testing scripts were written for the following publication:

+ Barratt, C.D., Bwong, B.A., Jehle, R., Liedtke, H.C., Nagel, P., Onstein, R.E., Portik, D.M., Streicher, J.W., and S.P. Loader. 2018. Vanishing refuge: testing the forest refuge hypothesis in coastal East Africa using genome-wide sequence data for five co-distributed amphibians. ***Molecular Ecology*** 27: 4289-4308. *https://doi.org/10.1111/mec.14862*

If you conduct goodness of fit tests using these scripts, please also cite this publication.

## Contact:

Daniel Portik, PhD

daniel.portik@gmail.com

