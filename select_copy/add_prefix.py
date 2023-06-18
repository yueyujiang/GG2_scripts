import argparse

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--infile', type=str)
parser.add_argument('--outfile', type=str)
parser.add_argument('--prefix', type=str)
args = parser.parse_args()

with open(args.infile, 'r') as f:
    seq = f.read().split('\n')

seq = [f'>{args.prefix}{a[1:]}' if a.startswith('>') else a for a in seq]

with open(args.outfile, 'w') as f:
    f.write("\n".join(seq))
