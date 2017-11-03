clearvars -except LastFolder DistanceRight1;
if exist('LastFolder','var')
    GetFileName=sprintf('%s/*.bin',LastFolder);
else
    GetFileName='*.bin';
end

%--------Parameters to tweak-----------

ShiftX=0; %Inital shift, necessary if centers of the two views are not well aligned
ShiftY=0; %Inital shift, necessary if centers of the two views are not well aligned
MatchDistanceMax=7; %The max shift from center allowed (in pixels). Choose ~7.
TolSigma=4; %Tolenrance btw two views. Choose ~4.
CheckWarpJumpFr=100; %Only align the data every x frames; otherwise too many moelcues to map.

%-------------------------
[FileNameL,PathNameL] = uigetfile(GetFileName,'Select the L bin file to map');
GetFileName=sprintf('%s/*.bin',PathNameL);
[FileNameR,PathNameR] = uigetfile(GetFileName,'Select the R bin file to map');
LastFolder=PathNameR;

LeftFile =sprintf('%s%s',PathNameL,FileNameL);
RightFile =sprintf('%s%s',PathNameR,FileNameR);
FileNameRLen=size(FileNameR);
FileNameRLen=FileNameRLen(2)-1;
filehead = LeftFile(1:end-4);
filehead2 = RightFile(end-FileNameRLen:end-4);
ReverseZ=1;  %!!!!!!!!!!!!!!!!!!!!Use "1" here if want to reverse z

readbin = 1;
is3D = 0;

increasecat = 1;    % 1 to make category +1, 0 for no change in category

%warpfile = 'tform_tmp.mat';%'STORM_warp_std.mat'; %The standard warping file used for initnial alignment

warpfile = sprintf('tardis_splitplane_map_090616.mat'); %The standard warping file used for initnial alignment


%OutFilePairs = sprintf('%s_FoundPairs.txt',filehead);

load(warpfile);

fprintf(1,'Loading right molecule list...\n');
[rMolAll, r]= readbinfileNXcYcZcCat1All(RightFile);

bx = double(r.x);
by = double(r.y);


Nr = size(r.x,1);

fprintf(1,'warping using std...\n');
if (is3D)
    % Warping in 3D
    bz = r.z;
    [tx,ty,tz] = tforminv(tform,bx,by,bz);
else
    [tx,ty] = tforminv(tform,bx,by);
end


fprintf(1,'Rough shifting...\n');
tx=tx+ShiftX;
ty=ty+ShiftY;


ww = r;
ww.x = tx;
ww.y = ty;
if (ReverseZ)
    ww.z=-r.z;
end

if (is3D)
    if (ReverseZ)
        ww.z = -1.*tz;
    else
        ww.z = tz;  
    end
end
% incat1 = find(r.cat==1);
if (increasecat)
    ww.cat = r.cat + increasecat;
end


Right = ww;
RightOrg=r;

fprintf(1,'\nLoading left bin file...\n')
[LeftAll Left] = readbinfileNXcYcZcCat1All(LeftFile);
fprintf(1,'Loaded!\n')

NumLeft=length(Left.x);
NumRight=length(Right.x);
TotalFrame=Left.frame(NumLeft-1);

MasterMatchedLeftX=[];
MasterMatchedLeftY=[];
MasterMatchedRightX=[];
MasterMatchedRightY=[];

MasterMatchedRightOrgX=[];
MasterMatchedRightOrgY=[];

MasterMatchedDistance=[];

