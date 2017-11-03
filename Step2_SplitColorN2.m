% clear;


ComponentLZ=.4; 
CompomentRZ=1-ComponentLZ;

IntensityRatioTh=2.38;

IfAvergaeCoordinates=0;

IfWriteResult=1;
IfWriteZdiff=0;
IfWriteZCor=0;
IfWriteZConcise=0;

SkipData=1; %Use 1 for non-skip

RejectStart=0;
RejectEnd=0;

IfInv2ndZ=0;

IfRead2ndImg=0;
IfRead1stImg=0;

FrameTol=0;
XTol=1; %pix0
YTol=1; %pix !!!!!!!!!!!!!!!!!!!!!

MoreMatchMode=0; %0- discard; 1-median; 2-use same frame only

ZCorCount=0;

ZShift=0;
DisplayFrame=1000;


ZTolPlus= 1480;
ZTolMinus=-1270;

if ~FrameTol
    outfile = sprintf('%s_%s.bin',filehead,filehead2);
else
    outfile = sprintf('%s_FrameTol_%d.bin',filehead,FrameTol);
end

bx=double(rMolAll.x);
by=double(rMolAll.y);
[tx,ty] = tforminv(tform,bx,by);

Right=rMolAll;
Right.x=tx;
Right.y=ty;

Left=LeftAll;

SplitData=Left;

NumLeft=Left.N;
NumRight=Right.N;

NowFrameNum=-1000;

NumofNoMatch=0;
NumofMoreMatch=0;
NumofMatch=0;

NumofZMismach=0;
NumofNotSameFrame=0;

% NumLeft=1000;
% MatchList=[];
IndicesC=[];
LeftIntensity=[];
RightIntensity=[];


% ZDiffList=zeros(min(NumLeft,NumRight),1);
% ZCorList=zeros(min(NumLeft,NumRight),4);

RightIndexLower=0;
RightIndexUpper=0;

for i=1+RejectStart:SkipData:NumLeft-RejectEnd
    %SplitData.cat(i)=1;
    
    if SplitData.cat(i)==9
        continue;
    end
    
    CurrentFrameNum = Left.frame(i);
    if CurrentFrameNum~=NowFrameNum
        NowFrameNum=CurrentFrameNum;
        
        if ~(mod(NowFrameNum,DisplayFrame))
            fprintf(1,'Current Frame:%d\n', NowFrameNum)
        end
        
        for RInd=RightIndexLower+1:NumRight
            if Right.frame(RInd)>=CurrentFrameNum-FrameTol
%                 RInd=RInd-1;
                break;
            end
        end
        RightIndexLower=max(1,RInd);

        for RInd=RightIndexUpper+1:NumRight
            if Right.frame(RInd)>CurrentFrameNum+FrameTol
                RInd=RInd-1;
                break;
            end
        end
        RightIndexUpper=max(1,RInd);
        if isempty(RightIndexUpper)
            RightIndexUpper=NumRight;
        end
        

        
        
        IndicesForRight=RightIndexLower:RightIndexUpper;
%         IndicesForRight1=IndicesForRight';
%         IndicesForRight=find(abs(Right.frame-CurrentFrameNum)<=FrameTol);
        
        if isempty(IndicesForRight)
            NumofNoMatch=NumofNoMatch+1;
            SplitData.cat(i)=2;
            continue %!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
        
        RCoX=Right.x(IndicesForRight);
        RCoY=Right.y(IndicesForRight);
    end

    if isempty(IndicesForRight)
        NumofNoMatch=NumofNoMatch+1;
        SplitData.cat(i)=2;
        continue %!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end

    
    LcoX=Left.x(i);
    LcoY=Left.y(i);
    
    IndicesMeetX=find(LcoX-XTol<RCoX & RCoX<LcoX+XTol);
    if isempty(IndicesMeetX)
        NumofNoMatch=NumofNoMatch+1;
        SplitData.cat(i)=2;
        continue %!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
    
    YForMolesMeetX=RCoY(IndicesMeetX);
    
    IndicesMeetY=find(LcoY-YTol<YForMolesMeetX & YForMolesMeetX<LcoY+YTol);
    if isempty(IndicesMeetY)
        NumofNoMatch=NumofNoMatch+1;
        SplitData.cat(i)=2;
        continue %!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
    
    RMatchedMolecule = IndicesForRight(IndicesMeetX(IndicesMeetY));
    ArMatchedXs=Right.x(RMatchedMolecule);
    ArMatchedYs=Right.y(RMatchedMolecule);
    ArMatchedZs=Right.z(RMatchedMolecule);
    ArMatchedCats=Right.cat(RMatchedMolecule);
        
    if length(IndicesMeetY)>1
        NumofMoreMatch=NumofMoreMatch+1;
        if MoreMatchMode==0
            NumofNoMatch=NumofNoMatch+1;
            SplitData.cat(i)=4;
            continue %!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
        
        ArMatchedFrames=Right.frame(RMatchedMolecule);
        
        if MoreMatchMode==1
            SplitData.cat(i)=7;
            MachedXuse=median(ArMatchedXs);
            MachedYuse=median(ArMatchedYs);
            MachedZuse=median(ArMatchedZs);
        end
        
        if MoreMatchMode==2
            SplitData.cat(i)=7;
            
            ArSameFrame=find(ArMatchedFrames==CurrentFrameNum);
            if length(ArSameFrame)~=1
                SplitData.cat(i)=8;
                NumofNoMatch=NumofNoMatch+1;
                continue %!!!!!!!!!!!!!!!!!!!!!!!!!!!
            end
            
            MachedXuse=ArMatchedXs(ArSameFrame);
            MachedYuse=ArMatchedYs(ArSameFrame);
            MachedZuse=ArMatchedZs(ArSameFrame);
            MatchCatuse=ArMatchedCats(ArSameFrame);
       
        end
        
    
    else
        %SplitData.cat(i)=1;
              
        MachedXuse=ArMatchedXs;
        MachedYuse=ArMatchedYs;
        MachedZuse=ArMatchedZs;
        MatchCatuse=ArMatchedCats;
    end
    
    if MatchCatuse==9
        SplitData.cat(i)=8;
        continue;
    end
    
    %     MatchList=[MatchList RMatchedMolecule];
    NumofMatch=NumofMatch+1;
    
