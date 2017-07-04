import pylab as plt
import numpy as np
import os
from mpl_toolkits.axes_grid1 import make_axes_locatable

#change the working directory according to where the UppASD output files are located
os.chdir('/UppASD/UppASD_output_files')

data = np.loadtxt('moment.test2d00.out')
data = data[:,2:5]

X = data[:,0]
X = X.reshape(100,100)

Y = data[:,1]
Y = Y.reshape(100,100)

Z = data[:,2]
Z = Z.reshape(100,100)

data=np.stack((X,Z),axis=0)

fig, axes = plt.subplots(nrows=1, ncols=2)

flag=0
for dat, ax in zip(data, axes.flat):
	im = ax.imshow(dat, vmin=-1, vmax=1, origin='lower')
	ax.set_title('x-components')

	if flag==1:
		ax.set_title('z-components')
		
	flag=1
	
		 

plt.setp(axes, xticks=[0,20,40,60,80,100], yticks=[0,20,40,60,80,100])

fig.colorbar(im,  ax=axes.ravel().tolist(), orientation='horizontal')

plt.show()


