function [dist,path,pred,x,y,Pt,DistMat,startpoint,longest_end,endp,Pt1,Pt2,leaf_ID_good,longpath,Pt3,new_skeBW]=LongestPath(skeBW);
[y,x] = find(skeBW);
Pt = [y x];

%find distance matrix between all these useful point
% [null] = Func_Diagnostic('Computing Distance Matrix...');
% waitbar(0.375,h,'Computing Distance Matrix..')
[IDX,D] = knnsearch(Pt,Pt,'K',10);

%removes self counting
D(:,1)= [];
IDX(:,1) = [];
%preallocates the distance matrix
DistMat = sparse(max(size(y)));
k = 0;

for i=1:size(y,1)
    %you are at node i
    
    %find neighbors ID
    NN = find( D(i,:) < 2);
    if NN == 1;
        %%change name
        leaf_ID(k+1) = IDX(i,NN);
        k = k+1;
    end
    NN_ID = IDX(i,NN);
    n_NN_ID = max(size(NN_ID));
    
    %find distance from NN_ID to i
    for j=1:n_NN_ID
        DistMat(i,NN_ID(j)) = D(i,NN(j));
        DistMat(NN_ID(j),i) = D(i,NN(j));
    end
end
% disp('Done.')


%finding closest start point to the coordinates the user has input
%after skeletonizing,since everything has become one pixel
startpts = [max(size(skeBW)),min(size(skeBW))/2];
startpts = round(startpts);
[Istart,Dstart] = knnsearch(Pt,startpts, 'K',2);

%Locates all the leafs on the graph, and creates a shortest path from the
%start point to each leaf. Using this concept, the end point of the primary
%root can be located, by using the longest "shortest path" from the
%starting point to the leaf.
% [null] = Func_Diagnostic('Finding Longest Shortest Path...');
% waitbar(0.5,h,'Finding Best Path..')
max_length = max(size(leaf_ID));
dist = zeros(max_length,1); %preallocate memory for shortest distance of all leaf ids
for n = 1 : max_length
    [dist(n)]=graphshortestpath(DistMat,Istart(1),leaf_ID(n));
end
%ID of the longest "shortest path"
n = find(dist == max(dist));
nn=n;
% disp('Done.')

%Outputs details of the shortest path.
[dist, path, pred]=graphshortestpath(DistMat,Istart(1),leaf_ID(n(1)));

longest_end=leaf_ID(n(1));
startpoint=Istart(1);
endp=leaf_ID;



pp1=x(path);
pp2=y(path);
longpath=[pp2 pp1];

old_skeBW=skeBW;
for (i=1:max(size(longpath)))
skeBW(longpath(i,1),longpath(i,2))=0;
end
new_skeBW=old_skeBW-skeBW;
[y1,x1]=find(skeBW);
Pt1=[y1 x1];

[y2,x2] = find(new_skeBW);
Pt2=[y2 x2];

leaf_ID=endp;
for i=1:max(size(leaf_ID))
endpp(i,:)=Pt(leaf_ID(i),:);
end
x1=endpp(:,1);
y1=endpp(:,2);
leaf_ID_good = boundary(x,y,0.1);
Pt3=[y(leaf_ID_good) x(leaf_ID_good)];
% plot(x(leaf_ID_good),y(leaf_ID_good),'b', 'LineWidth', 2);