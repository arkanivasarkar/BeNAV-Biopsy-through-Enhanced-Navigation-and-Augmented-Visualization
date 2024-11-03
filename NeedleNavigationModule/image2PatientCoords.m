function [x,y,z,centroid] = image2PatientCoords(app)


%% Pre-settings
nimages =  size(app.var.image,3);
x = NaN(app.var.rows, app.var.cols, nimages,'single'); %pre-allocate x-coordinate matrix
y = NaN(app.var.rows, app.var.cols, nimages,'single'); %pre-allocate y-coordinate matrix
z = NaN(app.var.rows, app.var.cols, nimages,'single'); %pre-allocate z-coordinate matrix
centroid = NaN(3, nimages,'single');

%% Main code
row = 1:app.var.rows; % min and max row dimensions 
column = 1:app.var.cols; % min and max column dimension 

M = [app.var.ImageOrientationPatient(1:3) app.var.ImageOrientationPatient(4:6)]*app.var.px_size(1);
M = cat(2, M, zeros(3,1)); % transformation rotational matrix
ijk = [0, 0, 0, 1]';

for slice_num = 1:nimages
    M1 = cat(2, M, app.var.ImagePositionPatient(:,slice_num));
    M2 = cat(1, M1, [0 0 0 1]); % transformation rotational-translational matrix
    
    % transform coordinates
    for i = 1:length(row)
        for j = 1:length(column)
            ijk(1) = row(i)-1;
            ijk(2) = column(j)-1;

            coord = M2*ijk;

            x(i,j,slice_num) = coord(1); 
            y(i,j,slice_num) = coord(2);  
            z(i,j,slice_num) = coord(3);
        end
    end
    centroid(:,slice_num) = [mean(x(:,:,slice_num),'all'),mean(y(:,:,slice_num),'all'),mean(z(:,:,slice_num),'all')]';

end



