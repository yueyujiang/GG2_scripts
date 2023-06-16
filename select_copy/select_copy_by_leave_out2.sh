# $1 tree
# $2 backbone sequences
# $3 query sequences
# query and backbone sepereated

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SCRIPTS_DIR=$PROJ_DIR/../scripts

temp_dir=$(mktemp -d)

grep ">" ${3} | sed "s/>//g" | sed "s/_[^ \t]*//g" | sort | uniq > query.label
python ${SCRIPTS_DIR}/grep_seq.py --infile $2 --outfile ${temp_dir}/backbone.fa --seqnames query.label --inverse --replicate

cat ${temp_dir}/backbone.fa <(echo) ${3} > ${temp_dir}/seq.fa
python ${SCRIPTS_DIR}/get_one_seq.py --infile ${temp_dir}/seq.fa --outfile ${temp_dir}/seq.fa
grep ">" ${temp_dir}/seq.fa | sed "s/>//g" > ${temp_dir}/one_seq.label 

nw_prune -vf ${1} ${temp_dir}/one_seq.label > ${temp_dir}/tree.nwk
nw_labels -I ${temp_dir}/tree.nwk > ${temp_dir}/tree.label

grep ">" ${3} | sed "s/>//g" | sed "s/_[^ \t]*//g" | sort | uniq > ${temp_dir}/query.label

python ${SCRIPTS_DIR}/grep_seq.py --infile ${temp_dir}/seq.fa --outfile ${temp_dir}/seq.fa --seqnames ${temp_dir}/tree.label 
python ${SCRIPTS_DIR}/grep_seq.py --infile ${3} --outfile ${temp_dir}/query_orig.fa --seqnames ${temp_dir}/tree.label --replicate
python ${SCRIPTS_DIR}/grep_seq.py --infile ${temp_dir}/seq.fa --outfile ${temp_dir}/seq.fa --seqnames ${temp_dir}/tree.label --replicate
python ${SCRIPTS_DIR}/grep_seq.py --infile ${temp_dir}/seq.fa --outfile ${temp_dir}/backbone_one_seq.fa --seqnames ${temp_dir}/query.label --inverse

#grep ">" ${temp_dir}/seq_orig.fa | sed "s/>//g" > ${temp_dir}/seq.label
grep ">" ${temp_dir}//backbone_one_seq.fa | sed "s/>//g" > ${temp_dir}/backbone.label
nw_prune -vf ${temp_dir}/tree.nwk ${temp_dir}/backbone.label > ${temp_dir}/backbone.nwk
python ${SCRIPTS_DIR}/resolve_polytomies.py --infile ${temp_dir}/backbone.nwk --outfile ${temp_dir}/backbone.nwk
raxml-ng --evaluate --msa ${temp_dir}/backbone_one_seq.fa --tree ${temp_dir}/backbone.nwk --model JC --brlen scaled --threads 1 --prefix ${temp_dir}/run --redo --force > out.log 2> /dev/null
mv ${temp_dir}/run.raxml.bestTree ${temp_dir}/backbone.nwk

run_apples.py -s ${temp_dir}/backbone_one_seq.fa -q ${temp_dir}/query_orig.fa -t ${temp_dir}/backbone.nwk -o ${temp_dir}/placement.jplace -f 0 -b 5 -D > out.log 2> /dev/null
gappa examine graft --jplace-path ${temp_dir}/placement.jplace --out-dir ${temp_dir}/ --allow-file-overwriting > out.log 2> /dev/null

bash ${SCRIPTS_DIR}/evaluate_placement.sh ${temp_dir}/tree.nwk ${temp_dir}/placement.newick ${temp_dir}/query_orig.fa ${temp_dir}/backbone.nwk

rm -rf ${temp_dir}
