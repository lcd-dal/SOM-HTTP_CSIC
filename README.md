# Description
Matlab SOM code for Normal and Malicious web request classification 
on HTTP dataset CSIC 2010 (http://www.isi.csic.es/dataset/)

===========================
- Requirements: 
	SOMToolbox 2.1 (https://github.com/ilarinieminen/SOM-Toolbox)
	(Warning: the warning about NARGCHK commands used in the toolbox should be fixed to
	reduce the runtime).
	
	All the code and data folders need to be be added to Matlab path.

- Data format: The program accepts numerical data, where each row is an instance
	and the last feature is the label. For legacy reason, class "2" denotes Normal
	data, class "n" where n > 2 represents malicious data. Processed versions
	of HTTP CSIC 2010 dataset can be found in data folder.
	
	With some small modification in running script, the program can be used on
	other data.

- Run the program: See "run_http.m" for an example script. Note that the rpath 
	should be set to the output folder, where all the results will be stored.

- Output: In the output folder, for each running mode, there will be a .mat file
	containing all the results of that mode. The main variables to look for are
	dr, which summarizes the detection rates, and cmt, which details the confusion matrix.

============================

# CITATION
To cite the work, please cite the paper: 
D. C. Le, A. N. Zincir-Heywood and M. I. Heywood, "Data analytics on network traffic flows for botnet behaviour detection," 
2016 IEEE Symposium Series on Computational Intelligence (SSCI), Athens, 2016, pp. 1-7. doi: 10.1109/SSCI.2016.7850078

For more information, please contact "duc dot le at dal dot ca"