for CurrentFrame = 1:CheckWarpJumpFr:TotalFrame  %+2: for multicolor
    CurrentFrameListLeftInd = find(Left.frame == CurrentFrame);
    CurrentFrameListRightInd = find(Right.frame == CurrentFrame);
    CurrentFrameListLeftX = Left.x(CurrentFrameListLeftInd);
    CurrentFrameListLeftY = Left.y(CurrentFrameListLeftInd);
    CurrentFrameListRightX = Right.x(CurrentFrameListRightInd);
    CurrentFrameListRightY = Right.y(CurrentFrameListRightInd);

    CurrentFrameListRightOrgX = RightOrg.x(CurrentFrameListRightInd);
    CurrentFrameListRightOrgY = RightOrg.y(CurrentFrameListRightInd);

    
    NumLeft=length(CurrentFrameListLeftInd);
    
    MatchedDistance=zeros(1,NumLeft);
    MatchedInd=zeros(1,NumLeft);
  
    for i =1:NumLeft
        CurrentLeftMolX=CurrentFrameListLeftX(i);
        CurrentLeftMolY=CurrentFrameListLeftY(i);
        
        DistanceRightX = CurrentFrameListRightX - CurrentLeftMolX;
        DistanceRightY = CurrentFrameListRightY - CurrentLeftMolY;
        DistanceRight = sqrt(DistanceRightX.*DistanceRightX + DistanceRightY.*DistanceRightY);
        [DistMin MinInd]=min(DistanceRight);
        if DistMin<MatchDistanceMax
            MatchedDistance(i)=DistMin;
            MatchedInd(i)=MinInd;
        end
        if numel(MinInd)>1
            break
        end
    end
        
    ValidMatchInd = find(MatchedInd);
    MatchedInd = MatchedInd(ValidMatchInd);
    MatchedDistance = MatchedDistance(ValidMatchInd);
    %use column vectors instead of row vectors for indexing
    ValidMatchInd=ValidMatchInd';
    MatchedInd=MatchedInd';
    
    MatchedLeftX = CurrentFrameListLeftX(ValidMatchInd);
    MatchedLeftY = CurrentFrameListLeftY(ValidMatchInd);
    
    MatchedRightX =CurrentFrameListRightX(MatchedInd);
    MatchedRightY =CurrentFrameListRightY(MatchedInd);

    MatchedRightOrgX =CurrentFrameListRightOrgX(MatchedInd);
    MatchedRightOrgY =CurrentFrameListRightOrgY(MatchedInd);
   
        
    MasterMatchedLeftX = [MasterMatchedLeftX MatchedLeftX'];
    MasterMatchedLeftY = [MasterMatchedLeftY MatchedLeftY'];
    
    MasterMatchedRightX = [MasterMatchedRightX MatchedRightX'];
    MasterMatchedRightY = [MasterMatchedRightY MatchedRightY'];

    MasterMatchedRightOrgX = [MasterMatchedRightOrgX MatchedRightOrgX'];
    MasterMatchedRightOrgY = [MasterMatchedRightOrgY MatchedRightOrgY'];
    
    
    MasterMatchedDistance = [MasterMatchedDistance MatchedDistance];
    
end

figure(1)
plot(MasterMatchedRightX,MasterMatchedRightY,'k.',MasterMatchedLeftX,MasterMatchedLeftY,'m.')

DiffX=double(MasterMatchedRightX-MasterMatchedLeftX);
DiffY=double(MasterMatchedRightY-MasterMatchedLeftY);

HistBinX=min(DiffX):.01:max(DiffX);
[BinCountDiffX, xout]=hist(DiffX,HistBinX);
[Gaussfit FitErr]=fit(xout(2:end-1)',BinCountDiffX(2:end-1)','gauss1');
XDiffCenter=Gaussfit.b1;
XDiffSigma=Gaussfit.c1/1.4142;

HistBinY=min(DiffY):.01:max(DiffY);
[BinCountDiffY, yout]=hist(DiffY,HistBinY);
[Gaussfit FitErr]=fit(yout(2:end-1)',BinCountDiffY(2:end-1)','gauss1');
YDiffCenter=Gaussfit.b1;
YDiffSigma=Gaussfit.c1/1.4142;

DiffXRel=abs(DiffX-XDiffCenter);
DiffYRel=abs(DiffY-YDiffCenter);

GoodMatchInd=find(DiffXRel<XDiffSigma*TolSigma & DiffYRel<YDiffSigma*TolSigma);
GoodMatchedRightX=MasterMatchedRightX(GoodMatchInd);
GoodMatchedRightY=MasterMatchedRightY(GoodMatchInd);
GoodMatchedLeftX=MasterMatchedLeftX(GoodMatchInd);
GoodMatchedLeftY=MasterMatchedLeftY(GoodMatchInd);
GoodMatchedRightOrgX=double(MasterMatchedRightOrgX(GoodMatchInd));
GoodMatchedRightOrgY=double(MasterMatchedRightOrgY(GoodMatchInd));

figure(2)
plot(GoodMatchedRightX,GoodMatchedRightY,'k.',GoodMatchedLeftX,GoodMatchedLeftY,'m.')

input=double([GoodMatchedLeftX' GoodMatchedLeftY']);

%[GoodMatchedRightOrgX, GoodMatchedRightOrgY]=tformfwd(tform,GoodMatchedRightX',GoodMatchedRightY');

% GoodMatchedRightOrgX=GoodMatchedRightX-ShiftX;
% GoodMatchedRightOrgY=GoodMatchedRightY-ShiftY;


base=double([GoodMatchedRightOrgX' GoodMatchedRightOrgY']);

figure(3)
plot(input(:,1),input(:,2),'k.',GoodMatchedRightOrgX,GoodMatchedRightOrgY,'m.');

% tform = cp2tform(input,base,'polynomial',4);

tform = cp2tform(input,base,'projective');


[tx,ty] = tforminv(tform,GoodMatchedRightOrgX,GoodMatchedRightOrgY);

figure(4)
plot(input(:,1),input(:,2),'k.',tx,ty,'m.');

% Saving tform 
outfileTform = sprintf('%s_warp.mat',filehead);
save(outfileTform,'tform');
outfileTform = 'Right-Left.mat'; %Addiotnal copy in the current folder
save(outfileTform,'tform');

%FoundPairs=[input base];

%dlmwrite(OutFilePairs, FoundPairs, 'delimiter', '\t', 'precision', 9)
