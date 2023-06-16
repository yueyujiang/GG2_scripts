import argparse
import numpy as np

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--infile', type=str)
parser.add_argument('--outfile', type=str)
parser.add_argument('--ratio', type=float, default=None)
parser.add_argument('--size', type=int, default=None)
args = parser.parse_args()

with open(args.infile, 'r') as f:
    a = f.read().split('\n')

if not a[-1]:
    a = a[:-1]

if args.size is not None:
    size = args.size

if args.ratio is not None:
    size = int(len(a) * args.ratio)

a = np.random.choice(a, size=size, replace=False)

with open(args.outfile, 'w') as f:
    f.write("\n".join(a))
