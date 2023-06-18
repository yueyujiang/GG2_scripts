# $1 outdir
# $2 seq
# $3 tree
# $4 query list optional
echo $1

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SCRIPTS_DIR=$PROJ_DIR/

query_names="${4:-None}"
nw_labels -I $3 > ${1}/tree.label
python ${SCRIPTS_DIR}/../scripts/grep_seq.py --infile $2 --outfile $1/seq.fa --seqnames ${1}/tree.label  --replicate 
python ${SCRIPTS_DIR}/train_test_split_seq.py --seq-file $1/seq.fa --out-dir $1 --query-names $query_names --replicate
grep ">" ${1}/seq.fa | sed "s/>//g" | sed "s/_[^ \t]*//g" > .tmp1
nw_prune -vf ${3} .tmp1 > ${1}/tree.nwk
#cp ${3} ${1}/tree.nwk
grep ">" ${1}/backbone.fa | sed "s/>//g" | sed "s/_[^ \t]*//g" > .tmp
nw_prune -vf ${1}/tree.nwk .tmp > ${1}/backbone.nwk
