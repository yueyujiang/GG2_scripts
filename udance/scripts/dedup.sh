#!/usr/bin/env bash
# $1 backbone_tree
# $2 seqs
# $3 out_dir

export SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

temp_dir=$(mktemp -d)
if [ ! -d "${3}" ]; then
	mkdir -p ${3}
fi
if [ ! -d "${3}/seqs" ]; then
	mkdir ${3}/seqs
fi
nw_labels -I ${1} > ${temp_dir}/backbone_id.txt
grep ">" ${2} | sed "s/>//g"  > ${temp_dir}/all_id.txt
python $SCRIPTS_DIR/order_id.py --backbone ${temp_dir}/backbone_id.txt --all ${temp_dir}/all_id.txt --out-dir ${temp_dir}
{ seqkit grep -f ${temp_dir}/backbone_id.txt ${2} -w 0 ; seqkit grep -f ${temp_dir}/query_id.txt ${2} -w 0; } >> ${temp_dir}/reorder.fa 2>> ${3}/error.log
sed "2~2 s/[N,n]/-/g" ${temp_dir}/reorder.fa | seqkit rmdup -s -o ${3}/seqs/seqs.fa -i -w 0 -D ${3}/rm_map.txt 2>> ${3}/error.log
seqkit grep -f ${temp_dir}/backbone_id.txt ${3}/seqs/seqs.fa -w 0 --quiet -o ${3}/backbone.fa 2>> ${3}/error.log
seqkit grep -f ${temp_dir}/query_id.txt ${3}/seqs/seqs.fa -w 0 --quiet -o ${3}/query.fa	2>> ${3}/error.log
grep ">" ${3}/backbone.fa | sed "s/>//g" > ${temp_dir}/backbone_id_dedup.txt
nw_labels -I ${1} > ${temp_dir}/backbone_tree_id.txt.tmp
grep -Fxvf  ${temp_dir}/backbone_id_dedup.txt ${temp_dir}/backbone_tree_id.txt.tmp > ${temp_dir}/backbone_id_dup.txt
#mapfile -t < ${temp_dir}/backbone_id_dedup.txt
#echo dup `wc -l ${temp_dir}/backbone_id_dup.txt`
n1=`cat ${temp_dir}/backbone_id_dup.txt | grep -c '^'`
#echo $n1
if [ "$n1" -eq 0 ]; then
	cp ${1} ${3}/backbone.tree
else
	mapfile -t < ${temp_dir}/backbone_id_dup.txt
##nw_prune -v ${1} "${MAPFILE[@]}" > ${temp_dir}/backbone_poly.tree
##python $SCRIPTS_DIR/resolve_polytomies.py ${temp_dir}/backbone_poly.tree >  ${3}/backbone.tree
#nw_prune -v ${1} "${MAPFILE[@]}" > ${3}/backbone.tree
	nw_prune ${1} "${MAPFILE[@]}" > ${3}/backbone.tree
fi
sed -i "s/'//g" ${3}/backbone.tree
echo ${temp_dir}
#rm -R ${temp_dir}
