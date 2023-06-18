import argparse
import parser
import os
from Bio import SeqIO
import numpy as np

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--out-dir', type=str)
parser.add_argument('--seq-file', type=str)
#parser.add_argument('--backbone-names', type=str, default=None)
parser.add_argument('--query-names', type=str, default=None)
parser.add_argument('--replicate', action='store_true')
args = parser.parse_args()

ratio = 0.5

if args.query_names == 'None':
    args.query_names = None

all_seq = SeqIO.to_dict(SeqIO.parse(args.seq_file, "fasta"))

species = set(all_seq.keys())
if not args.query_names is None:
    with open(args.query_names, 'r') as f:
        query_s = set(f.read().split('\n'))
else:
    if args.replicate:
        species_t = set([i.split('_')[0] for i in species])
        query_s = np.random.choice(list(species_t), size=int(ratio*len(species_t)), replace=False)
    else:
        query_s = np.random.choice(list(species), size=int(ratio*len(species)), replace=False)
backbone = ""
query = ""
for s in species:
    if args.replicate:
        ss = s.split('_')[0]
    else:
        ss = s
    if ss not in query_s:
        backbone += f">{s}\n"
        backbone += f"{all_seq[s].seq}\n"
    else:
        query += f">{s}\n"
        query += f"{all_seq[s].seq}\n"

if not os.path.isdir(args.out_dir):
    os.mkdir(args.out_dir)

with open(f'{args.out_dir}/backbone.fa', 'w') as f:
    f.write(backbone)
with open(f'{args.out_dir}/query.fa', 'w') as f:
    f.write(query)
with open(f'{args.out_dir}/query_label.txt', 'w') as f:
    f.write("\n".join(query_s))