%     Z1st=Left.z(i);
%     
%     if Z1st>0
%         Red1st=Z1st*CoZMatch1stPos;
%     else
%         Red1st=Z1st*CoZMatch1stNeg;
%     end
%     
%     if MachedZuse>0
%         Red2nd=MachedZuse*CoZMatch2ndPos;
%     else
%         Red2nd=MachedZuse*CoZMatch2ndNeg;
%     end
%     
%     ZDiff=Red1st+Red2nd; %"+" here = "--"
%        
%     ZDiffList(NumofMatch)=ZDiff;
%     
%     if ZDiff>ZTolPlus||ZDiff<ZTolMinus
%         NumofZMismach=NumofZMismach+1;
%         if SplitData.cat(i)==7
%             SplitData.cat(i)=6;
%         else
%             SplitData.cat(i)=8;
%         end
%     end
    
   
%     MergedX=(Left.x(i)+MachedXuse)/2;
%     MergedY=(Left.y(i)+MachedYuse)/2;
%     MergedZ=(Left.z(i)-MachedZuse)/2+ZShift;

%     ZCorCount=ZCorCount+1;
%     ZCorList(ZCorCount,:)=[MergedX MergedY Left.z(i) MachedZuse];

    if IfAvergaeCoordinates
        MergedI=Left.I(i)+Right.I(RMatchedMolecule);

        %The weighting below gives additional weight to the width of PSF over the photon count, as the former is perceived to be more important.
        %Alternative weighting methods can also be implemented.

        ErL=(Left.width(i)*Left.width(i))/sqrt(max(Left.I(i),1));
        ErLX=ErL/Left.Ax(i);
        ErLY=ErL*Left.Ax(i);

        ErR=(Right.width(RMatchedMolecule)*Right.width(RMatchedMolecule))/sqrt(Right.I(RMatchedMolecule));
        ErRX=ErR/Right.Ax(RMatchedMolecule);
        ErRY=ErR*Right.Ax(RMatchedMolecule);

        ComponentLX=ErRX*ErRX/(ErRX*ErRX+ErLX*ErLX);
        ComponentRX=1-ComponentLX;

        ComponentLY=ErRY*ErRY/(ErRY*ErRY+ErLY*ErLY);
        ComponentRY=1-ComponentLY;

        MergedX=Left.x(i)*ComponentLX+MachedXuse*ComponentRX;
        MergedY=Left.y(i)*ComponentLY+MachedYuse*ComponentRY;
        MergedZ=Left.z(i)*ComponentLZ+MachedZuse*CompomentRZ; 
%         MergedZ=Left.z(i);
        SplitData.x(i)=MergedX;
        SplitData.y(i)=MergedY;
        SplitData.z(i)=MergedZ;
    end    
%     MergedList(NumofMatch,:)=[SplitData.cat(i) MergedX MergedY MergedX MergedY Left.h(i) Left.area(i) Left.width(i) ComponentLX ComponentLY ZDiff MergedI Left.frame(i) Left.length(i) Left.link(i) Left.valid(i) MergedZ MergedZ];
%     LeftIntensity(i)=Left.I(i);
%     RightIntensity(i)=Right.I(RMatchedMolecule);
    
    IntensityRatio=Left.I(i)/Right.I(RMatchedMolecule);
    SplitData.Ax(i)=IntensityRatio;
    SplitData.area(i)=Right.I(RMatchedMolecule);
     
    if IntensityRatio>IntensityRatioTh
        SplitData.cat(i)=0;
    else
        SplitData.cat(i)=1;
    end
    
end

%%%Extra Stuff
% cat=SplitData.cat;
% Cat1Ind=find(cat==1);
% Cat0Ind=find(cat==0);
% Cat0Num=numel(Cat0Ind);
% Cat1Num=numel(Cat1Ind);
% 
% num=Cat0Num/(Cat1Num+Cat0Num)


% a=25;
% figure(1)
% scatter(RightIntensity,LeftIntensity,a,'filled')
%%%End Extra Stuff
fprintf(1,'Writing to file...\n');

WriteMolBinN(SplitData,outfile);
