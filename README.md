# PARSEC_ABC-FAR

Codes for "Rationalised experiment design for parameter estimation with sensitivity clustering".

Problem statement (copied from the article): "We explore the dynamics of a three-gene repressilator system, a synthetic genetic circuit characterized by the sequential repression of gene expression in a cyclic manner (Elowitz, M.B. and Leibler, S., Nature, 403(6767), 2000). Using an ordinary differential equation (ODE) model detailed in Supplementary SI S3, we monitor the protein levels produced by these genes. We analyze a set of six simultaneous measurements of protein B and C levels over 72 hours to obtain an accurate estimate of the parameters using PARSEC. Briefly, PARSEC calculates the parameter sensitivity indices (PSI) at a specific set of time points for proteins B and C. We combine the indices for proteins B and C to create a PARSEC-PSI vector for the candidate measurements. We then use k-means clustering to group the measurements into six clusters, with one representative candidate randomly chosen from each cluster as part of the final design."

We compare the designs using ABC-FAR to identify the most informative ones.
Labels for the designs: SSD, SRD and W1SD denote the PARSEC, random and anti-PARSEC designs respectively.

run_this.m is the file to run for the complete analysis.

ground_truth_GRN.mat has details of the parameter values guess and initial conditions used to predict designs.

The folder 'TSA/' has codes for parameter sensitivity analysis.

The folder 'PARSEC/' has codes for predicting PARSEC designs by performing clustering on the parameter sensitivity profiles..

The folder 'expt_analysis\' has codes for avaluating the designs for informativeness about the parameter values. The codes here use the codes in '../functions_ABC_FAR', so please keep the folder in the path.
