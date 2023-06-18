# $1 tree
# $2 seq
# $3 outdir

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SCRIPTS_DIR=$PROJ_DIR/

nw_labels -I $1 > $3/tree.label
python ${SCRIPTS_DIR}/random_choice.py --infile $3/tree.label --outfile $3/query1.label --ratio 0.5
comm -23 <(sort $3/tree.label) <(sort $3/query1.label) > $3/query2.label

for i in {1,2};
do
	bash ${SCRIPTS_DIR}/train_test_split.sh $3 $2 $1 $3/query${i}.label
	python ${SCRIPTS_DIR}/add_prefix.py --infile $3/query.fa --outfile $3/query.fa.prefix --prefix query

	python ${SCRIPTS_DIR}/get_one_seq.py --infile $3/backbone.fa --outfile $3/backbone_one_seq.fa
	python ${SCRIPTS_DIR}/get_one_seq.py --infile $3/seq.fa --outfile $3/seq_one_seq.fa
	raxml-ng --evaluate --msa $3/backbone_one_seq.fa --tree $3/backbone.nwk --model JC --brlen scaled --threads 1 --prefix $3/run --redo --force
	python ${SCRIPTS_DIR}/resolve_polytomies.py --infile $3/run.raxml.bestTree --outfile $3/run.raxml.bestTree.tmp

	run_apples.py -s $3/backbone_one_seq.fa -q $3/query.fa.prefix -t $3/run.raxml.bestTree.tmp -o $3/placement.jplace -f 0 -b 5 -D
	gappa examine graft --jplace-path $3/placement.jplace --out-dir $3/ --allow-file-overwriting

	python ${SCRIPTS_DIR}/transfer_new_species.py --extended-tree  $3/placement.newick --smaller-tree $3/tree.nwk --new-species $3/query.label  --outfile $3/extended.nwk

	python ${SCRIPTS_DIR}/placement_error_dist2.py --infile $3/extended.nwk --outfile $3/error${i}.txt --jplace $3/placement.jplace
done
