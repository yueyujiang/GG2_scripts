# $1 tree
# $2 seq
# $3 outfile 

temp_dir=$(mktemp -d)

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export SCRIPTS_DIR=$PROJ_DIR/

echo "split the sequences ..."
grep ">" $2 | sed "s/>//g" | sed "s/_[^ \t]*//g" | sort | uniq > ${temp_dir}/seq.label
python ${SCRIPTS_DIR}/random_choice.py --infile ${temp_dir}/seq.label --outfile ${temp_dir}/seq.label.random --ratio 0.5

python ${SCRIPTS_DIR}/../scripts/grep_seq.py --infile $2 --outfile ${temp_dir}/seq1.fa --seqnames ${temp_dir}/seq.label.random --replicate 
python ${SCRIPTS_DIR}/../scripts/grep_seq.py --infile $2 --outfile ${temp_dir}/seq2.fa --seqnames ${temp_dir}/seq.label.random --replicate --inverse

echo "start evaluating ..."
bash ${SCRIPTS_DIR}/select_copy_by_leave_out2.sh $1 ${temp_dir}/seq1.fa ${temp_dir}/seq2.fa > ${temp_dir}/error1.txt
bash ${SCRIPTS_DIR}/select_copy_by_leave_out2.sh $1 ${temp_dir}/seq2.fa ${temp_dir}/seq1.fa > ${temp_dir}/error2.txt

tail -n +2 ${temp_dir}/error2.txt > ${temp_dir}/error2.txt.rm3

cat ${temp_dir}/error1.txt ${temp_dir}/error2.txt.rm3 > $3

echo "finished!"
rm -rf ${temp_dir}/
