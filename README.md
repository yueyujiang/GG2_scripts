# GG2_scripts

## Select a single copy
To speed up the process, split the sequence file into two files in realtively same size and each ideally contain the same number of genomes.          
1. run           
`bash select_copy/select_copy_by_leave_out2.sh tree_file seq_file1 seq_fil2 > error1.txt` and         
`bash ~/tool/select_copy_by_leave_out2.sh tree_file seq_file2 seq_fil1 > error2.txt`,            
this will give us error1.txt and error2.txt that containing the placement error for all the sequences. Then select the copies with lowest errors among multiple copies. 

## uDance
Run     
`bash udance/run.sh -b backbone_seq_file -s sequence_file -l 10000000 -o outdir -t cores -c 15000`

## DEPP
### Installation
conda env create -f depp_env.yml

### Prepare
1. Trim and backbone tree and remove sequences in the backbone sequences so that backbone tree and backbone sequences have the same set of species.
2. Make the aligned backbone sequence file to be in four types (full-length, V4, V4 100bp and V4 150bp) by trimming the sequences. Following is the position we used in the previous run for trimming the squences. Those positions are found by aligning the fragments of 16S to the aligned full-length 16S. It would be good to double check that.

* V4 100
start: 572
End: 672

* V4 150
Start: 572
End: 722

* V4 
Start: 572
End: 822

### Training
For each of the backbone sequence type, train a model using the command:    
`train_cluster_depp.sh -t backbone_tree -s backbone_seq -g gpu_id -o outdir`

### Placement
Do the placement using the following command:    
`depp-place-rRNA.sh -q query_seq -a accessory_file -o ourdir -x cores`.  

## Others
### APPLES (placement)
#### Installation
`pip install apples`

#### Run
`run_apples.py -s backbone_seq_file -q query_seq_file -t backbone_tree -o outfile`

### Treecluster (cluster a tree)
#### Installation
`pip install treecluster`

#### Run
TreeCluster.py -h

### UPP (alignment)
#### Installation
[Follow this readme](https://github.com/smirarab/sepp/blob/master/README.UPP.md)

#### Run (command I use)
`run_upp.py -s seq_to_be_aligned -a backbone_seq -t backbone_tree -A 200 -d otudir -x 36 -p tmp_dir`        
Note: backbone_tree can be obtained using FastTree: `FastTree -nt backbone_seq > backbone_tree`

