import argparse
from Bio import SeqIO

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--infile', type=str)
parser.add_argument('--start', type=int)
parser.add_argument('--end', type=int)
parser.add_argument('--outfile', type=str)
args = parser.parse_args()

s = ""
all_seq = SeqIO.to_dict(SeqIO.parse(args.infile, "fasta"))

s = [f'>{i}\n{str(all_seq[i].seq)[args.start: args.end+1]}\n' for i in all_seq]

with open(args.outfile, 'w') as f:
    f.write(''.join(s))
