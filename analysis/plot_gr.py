import numpy as np
import matplotlib.pyplot as plt

# compile RDF file into fortran, and create a module
get_ipython().system('f2py3 -c ../statistics.f90 -m statistics')

# import module
import statistics as stat

stat.declarate_radial_dist(L,total_esp,dr,g)

# import data
r, gr = np.loadtxt("../data/gr.data").T

fig = plt.figure(figsize=(3,3))
plt.plot(r[:-1], gr[:-1])

x1, x2, y1, y2 = plt.axis()
# plt.axis([x1, 4, y1, y2])
# plt.locator_params('x', nbins=6, tight='True')
plt.xlabel(r"r [$\sigma$]")
plt.ylabel("g(r)")
plt.legend(prop={'size':10})
fig.tight_layout() 
# plt.savefig("../plots/radial_dist.pdf")

plt.show()
