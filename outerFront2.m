


clear all
close all% function [result]=lengthAndWidthBottom(var)
ss1 = dir(strcat('/home/vahid/Desktop/UsingLengthandUniqueAndOnlyNearestToBottom/Data/panicles.front.view/*.JPG'));
mkdir (pwd,'frontViewCheck')

let=[];
for j=789:789%length(ss1)
% 	clearvars -except ss1 j result var
% try
    j
    IMG=imread(strcat('/home/vahid/Desktop/UsingLengthandUniqueAndOnlyNearestToBottom/Data/panicles.front.view/',ss1(j).name));
    
    result1{j,1}=ss1(j).name;
    
%     [skeBW pathTop distTop allrightBoundary allleftBoundary distCheck xskeBW yskeBW temp Blur]=blurAndOuterBoundary(IMG);
[skeBW pathTop distTop rightBoundary leftBoundary distCheck xskeBW yskeBW temp Blur]=lengthCroppedBottom2(IMG);

    pathTopSub = [yskeBW(pathTop) xskeBW(pathTop)];
    result2{j,1}=length(unique(pathTopSub(:,1)));
  
    mainPathSubUnique = unique(pathTopSub(:,1),'rows');
    area = nnz(Blur);
%     result3{j,1} = area / length(unique(pathTopSub(:,1)));
    
%     smoothPath = smooth(mainPathSubUnique(:,2),mainPathSubUnique(:,1),0.1,'loess');
    smoothPath = smoothdata(unique(pathTopSub,'rows'),'sgolay','SmoothingFactor',1);
    
    step = size(smoothPath,1) / 10;
    count = 0;
    Distance = [];
    idxLength = [];
    count5=0;
    count10=0;
    each5 = {};
    each10 = {};
    for i=2:50:size(smoothPath,1)-1
        count = count + 1;
        slope = (smoothPath(i-1,1) - smoothPath(i+1,1)) / ...
            (smoothPath(i-1,2) - smoothPath(i+1,2));
        m = -1/slope;
        
        tempData = -m*smoothPath(i,2)+smoothPath(i,1);
        resultRight = abs(m*rightBoundary(:,2)-rightBoundary(:,1) + tempData);
        [numRight,idxRight] = min(resultRight);
        resultLeft = abs(m*leftBoundary(:,2)-leftBoundary(:,1) + tempData);
        [numLeft,idxLeft] = min(resultLeft);
        Distance= [Distance;[leftBoundary(idxLeft,:) smoothPath(i,:) rightBoundary(idxRight,:)]];
        
        idxLength = [idxLength;i];
        

            
    end

        
    result4{j,1} = Distance;
    result5{j,1} = idxLength;
  

    
    close all
    h=figure;
    subplot(1,2,1)
    set(h, 'Visible', 'on');
    imshow(IMG)
    hold on
%     scatter(pathTopSub(:,2),pathTopSub(:,1),'*w','LineWidth',2);
    scatter(smoothPath(:,2),smoothPath(:,1),'*g','LineWidth',2);

  
    hold off
    subplot(1,2,2)
    set(h, 'Visible', 'on');
    imshow(IMG)
    hold on
      for t=1:count
        line ([Distance(t,2),Distance(t,4),Distance(t,6)] ,[Distance(t,1),Distance(t,3),Distance(t,5)]);
    end
    scatter(rightBoundary(:,2),rightBoundary(:,1),'*b','LineWidth',2);
    scatter(leftBoundary(:,2),leftBoundary(:,1),'*r','LineWidth',2);
    scatter(smoothPath(:,2),smoothPath(:,1),'*g','LineWidth',2);
    saveFileNameWidth = strcat(pwd,'/frontViewCheck/',ss1(j).name)
%     saveas(h,strcat(strtok(saveFileNameWidth,'.'),'.jpg'));
%    catch
% let=[let;j];
% end 
    
    
    
       
end
load('frontOuter.mat')
result = [result1 result2 result4];
resultTable = cell2table(result);
resultTable.Properties.VariableNames = {'Name','Length','width'};


meanEach5 = [];
maxEach5 = [];
medianEach5 = [];
meanEach10 = [];
maxEach10 = [];
medianEach10 = [];


ss = [];
for i =1:size(result4)
    clear X Y w 
    meanEach5 = [];
maxEach5 = [];
medianEach5 = [];
meanEach10 = [];
maxEach10 = [];
medianEach10 = [];
    X = result4{i,1}(:,1:2);
    Y = result4{i,1}(:,5:6);
    w = diag(pdist2(X,Y));
    for iter=5:5:size(w,1)
        meanEach5 = [meanEach5;mean(w(iter-4:iter,1))];
        maxEach5 = [maxEach5;max(w(iter-4:iter,1))];
        medianEach5 = [medianEach5;median(w(iter-4:iter,1))];
        
    end
    for iter=10:10:size(w,1)
        meanEach10 = [meanEach10;mean(w(iter-9:iter,1))];
        maxEach10 = [maxEach10;max(w(iter-9:iter,1))];
        medianEach10 = [medianEach10;median(w(iter-9:iter,1))];
        
    end
    resultMeanEach10{i,1} = meanEach10;
    resultMaxEach10{i,1} = maxEach10;
    resultMedianEach10{i,1} = medianEach10;
    
    resultMeanEach5{i,1} = meanEach5;
    resultMaxEach5{i,1} = maxEach5;
    resultMedianEach5{i,1} = medianEach5;
        
end


for i =1:size(result4)
    clear X Y w 
    X = result4{i,1}(:,1:2);
    Y = result4{i,1}(:,5:6);
    w = diag(pdist2(X,Y));
    
    widthDist{i,1}=w(:,1);
    ss=[ss;size(w(:,1))];
    widthMean{i,1}=mean(w(:,1));
    widthMax{i,1}=max(w(:,1));
    widthMedian{i,1}=median(w(:,1));
    
end

output=[result1 result2 widthMean widthMedian widthMax];
outputTable = cell2table(output);

outputTable.Properties.VariableNames = {'Name','Length','widthMean' , 'widthMedian','widthMax'};
writetable(outputTable,'traitFront.xlsx');

widthDistTable=cell2table([result1 widthDist(:,1)]);
writetable(widthDistTable,'widthDistTableFront.xlsx')


widthDistTable=cell2table([result1 result5]);
writetable(widthDistTable,'widthDistTableIndexFront.xlsx')



   
    
resultMeanEach10Table=cell2table([result1 resultMeanEach10]);
writetable(resultMeanEach10Table,'lineByLineFront.xlsx','Sheet','MeanEach10')

resultMaxEach10Table=cell2table([result1 resultMaxEach10]);
writetable(resultMaxEach10Table,'lineByLineFront.xlsx','Sheet','MaxEach10')

resultMedianEach10Table=cell2table([result1 resultMedianEach10]);
writetable(resultMedianEach10Table,'lineByLineFront.xlsx','Sheet','MedianEach10')

resultMeanEach5Table=cell2table([result1 resultMeanEach5]);
writetable(resultMeanEach5Table,'lineByLineFront.xlsx','Sheet','MeanEach5')
resultMaxEach5Table=cell2table([result1 resultMaxEach5]);
writetable(resultMaxEach5Table,'lineByLineFront.xlsx','Sheet','MaxEach5')
resultMedianEach5Table=cell2table([result1 resultMedianEach5]);
writetable(resultMedianEach5Table,'lineByLineFront.xlsx','Sheet','MedianEach5')





