import argparse
import collections
import treeswift as ts
import pandas as pd
import numpy as np

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--infile', type=str)
parser.add_argument('--outfile', type=str)
args = parser.parse_args()

tree = ts.read_tree_newick(args.infile)
tree.resolve_polytomies()
tree.write_tree_newick(args.outfile)
