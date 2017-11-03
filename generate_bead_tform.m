%load input, base as xy coords
%input = 2D
%base = 3D

%warps input to base (2D to 3D)
%inverse will warp base to input (3D to 2D)

tform = cp2tform(input,base,'polynomial',3)

[out] = tforminv(tform,base);

plot(input(:,1),input(:,2),'m.')
hold on
plot(out(:,1),out(:,2),'k.')