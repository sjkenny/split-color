%evaluate crosstalk with Z section
addpath ../common

r=OpenMolList;



%crosstalk vs. z section thickness
z_max=600;
z_start = 0;
z_range = z_max-z_start;
z_step = 60;

z_idx = z_start:z_step:z_max;

crosstalk=z_idx.*0;
for i=1:numel(z_idx)
    zfind=z_idx(i);
    z_idx_3 = find(r.zc<zfind&r.cat==3);
    z_idx_2 = find(r.zc<zfind&r.cat==2);
    crosstalk(i) = numel(z_idx_3)/(numel(z_idx_2)+numel(z_idx_3));
end
plot(z_idx,crosstalk)
    