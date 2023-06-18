import argparse
from Bio import SeqIO

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--infile', type=str)
parser.add_argument('--outfile', type=str)
args = parser.parse_args()

seq = SeqIO.to_dict(SeqIO.parse(args.infile, "fasta"))
seen = set()
seq_s = ""
for s in seq:
    ss = s.split('_')[0]
    if ss in seen:
        continue
    seq_tmp = str(seq[s].seq).upper()
    if 'A' not in seq_tmp and 'C' not in seq_tmp and 'G' not in seq_tmp and 'T' not in seq_tmp:
        continue
    seen.add(ss)
    seq_s += f'>{ss}\n{seq_tmp}\n'

with open(args.outfile, 'w') as f:
    f.write(seq_s)
