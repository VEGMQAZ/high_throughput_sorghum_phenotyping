function [skeBW pathTop distTop rightBoundary leftBoundary distCheck xskeBW yskeBW temp Blur]=lengthCroppedBottom2(IMG)
LB1KNN = knnRB(IMG,2);
temp=LB1KNN(:,:,1);
CC = bwconncomp(temp);
numPixels = cellfun(@numel,CC.PixelIdxList);
temp = zeros(size(temp));
[biggest,idx] = max(numPixels);
temp(CC.PixelIdxList{idx}) = 1;
Blur = imgaussfilt(temp,10);
count=1;
for j=1:size(Blur,1)
    checkB = Blur(j,:);
    [r c] = find(checkB);
    if ~isempty(c)
        leftBoundary(count,1:2) = [j min(c)];
        rightBoundary(count,1:2) = [j max(c)];
        Blur(j,min(c):max(c))=1;
        count = count + 1;
    end
end
%Blur = imfill(temp,'holes');
% blu=imgaussfilt(Blur,10);
skeBW = bwmorph(Blur,'thin',inf);
skeBW(1,:)=0;
skeBW(end,:)=0;
skeBW(:,1)=0;
skeBW(:,end)=0;
[dist,path,pred,x,y,Pt,DistMat,startpoint,longest_end,endp,Pt1,Pt2,leaf_ID_good,longpath,Pt3,new_skeBW]=LongestPath(skeBW);
[DistMat]=FourthFindGraph(skeBW);
nn=bwmorph(skeBW,'endpoints');
[vv ww]=find(nn);
Endpoints = [vv ww];
sortedEndpoints = sortrows(Endpoints);
[yskeBW xskeBW]=find(skeBW);
MatOne = [yskeBW xskeBW];
distCheck=-1;

path=[];
% startpts=[size(IMG,1) size(IMG,2)/2];
% startpts=[repmat(size(IMG,1),size(IMG,2),1) [1:size(IMG,2)]'];
% [Istart,Dstart] = knnsearch(MatOne,startpts, 'K',1);
Istart=find(xskeBW==sortedEndpoints(end,2) & yskeBW==sortedEndpoints(end,1));
linearIndEndTop=find(xskeBW==sortedEndpoints(1,2) & yskeBW==sortedEndpoints(1,1));
[distTop, pathTop, predTop]=graphshortestpath(DistMat,Istart,linearIndEndTop);
% for endIter=1:size(Endpoints,1)
%     
%     
%     linearIndEnd=find(xskeBW==Endpoints(endIter,2) & yskeBW==Endpoints(endIter,1));
%     %             linearIndStart=find(xskeBW==Endpoints(startIter,2) & yskeBW==Endpoints(startIter,1));
%     [dist, path, pred]=graphshortestpath(DistMat,Istart,linearIndEnd);
%     if (dist>distCheck)
%         distCheck=dist;
%         mainLinearIndEnd = linearIndEnd;
%         mainLinearIndStart = Istart;
%         mainPath=path;
%     end
%     
% end
end
% z