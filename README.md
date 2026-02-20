## 1) System Requirements
Required Software:
- MATLAB (version 2021b)
- Parallel Computing Toolbox
- Statistics and Machine Learning Toolbox
- GenLouvain Toolbox (https://github.com/GenLouvain/GenLouvain), included in helpers folder
	
Operating Systems Tested: 
- MacOS 15 Sequoia, MacOS 26 Tahoe (Intel processor, not ARM)

Notes on system requirements
- For running on different processor architectures/OS may need to recompile the GenLouvain toolbox
- Other versions of MATLAB may work, but if you encounter any issues I recommend running on version 2021b
- On MacOS26 Tahoe, execution of GenLouvain toolbox may be blocked by system security on first run	

## 2) Installation guide
- Download and install MATLAB 2021b
- Download and unzip provided code and data files
- Typical install time determined by time needed to install MATLAB, not setup of provided files/scripts

## 3) Demo instructions
Run the scripts in the following order (first letter indicates order to run)
- A_get_folders_w_csv_xlsx.m
- B_check_csv_xlsx_redundancy.m
- C_get_metadata.m
- D_check_csvs.m
- E_check_xlsx.m
- F_extract_data.m
- G_check_data.m
- H_calculate_dRRo.m
- Ja_bootstrap_kernels.m
- Jb_plot_bootstrapped_kernels.m
- Jc_plot_kernel_AUC_heatmaps.m
- Ka_multislice_modularity_learning_bootstrap.m
- Kb_visualize_modularity_results.m

Notes
- When running Ja, reduce number of bootstraps (line 61) to reduce run time for quick demo (10 - 30 suggested)
- When running Ka, reduce number of bootstraps (line 71) to reduce run time for quick demo (10 - 100 suggested)

Expected outputs
- A to H: .csv and .mat file containing combined data
- Ja: .mat file containing bootstrapped kernels
- Jb, Jc: .pdf figures used to prepare main text and extended data figures
- Ka: .mat files containing bootstrapped module assignment results
- Kb: .pdf figures used to prepare main text, extended data, and online supplementary data figures

## Expected run times 
Estimates are based on runtimes with 2.3 GHz, 8 core Intel i9 CPU and MATLAB parallel computing toolbox

Data pre-processing, combines data from individual excel and csv files
- A - C: seconds
- D: seconds (no csvs in demo data)
- E: 3 min 
- F: 3 min
- G: ~1 min
- H: ~1 min

Data analysis
- Ja: 3 - 5 min for 30 bootstraps, 5 - 6 hours for 2k bootstraps
- Jb: seconds
- Jc: seconds
- Ka: ~5 - 10 min for 10 bootstraps, 1 - 2 hrs for 100 bootstraps
- Kb: 1 - 5 min per .mat file plotted
