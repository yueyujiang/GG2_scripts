import argparse
import copy
import collections
import treeswift as ts

parser = argparse.ArgumentParser(description='test')
parser.add_argument('--extended-tree', type=str)
parser.add_argument('--smaller-tree', type=str)
parser.add_argument('--new-species', type=str)
parser.add_argument('--outfile', type=str)
args = parser.parse_args()

extending_tree = ts.read_tree_newick(args.extended_tree)
original_tree = ts.read_tree_newick(args.smaller_tree)

# for i in original_tree.traverse_postorder():
#     if i.edge_length is not None and i.edge_length < 0:
#         breakpoint()
# r = ts.Node()
# a = ts.Node(label='a', edge_length=1)
# b = ts.Node(label='b', edge_length=1)
# c = ts.Node(label='c', edge_length=1)
# original_tree = ts.Tree()
# original_tree.root = r
# n1 = ts.Node(label='n1', edge_length=1)
# r.add_child(n1)
# r.add_child(c)
# n1.add_child(a)
# n1.add_child(b)
#
# r = ts.Node()
# a = ts.Node(label='a', edge_length=2)
# b = ts.Node(label='b', edge_length=2)
# c = ts.Node(label='c', edge_length=2)
# d = ts.Node(label='d', edge_length=2)
# e = ts.Node(label='e', edge_length=2)
# f = ts.Node(label='f', edge_length=2)
# g = ts.Node(label='g', edge_length=2)
# h = ts.Node(label='h', edge_length=2)
# i = ts.Node(label='i', edge_length=2)
# n2 = ts.Node(label='n2', edge_length=2)
# n3 = ts.Node(label='n3', edge_length=2)
# n4 = ts.Node(label='n4', edge_length=2)
# n5 = ts.Node(label='n5', edge_length=2)
# n6 = ts.Node(label='n6', edge_length=2)
# n7 = ts.Node(label='n7', edge_length=2)
# n8 = ts.Node(label='n8', edge_length=2)
# extending_tree = ts.Tree()
# extending_tree.root = r
# r.add_child(n3)
# r.add_child(n2)
# n2.add_child(n4)
# n2.add_child(n5)
# n4.add_child(a)
# n4.add_child(f)
# n5.add_child(d)
# n5.add_child(n6)
# n6.add_child(e)
# n6.add_child(b)
# n3.add_child(n7)
# n3.add_child(c)
# n7.add_child(i)
# n7.add_child(n8)
# n8.add_child(g)
# n8.add_child(h)
#
# new_species = set(['d', 'e', 'f', 'g', 'h', 'i'])
with open(args.new_species, 'r') as f:
    new_species = set(f.read().split('\n'))

for node in extending_tree.traverse_postorder():
    if node.is_leaf():
        if node.label in new_species:
            node.is_new = True
        else:
            node.is_new = False
    else:
        is_new = True
        for c in node.child_nodes():
            if not c.is_new:
                is_new = False
                break
        node.is_new = is_new

remove_node = []

start_node = extending_tree.root
def preorder_traverse(node):
    if node.is_new:
        p = node.parent
        for c in p.child_nodes():
            if c != node:
                remove_node.append(node)
                break
        return
    if node.is_leaf():
        return
    for c in node.child_nodes():
        preorder_traverse(c)

preorder_traverse(start_node)
new_species_dict = collections.defaultdict(list)
for n in remove_node[::-1]:
    # for the new species added in the same edges, we need process it from bottom to top
    p = n.parent
    for c in p.child_nodes():
        if c != n:
            break
    n.parent.parent.add_child(c)
    n.parent.parent.remove_child(n.parent)
    new_species_dict[c].append((n, c.edge_length))
    if n.parent in new_species_dict:
        for olditem in new_species_dict[n.parent]:
            new_species_dict[c].append((olditem[0], olditem[1] + c.edge_length))
        # breakpoint()
        new_species_dict.pop(n.parent)
    # new_species_dict[n] = (c, c.edge_length)
    c.edge_length += n.parent.edge_length

for n in new_species_dict:
    for i, item in enumerate(new_species_dict[n]):
        new_species_dict[n][i] = (item[0], item[1] / n.edge_length)

# leaves = []
# for n in original_tree.traverse_postorder():
#     if n.is_leaf():
#         leaves.append(n.label)

species_set1 = set([i.label for i in extending_tree.traverse_leaves()])
species_set2 = set([i.label for i in original_tree.traverse_leaves()])
constrained_species = species_set1.intersection(species_set2)

tree_dict = {}
def postorder_traverse(node):
    if node.is_leaf():
        node.descent = set([node.label]).intersection(constrained_species)
        tree_dict[frozenset(node.descent)] = node
#        tree_dict[frozenset(constrained_species.difference(node.descent))] = node
        return
    descent = set()
    for c in node.child_nodes():
        postorder_traverse(c)
        descent = descent.union(c.descent)
    tree_dict[frozenset(descent)] = node
    node.descent = descent
#    tree_dict[frozenset(constrained_species.difference(node.descent))] = node

postorder_traverse(original_tree.root)
original_tree_dict = tree_dict

tree_dict = {}
postorder_traverse(extending_tree.root)
extending_tree_dict = tree_dict

node_corr = {}
for i in original_tree_dict:
    if not i:
        continue
    if i in extending_tree_dict:
        node_corr[extending_tree_dict[i]] = original_tree_dict[i]
    elif frozenset(constrained_species.intersection(i)) in extending_tree_dict:
        node_corr[extending_tree_dict[frozenset(constrained_species.intersection(i))]] = original_tree_dict[i]
    else:
        breakpoint()

for n in new_species_dict:
    # breakpoint()
    items = sorted(new_species_dict[n], key=lambda x: x[1])
    original_node = node_corr[n]
    edge_length = original_node.edge_length
    current_node = original_node
    current_pos = 0
    for item in items:
        new_node = ts.Node(edge_length=edge_length - edge_length * item[1])
        current_node.parent.add_child(new_node)
        current_node.parent.remove_child(current_node)
        # current_node.parent = None
        new_node.add_child(current_node)
        new_node.add_child(item[0])
        current_node.edge_length = edge_length * (item[1] - current_pos)
        current_node = new_node
        current_pos = item[1]

    # for i in original_tree.traverse_postorder():
    #     if i.edge_length is not None and i.edge_length < 0:
    #         breakpoint()
        # new_node.is_newnode = True
    # if original_node.edge_length < 0 or original_node.parent.edge_length < 0:
    #     breakpoint()
# for i in original_tree.traverse_postorder():
#     if i.edge_length is not None and i.edge_length < 0:
#         breakpoint()

original_tree.write_tree_newick(args.outfile)
