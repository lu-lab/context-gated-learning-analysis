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
	
## 4) Instructions for use

## Expected run times 
Expected run time are with 2.3 GHz, 8 core Intel i9 CPU and MATLAB parallel computing toolbox

Data pre-processing, combines data from individual excel and csv files
- A - C: seconds
- D: 1 - 2 min
- E: 5 - 10 min
- F: 10 - 15 min
- G: ~1 min
- H: ~1 min

Data analysis
- Ja: 3 - 5 min for 30 bootstraps, 5 - 6 hours for 2k bootstraps
- Jb: seconds
- Jc: seconds
- Ka: ~1 - 2 hrs for 10 bootstraps, 2 - 3 days for 1k bootstraps
- Kb: 1 - 5 min per .mat file plotted
