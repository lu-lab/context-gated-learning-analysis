## 1) System Requirements
See main repository readme

## 2) Installation guide
See main repository readme

## 3) Demo instructions
*Disclaimer, data provided for demonstration purposes only to show functionality and assist with installation and debugging. The demo data is not a representative sample of the overall dataset associated with the manuscript.

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
