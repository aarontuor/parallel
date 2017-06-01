import numpy as np
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("matrix", type=str, help="Plain text file to plot heatmap of.")
parser.add_argument("imagefile", type=str, help="File to save plot to.")
args = parser.parse_args()
matrix = np.loadtxt(args.matrix)
plt.imshow(matrix, cmap='hot')
plt.savefig(args.imagefile)
plt.show()
