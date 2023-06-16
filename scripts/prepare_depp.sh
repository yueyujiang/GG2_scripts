# $1 backbone_tree
# $2 backbone_seq
# $3 outdir

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SCRIPTS_DIR=$PROJ_DIR/

temp_dir=$(mktemp -d)

mkdir ${3}/full_length ${3}/v4 ${3}/v4_150 ${3}/v4_100

grep ">" $2 | sed "s/>//g" | sed "s/_[^ \t]*//g" | sort | uniq  > ${temp_dir}/seq.label
nw_prune -vf $1 ${temp_dir}/seq.label > ${3}/backbone.nwk
nw_labels ${3}/backbone.nwk > ${temp_dir}/tree.label
python $PROJ_DIR/grep_seq.py --infile $2 --outfile ${3}/full_length/backbone.fa --seqnames ${temp_dir}/tree.label --replicate

python $PROJ_DIR/trim_seq.py --infile ${3}/full_length/backbone.fa --outfile ${3}/v4_100/backbone.fa --start 571 --end 669 
python $PROJ_DIR/trim_seq.py --infile ${3}/full_length/backbone.fa --outfile ${3}/v4_150/backbone.fa --start 571 --end 719
python $PROJ_DIR/trim_seq.py --infile ${3}/full_length/backbone.fa --outfile ${3}/v4/backbone.fa --start 571 --end 819
