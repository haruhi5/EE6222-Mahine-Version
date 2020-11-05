%% 
format long g;
file = [ "C:\Users\Misaka\Desktop\DSC_0146(0°).jpg", ...
         "C:\Users\Misaka\Desktop\DSC_0147(6°).jpg"]; % 之前那个的压了画质算的不对
Im1 = imread(file(1));
Im2 = imread(file(2));
%impixelinfo;
f = 3960;
%%
I1 = rgb2gray(Im1);
I2 = rgb2gray(Im2);
% Find the corners. https://ww2.mathworks.cn/help/vision/ref/matchfeatures.html#btatw3a
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);
%Extract the neighborhood features.
[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);
%Match the features.
indexPairs = matchFeatures(features1,features2);
%Retrieve the locations of the corresponding points for each image.
matchedPoints1 = valid_points1(indexPairs(2:10,1),:);
matchedPoints2 = valid_points2(indexPairs(2:10,2),:);

%%
% Show the putatively matched points. https://ww2.mathworks.cn/help/vision/ref/estimatefundamentalmatrix.html#btcx8i7
figure;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage','PlotOptions',{'ro','go','y--'});
title('Putative point matches');
set (gca,'position',[0.01,0.01,0.98,0.98] );
%Show the inlier points.
% [fLMedS, inliers] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'NumTrials',2000)
% matchedPoints1 = valid_points1(indexPairs(:,1),:);
% matchedPoints2 = valid_points2(indexPairs(:,2),:);
% figure;
% showMatchedFeatures(I1, I2, matchedPoints1(inliers,:),matchedPoints2(inliers,:),'montage','PlotOptions',{'ro','go','y--'});
% title('Point matches after outliers were removed');
%% 

%% 
[row,col] = size(matchedPoints1);
mpoints1 = [matchedPoints1.Location ones(row,1)*f];
mpoints2 = [matchedPoints2.Location ones(row,1)*f];

Nvecx = mpoints1./sqrt(sum(mpoints1'.^2))'; % sum的方向
Nvecp = mpoints2./sqrt(sum(mpoints2'.^2))';
ux=0;uy=0;uz=0;
for i=1:row
    ux=ux+Nvecx(i,1);
    uy=uy+Nvecx(i,2);
    uz=uz+Nvecx(i,3);
end
ux=ux/row;uy=uy/row;uz=uz/row;

upx=0;upy=0;upz=0;
for i=1:row
    upx=upx+Nvecp(i,1);
    upy=upy+Nvecp(i,2);
    upz=upz+Nvecp(i,3);
end
upx=upx/row;upy=upy/row;upz=upz/row;

x_prime = [mpoints1(:,1)-ux,mpoints1(:,2)-uy,mpoints1(:,3)-uz];
p_prime = [mpoints2(:,1)-upx,mpoints2(:,2)-upy,mpoints2(:,3)-upz];

W=zeros(3,3);
for i=1:row
    W=W+x_prime(i,:)'*p_prime(i,:);
end
[U,S,V]=svd(W);
R=U*V'
%t=ux-R*upx;
angle=acosd((trace(R)-1)/2)

%%
K=0;
for i=1:row
    K=K+mpoints1(i,:)'*mpoints2(i,:);
end
K_hat=zeros(4,4);
K_hat(1,1)=K(1,1)+K(2,2)+K(3,3);
K_hat(1,2)=K(3,2)-K(2,3);
K_hat(1,3)=K(1,3)-K(3,1);
K_hat(1,4)=K(2,1)-K(1,2);
K_hat(2,1)=K_hat(1,2);
K_hat(2,2)=K(1,1)-K(2,2)-K(3,3);
K_hat(2,3)=K(1,2)+K(2,1);
K_hat(2,4)=K(3,1)+K(1,3);
K_hat(3,1)=K_hat(1,3);
K_hat(3,2)=K_hat(2,3);
K_hat(3,3)=-K(1,1)+K(2,2)-K(3,3);
K_hat(3,4)=K(2,3)+K(3,2);
K_hat(4,1)=K_hat(1,4);
K_hat(4,2)=K_hat(2,4);
K_hat(4,3)=K_hat(3,4);
K_hat(4,4)=-K(1,1)-K(2,2)+K(3,3);
%K_hat
[x,y]=eig(K_hat);
q_hat=x(:,4)/sqrt(x(1,4)^2+x(2,4)^2+x(3,4)^2+x(4,4)^2);
angle2=acosd(q_hat(1))*2
R = [q_hat(1)^2+q_hat(2)^2-q_hat(3)^2-q_hat(4)^2 2*(q_hat(2)*q_hat(3)-q_hat(1)*q_hat(4)) 2*(q_hat(2)*q_hat(4)-q_hat(1)*q_hat(2));...
     2*(q_hat(3)*q_hat(2)-q_hat(1)*q_hat(4)) q_hat(1)^2-q_hat(2)^2+q_hat(3)^2-q_hat(4)^2 2*(q_hat(3)*q_hat(4)-q_hat(1)*q_hat(2));...
     2*(q_hat(2)*q_hat(4)-q_hat(1)*q_hat(1)) 2*(q_hat(3)*q_hat(4)-q_hat(1)*q_hat(2)) q_hat(1)^2-q_hat(2)^2-q_hat(3)^2+q_hat(4)^2]
angle=acosd((trace(R)-1)/2)