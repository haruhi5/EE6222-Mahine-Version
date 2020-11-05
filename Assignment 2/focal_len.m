%% Focal Length
% EE6222 Wu Tanghong
% 1 inch = 2.54 cm
format long g;
file = [ "C:\Users\Misaka\Desktop\DSC_0143.JPG"]; % 之前那个的压了画质算的不对
img_file = file(1);
img_info = imfinfo(img_file);
img_info
imshow(img_file);
impixelinfo;
[x,y] = ginput(2); % [x,y] = ginput(n) 可用于标识 n 个点的坐标。要选择一个点，请将光标移至所需位置，然后按下鼠标按键或键盘上的键。在选中全部 n 个点之前，按 Return 键可停止选择。
fprintf("Point 1: (%f,%f)\nPoint 2: (%f,%f)\n",x(1),y(1),x(2),y(2));

pixel_len = 25.4/img_info.XResolution % mm 这个应该是实际图像的像素大小
img_info.Width*pixel_len % mm 式子是对的 但是？？？
%pixel_len = 1.22e-3 % mm 这个应该是传感器的像素间距

object_len = 15 % cm
object_projlen = 4.5 % cm
dist_PhoneToObject = 50 % cm

f = abs(x(2)-x(1))/15*50 % pixel
f_real = 4.4/1.22*1e3 % mm