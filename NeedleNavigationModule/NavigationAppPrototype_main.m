classdef NavigationAppPrototype_main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        Image                     matlab.ui.control.Image
        BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel  matlab.ui.control.Label
        GridLayout2               matlab.ui.container.GridLayout
        appIntro                  matlab.ui.control.Label
        needlePathShortestButton  matlab.ui.control.Button
        needlePathManualButton    matlab.ui.control.Button
        NeedlePathAutoButton      matlab.ui.control.Button
        ChooseNeedlePathDetectionMethodLabel  matlab.ui.control.Label
        NeedleSelectionDropDown   matlab.ui.control.DropDown
        ChooseNeedleTypeLabel     matlab.ui.control.Label
        Tree                      matlab.ui.container.CheckBoxTree
        BreastNode                matlab.ui.container.TreeNode
        TumorNode                 matlab.ui.container.TreeNode
        Model3D                   matlab.ui.control.Label
        ImageDetailsText          matlab.ui.control.Label
        ImageDetails              matlab.ui.control.Label
        ControlButton             matlab.ui.control.Button
        ImageSlider               matlab.ui.control.Slider
        Label                     matlab.ui.control.Label
        mainAppLabel              matlab.ui.control.Label
        UIAxes2D                  matlab.ui.control.UIAxes
    end


    properties (Access = private)
    end

    properties (Access = public)
        var % Description
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)

            % Initialize variables
            app.var.current_light = [];
            app.var.needleDisplayHandle.Visible  = isgraphics(1,1);

            % Hardcoded variables
            app.var.tumor_stl_path = '.\Healthcare Hackathon Bayern\STL\Tumour.stl';
            app.var.breast_stl_path = '.\Healthcare Hackathon Bayern\STL\Breast_unsmoothened.stl';
            app.var.needle_22mm_path = '.\Healthcare Hackathon Bayern\STL\22mm Biopsy Instrument.stl';
            app.var.needle_20mm_path = '.\Healthcare Hackathon Bayern\STL\20mm Biopsy Instrument.stl';
            soundAlert_path = '\Healthcare Hackathon Bayern\MIsc\audioFeedback.wav';
            [app.var.alert1, app.var.alert2] = audioread(soundAlert_path);

            app.Image.ImageSource = ".\Healthcare Hackathon Bayern\logo.png";
            app.UIFigure.Name = 'BeNAV - Prototype';
            app.UIFigure.Icon =  ".\Healthcare Hackathon Bayern\logo.png";


        end

        % Button pushed function: ControlButton
        function ControlButtonPushed(app, event)

            switch app.ControlButton.Text

                case '▶  Start'
                    selpath = uigetdir('Select DICOM Folder');
                    if isequal(selpath,0)
                        return
                    end
                    figure(app.UIFigure)
                    filepath = dir(selpath);


                    for i=3:length(filepath)
                        fullfilepath = fullfile(selpath, filepath(i).name);
                        info = dicominfo(fullfilepath);
                        if i == 3
                            app.var.sliceThickness = info.SliceThickness;
                            app.var.px_size = info.PixelSpacing;
                            app.var.rows = info.Rows;
                            app.var.cols = info.Columns;
                            app.var.ImageOrientationPatient = info.ImageOrientationPatient;
                            app.var.ImagePositionPatient = zeros(3,length(filepath)-2);
                            app.var.image = zeros(app.var.cols, app.var.rows, length(filepath)-2);
                        end
                        app.var.image(:,:,i-2) = dicomread(fullfilepath);
                        app.var.ImagePositionPatient(:,i-2) = info.ImagePositionPatient;
                    end

                    app.ImageSlider.Limits = [1 length(filepath)-2];
                    app.ImageSlider.Value = round(length(filepath)/2);
                    app.var.imageHandle = imshow(app.var.image(:,:,app.ImageSlider.Value), [], 'Parent', app.UIAxes2D);
                    axis(app.UIAxes2D, 'tight')


                    app.ImageDetailsText.Text = sprintf('\tImage Size: \t\t%s\n\n\tImage Frames: \t\t%s\n\n\tPixel Size: \t\t%smm\n\n\tSlice Thickness: \t%smm\n\n\tOrientation: \t%s',...
                        [num2str(app.var.rows),' x ',num2str(app.var.cols)],...
                        num2str(length(filepath)-2),...
                        num2str(app.var.px_size(1)),...
                        num2str(app.var.sliceThickness),...
                        'Sagittal');
                    app.appIntro.Visible = 'off';
                    app.mainAppLabel.Visible = 'off';
                    app.Image.Visible = 'off';
                    app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.Visible = 'off';
                    app.ImageSlider.Visible = 'on';
                    app.UIAxes2D.Visible = 'on';
                    app.ImageDetails.Visible = 'on';
                    app.ControlButton.Text = 'Segment & Generate 3D';
                    drawnow

                    [app.var.image_volume_x,app.var.image_volume_y,app.var.image_volume_z, app.var.image_volume_centroids] = image2PatientCoords(app);



                case 'Segment & Generate 3D'

                    
                    app.ImageDetails.Visible = 'off';
                    app.ImageDetailsText.Visible = 'off';
                    app.NeedleSelectionDropDown.Visible = 'on';
                    app.ChooseNeedleTypeLabel.Visible = 'on';

                    app.Model3D.Visible = 'on';
                    app.Tree.Visible = 'on';

                    app.ImageSlider.Visible = 'off';
                    app.UIAxes2D.Visible = 'off';
                    cla(app.UIAxes2D);
                    app.ControlButton.Text = 'Switch to AR';
                    drawnow

                    tumor_stl_path =  app.var.tumor_stl_path;
                    breast_stl_path =  app.var.breast_stl_path;

                    TR = stlread(tumor_stl_path);
                    app.var.threeD_tumor.vertices = TR.Points;
                    app.var.threeD_tumor.faces = TR.ConnectivityList;
                    TR = stlread(breast_stl_path);
                    app.var.threeD_breast.vertices = TR.Points;
                    app.var.threeD_breast.faces = TR.ConnectivityList;


                    app.var.breastDisplayHandle = patch('Parent',app.UIAxes2D, ...
                        'Faces',app.var.threeD_breast.faces, ...
                        'Vertices', app.var.threeD_breast.vertices, ...
                        'FaceAlpha',0.6,...
                        'Facecolor',[0.85,0.85,0.85],...
                        'Edgecolor','none', ...
                        'FaceLighting','gouraud', ...
                        'AmbientStrength',0.05, ...
                        'DiffuseStrength',0.8, ...
                        'SpecularStrength',0, ...
                        'SpecularExponent',10, ...
                        'SpecularColorReflectance',1);

                    app.var.tumourDisplayHandle = patch('Parent',app.UIAxes2D, ...
                        'Faces',app.var.threeD_tumor.faces, ...
                        'Vertices', app.var.threeD_tumor.vertices,...
                        'FaceAlpha',0.4,...
                        'Facecolor',[1,0,0],...
                        'Edgecolor','none', ...
                        'FaceLighting','gouraud', ...
                        'AmbientStrength',0.05, ...
                        'DiffuseStrength',0.8, ...
                        'SpecularStrength',0, ...
                        'SpecularExponent',10, ...
                        'SpecularColorReflectance',1);

                    view(app.UIAxes2D, 180,0);
                    if isempty(app.var.current_light)
                        app.var.current_light = camlight(app.UIAxes2D,'headlight');
                        set(app.var.current_light,'style','infinite');
                        drawnow
                    end


                    app.Tree.CheckedNodes = app.Tree.Children(1);
                    app.Tree.CheckedNodes(end+1) = app.Tree.Children(2);
                    drawnow



                case 'Switch to AR'
                    cla(app.UIAxes2D);
                    tumor_stl_path =  app.var.tumor_stl_path;
                    breast_stl_path =  app.var.breast_stl_path;

                    TR = stlread(tumor_stl_path);
                    app.var.threeD_tumor.vertices = TR.Points;
                    app.var.threeD_tumor.faces = TR.ConnectivityList;
                    TR = stlread(breast_stl_path);
                    app.var.threeD_breast.vertices = TR.Points;
                    app.var.threeD_breast.faces = TR.ConnectivityList;

                    app.var.breastDisplayHandle = patch('Parent',app.UIAxes2D, ...
                        'Faces',app.var.threeD_breast.faces, ...
                        'Vertices', app.var.threeD_breast.vertices, ...
                        'FaceAlpha',1,...
                        'Facecolor',[0.85,0.85,0.85],...
                        'Edgecolor','none', ...
                        'FaceLighting','gouraud', ...
                        'AmbientStrength',0.05, ...
                        'DiffuseStrength',0.8, ...
                        'SpecularStrength',0, ...
                        'SpecularExponent',10, ...
                        'SpecularColorReflectance',1);

                    app.var.tumourDisplayHandle = patch('Parent',app.UIAxes2D, ...
                        'Faces',app.var.threeD_tumor.faces, ...
                        'Vertices', app.var.threeD_tumor.vertices,...
                        'FaceAlpha',1,...
                        'Facecolor',[1,0,0],...
                        'Edgecolor','none', ...
                        'FaceLighting','gouraud', ...
                        'AmbientStrength',0.05, ...
                        'DiffuseStrength',0.8, ...
                        'SpecularStrength',0, ...
                        'SpecularExponent',10, ...
                        'SpecularColorReflectance',1);

                    view(app.UIAxes2D, 180,0);
                    app.var.current_light = [];
                    if isempty(app.var.current_light)
                        app.var.current_light = camlight(app.UIAxes2D,'headlight');
                        set(app.var.current_light,'style','infinite');
                        drawnow
                    end

                    app.UIAxes2D.Layout.Column = [1 16];
                    app.GridLayout2.Visible = 'off';
                    drawnow
            end
        end

        % Value changed function: ImageSlider
        function ImageSliderValueChanged(app, event)
            value = round(app.ImageSlider.Value);

            app.var.imageHandle.CData = app.var.image(:,:,value);
            drawnow
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            rotateAxis(app)
        end

        % Clicked callback: Tree
        function TreeClicked(app, event)
            node = event.InteractionInformation.Node;

            switch node.Text
                case 'Tumor'
                    if strcmpi(app.var.tumourDisplayHandle.Visible,'on')
                        app.var.tumourDisplayHandle.Visible = 'off';
                    else
                        app.var.tumourDisplayHandle.Visible = 'on';
                    end
                case 'Breast'
                    if strcmpi(app.var.breastDisplayHandle.Visible,'on')
                        app.var.breastDisplayHandle.Visible = 'off';
                    else
                        app.var.breastDisplayHandle.Visible = 'on';
                    end
                case 'Needle'
                    if strcmpi(app.var.needleDisplayHandle.Visible,'on')
                        app.var.needleDisplayHandle.Visible = 'off';
                    else
                        app.var.needleDisplayHandle.Visible = 'on';
                    end
            end

        end

        % Value changed function: NeedleSelectionDropDown
        function NeedleSelectionDropDownValueChanged(app, event)
            switch app.NeedleSelectionDropDown.Value
                case 'BARD 22mm'
                    TR = stlread(app.var.needle_22mm_path);
                    app.var.needle_top_point_reference = [-7.712, 96.93, -0.1016];
                    app.var.needleStartPoint = [-7.653, 110.4, -0.4744];
                    app.var.needleEndPoint = [-7.648, 9.252, -0.0489];
                    app.var.needleAxisDirection = [0,0,0];

                case 'Custom 20mm'
                    TR = stlread(app.var.needle_20mm_path);
                    app.var.needle_top_point_reference = [-7.712, 96.93, -0.1016];
                    app.var.needleStartPoint = [-7.687, 109, -0.5234];
                    app.var.needleEndPoint = [-7.657, 9.52, -0.0605];
                    app.var.needleAxisDirection = [0,0,0];

                case 'None'
                    return
            end

            app.needlePathManualButton.Visible = 'on';
            app.needlePathShortestButton.Visible = 'on';
            app.NeedlePathAutoButton.Visible = 'on';
            app.ChooseNeedlePathDetectionMethodLabel.Visible = 'on';

            app.var.threeD_needle.vertices = TR.Points;
            app.var.threeD_needle.faces = TR.ConnectivityList;

            app.var.needleDisplayHandle = patch('Parent',app.UIAxes2D, ...
                'Faces',app.var.threeD_needle.faces, ...
                'Vertices', app.var.threeD_needle.vertices, ...
                'FaceAlpha',1,...
                'Facecolor',[0,1,0],...
                'Edgecolor','none', ...
                'FaceLighting','gouraud', ...
                'AmbientStrength',0.05, ...
                'DiffuseStrength',0.8, ...
                'SpecularStrength',0, ...
                'SpecularExponent',10, ...
                'SpecularColorReflectance',1);



            if length(app.Tree.Children) == 3
                if strcmpi(app.var.needleDisplayHandle.Visible,'on')
                    app.var.needleDisplayHandle.Visible = 'off';
                end
                delete(app.Tree.Children(3));
            end

            needleNode = uitreenode(app.Tree,"Text","Needle");
            app.Tree.CheckedNodes(end+1) = needleNode;






        end

        % Button pushed function: NeedlePathAutoButton, 
        % ...and 2 other components
        function NeedlePathButtonPushed(app, event)
            switch event.Source.Text
                case 'Auto'

                    TR = stlread(app.var.needle_22mm_path);

                    tumor_centroid = mean(app.var.threeD_tumor.vertices);
                    dist = (app.var.threeD_breast.vertices(:,1)-tumor_centroid(1)).^2 +  (app.var.threeD_breast.vertices(:,2)-tumor_centroid(2)).^2 +  (app.var.threeD_breast.vertices(:,3)-tumor_centroid(3)).^2;
                    [~,idx] = min(dist);
                    closest_breast_point = app.var.threeD_breast.vertices(idx,:);
                    reference_vec = tumor_centroid - closest_breast_point;
                    reference_vec = reference_vec/norm(reference_vec);


                    query_points = [app.var.image_volume_x(:),app.var.image_volume_y(:),app.var.image_volume_z(:)];
                    query_intensity = pagetranspose(app.var.image);
                    query_intensity = query_intensity(:);
                    intensity_tolerance = 10000000;

                    d = uiprogressdlg(app.UIFigure,'Title','Calculating Path Automatically',...
                        'Message','Please wait...');
                    for i = 1:length(app.var.threeD_breast.vertices)
                        vec = tumor_centroid - app.var.threeD_breast.vertices(i,:);
                        vec_mag = norm(vec);
                        vec = vec/vec_mag;
                        if dot(vec, reference_vec) <= 0
                            continue
                        elseif vec_mag < 22
                            continue
                        end

                        rotation_axis = cross(needle_mesh_vector, reference_vec);
                        rotation_angle = acosd(dot(needle_mesh_vector, reference_vec));

                        new_vertices = rotateMesh(TR.Points, rotation_axis, rotation_angle, app.var.needleStartPoint);

                        closest_point_on_tumour = ray_triangle_intersection(app.var.threeD_tumor.faces, app.var.threeD_tumor.vertices, tumor_centroid, -vec);
                        vec = closest_point_on_tumour - needleStartPoint;
                        new_vertices = new_vertices +  vec;

                        d.Value = i/length(app.var.threeD_breast.vertices);

                        fv.faces = TR.ConnectivityList;
                        fv.vertices = new_vertices;
                        IN = inpolyhedron(fv, query_points);

                        if nnz(IN) < 2
                            continue
                        end

                        intensity = query_intensity(IN);
                        sum_intensity = sum(intensity, "All");

                        if sum_intensity<intensity_tolerance
                            intensity_tolerance = sum_intensity;
                            best_position = new_vertices;
                        end

                    end

                    close(d)


                    app.var.needleDisplayHandle.Vertices =  best_position;
                    drawnow



                case 'Manual'
                    % add code to select incision site and find best path around the
                    % site

                case 'Shortest Path'
                    tumor_centroid = mean(app.var.threeD_tumor.vertices);

                    %move needle
                    dist = (app.var.threeD_breast.vertices(:,1)-tumor_centroid(1)).^2 +  (app.var.threeD_breast.vertices(:,2)-tumor_centroid(2)).^2 +  (app.var.threeD_breast.vertices(:,3)-tumor_centroid(3)).^2;
                    [~,idx] = min(dist);

                    closest_breast_point = app.var.threeD_breast.vertices(idx,:);
                    needle_direction_vector = tumor_centroid - closest_breast_point;
                    needle_direction_vector = needle_direction_vector/norm(needle_direction_vector);

                    needle_mesh_vector = app.var.needleStartPoint - app.var.needleEndPoint;
                    needle_mesh_vector = needle_mesh_vector/norm(needle_mesh_vector);

                    rotation_axis = cross(needle_mesh_vector, needle_direction_vector);
                    rotation_angle = acosd(dot(needle_mesh_vector, needle_direction_vector));

                    app.var.threeD_needle.vertices = rotateMesh(app.var.threeD_needle.vertices, rotation_axis, rotation_angle, app.var.needleStartPoint);
                    vec = closest_breast_point - app.var.needleStartPoint;
                    app.var.threeD_needle.vertices = app.var.threeD_needle.vertices +  vec;
                    app.var.needleDisplayHandle.Vertices =  app.var.threeD_needle.vertices;


                    app.var.needle_top_point_reference = rotateMesh(app.var.needle_top_point_reference, rotation_axis, rotation_angle, app.var.needleStartPoint);
                    app.var.needle_top_point_reference = app.var.needle_top_point_reference+vec;
                    drawnow

                    app.var.needleAxisDirection = closest_breast_point - mean(app.var.threeD_needle.vertices);
                    app.var.needleAxisDirection = app.var.needleAxisDirection/norm(app.var.needleAxisDirection);


            end
        end

        % Window key press function: UIFigure
        function UIFigureWindowKeyPress(app, event)
            key = event.Key;
            switch key
                case 'leftarrow'
                    tumor_centroid = mean(app.var.threeD_tumor.vertices);
                    intersectionPoint = ray_triangle_intersection(app.var.threeD_tumor.faces, app.var.threeD_tumor.vertices, tumor_centroid, app.var.needleAxisDirection);

                    vertices = app.var.threeD_needle.vertices -  app.var.needleAxisDirection*1;
                    needle_top_point_reference = app.var.needle_top_point_reference -  app.var.needleAxisDirection*1;

                    dir1 = tumor_centroid - intersectionPoint;
                    dir1 = dir1/norm(dir1);
                    dir2 = app.var.needle_top_point_reference - intersectionPoint;
                    dir2 = dir2/norm(dir2);

                    if dot(dir1,dir2) < 0
                        sound(app.var.alert1, app.var.alert2);
                    else
                        app.var.needle_top_point_reference = needle_top_point_reference;
                        app.var.threeD_needle.vertices = vertices;
                        app.var.needleDisplayHandle.Vertices =  app.var.threeD_needle.vertices;
                        drawnow
                    end




                case 'rightarrow'

                    tumor_centroid = mean(app.var.threeD_tumor.vertices);
                    intersectionPoint = ray_triangle_intersection(app.var.threeD_tumor.faces, app.var.threeD_tumor.vertices, tumor_centroid, app.var.needleAxisDirection);

                    vertices = app.var.threeD_needle.vertices +  app.var.needleAxisDirection*1;
                    needle_top_point_reference = app.var.needle_top_point_reference +  app.var.needleAxisDirection*1;

                    dir1 = tumor_centroid - intersectionPoint;
                    dir1 = dir1/norm(dir1);
                    dir2 = app.var.needle_top_point_reference - intersectionPoint;
                    dir2 = dir2/norm(dir2);

                    if dot(dir1,dir2) < 0
                        sound(app.var.alert1, app.var.alert2);
                        uialert(app.UIFigure, "Reached optimum needle position.","Navigation Stopped");
                        vertices = app.var.threeD_needle.vertices -  app.var.needleAxisDirection*1;
                        needle_top_point_reference = app.var.needle_top_point_reference -  app.var.needleAxisDirection*1;
                        app.var.needle_top_point_reference = needle_top_point_reference;
                        app.var.threeD_needle.vertices = vertices;
                        app.var.needleDisplayHandle.Vertices =  app.var.threeD_needle.vertices;
                        drawnow
                    else
                        app.var.needle_top_point_reference = needle_top_point_reference;
                        app.var.threeD_needle.vertices = vertices;
                        app.var.needleDisplayHandle.Vertices =  app.var.threeD_needle.vertices;
                        drawnow
                    end
                    plot3(app.UIAxes2D,intersectionPoint(1),intersectionPoint(2),intersectionPoint(3),'go','MarkerSize',3)
                    text(app.UIAxes2D,2+intersectionPoint(1),2+intersectionPoint(2),2+intersectionPoint(3),'Needle Exit Point','Color',[1,0,0], 'FontSize',12, 'FontWeight','bold')


            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @UIFigureWindowKeyPress, true);
            app.UIFigure.WindowState = 'maximized';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [2 2 2 2];
            app.GridLayout.BackgroundColor = [0.149 0.149 0.149];

            % Create UIAxes2D
            app.UIAxes2D = uiaxes(app.GridLayout);
            app.UIAxes2D.Toolbar.Visible = 'off';
            app.UIAxes2D.GridLineStyle = 'none';
            app.UIAxes2D.XTickLabel = '';
            app.UIAxes2D.YTickLabel = '';
            app.UIAxes2D.Color = 'none';
            app.UIAxes2D.NextPlot = 'add';
            app.UIAxes2D.Layout.Row = [1 16];
            app.UIAxes2D.Layout.Column = [1 12];
            app.UIAxes2D.Visible = 'off';

            % Create mainAppLabel
            app.mainAppLabel = uilabel(app.GridLayout);
            app.mainAppLabel.HorizontalAlignment = 'center';
            app.mainAppLabel.FontSize = 48;
            app.mainAppLabel.FontWeight = 'bold';
            app.mainAppLabel.FontColor = [0.0745 0.6235 1];
            app.mainAppLabel.Layout.Row = [11 12];
            app.mainAppLabel.Layout.Column = [3 11];
            app.mainAppLabel.Text = 'BeNAV';

            % Create Label
            app.Label = uilabel(app.GridLayout);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Layout.Row = 16;
            app.Label.Layout.Column = 13;
            app.Label.Text = '';

            % Create ImageSlider
            app.ImageSlider = uislider(app.GridLayout);
            app.ImageSlider.MajorTicks = [];
            app.ImageSlider.MajorTickLabels = {''};
            app.ImageSlider.Orientation = 'vertical';
            app.ImageSlider.ValueChangedFcn = createCallbackFcn(app, @ImageSliderValueChanged, true);
            app.ImageSlider.Visible = 'off';
            app.ImageSlider.Layout.Row = [1 16];
            app.ImageSlider.Layout.Column = 13;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.ColumnSpacing = 0;
            app.GridLayout2.RowSpacing = 0;
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = [1 16];
            app.GridLayout2.Layout.Column = [14 16];
            app.GridLayout2.BackgroundColor = [0 0 0];

            % Create ControlButton
            app.ControlButton = uibutton(app.GridLayout2, 'push');
            app.ControlButton.ButtonPushedFcn = createCallbackFcn(app, @ControlButtonPushed, true);
            app.ControlButton.BackgroundColor = [0.149 0.149 0.149];
            app.ControlButton.FontSize = 18;
            app.ControlButton.FontWeight = 'bold';
            app.ControlButton.FontColor = [0.302 0.749 0.9294];
            app.ControlButton.Layout.Row = 12;
            app.ControlButton.Layout.Column = [1 4];
            app.ControlButton.Text = '▶  Start';

            % Create ImageDetails
            app.ImageDetails = uilabel(app.GridLayout2);
            app.ImageDetails.HorizontalAlignment = 'center';
            app.ImageDetails.FontSize = 14;
            app.ImageDetails.FontWeight = 'bold';
            app.ImageDetails.FontColor = [0.0745 0.6235 1];
            app.ImageDetails.Visible = 'off';
            app.ImageDetails.Layout.Row = 1;
            app.ImageDetails.Layout.Column = [1 4];
            app.ImageDetails.Text = 'Image Details';

            % Create ImageDetailsText
            app.ImageDetailsText = uilabel(app.GridLayout2);
            app.ImageDetailsText.VerticalAlignment = 'top';
            app.ImageDetailsText.FontColor = [0.302 0.7451 0.9333];
            app.ImageDetailsText.Layout.Row = [2 7];
            app.ImageDetailsText.Layout.Column = [1 4];
            app.ImageDetailsText.Text = '';

            % Create Model3D
            app.Model3D = uilabel(app.GridLayout2);
            app.Model3D.HorizontalAlignment = 'center';
            app.Model3D.FontSize = 14;
            app.Model3D.FontWeight = 'bold';
            app.Model3D.FontColor = [0.0745 0.6235 1];
            app.Model3D.Visible = 'off';
            app.Model3D.Layout.Row = 1;
            app.Model3D.Layout.Column = [1 4];
            app.Model3D.Text = '3D Models';

            % Create Tree
            app.Tree = uitree(app.GridLayout2, 'checkbox');
            app.Tree.Visible = 'off';
            app.Tree.FontSize = 14;
            app.Tree.FontColor = [0.302 0.749 0.9294];
            app.Tree.BackgroundColor = [0 0 0];
            app.Tree.Layout.Row = [2 3];
            app.Tree.Layout.Column = [1 4];
            app.Tree.ClickedFcn = createCallbackFcn(app, @TreeClicked, true);

            % Create BreastNode
            app.BreastNode = uitreenode(app.Tree);
            app.BreastNode.NodeData = 1;
            app.BreastNode.Text = 'Breast';

            % Create TumorNode
            app.TumorNode = uitreenode(app.Tree);
            app.TumorNode.NodeData = 1;
            app.TumorNode.Text = 'Tumor';

            % Create ChooseNeedleTypeLabel
            app.ChooseNeedleTypeLabel = uilabel(app.GridLayout2);
            app.ChooseNeedleTypeLabel.HorizontalAlignment = 'center';
            app.ChooseNeedleTypeLabel.WordWrap = 'on';
            app.ChooseNeedleTypeLabel.FontSize = 14;
            app.ChooseNeedleTypeLabel.FontWeight = 'bold';
            app.ChooseNeedleTypeLabel.FontColor = [0.0745 0.6235 1];
            app.ChooseNeedleTypeLabel.Visible = 'off';
            app.ChooseNeedleTypeLabel.Layout.Row = 5;
            app.ChooseNeedleTypeLabel.Layout.Column = [1 4];
            app.ChooseNeedleTypeLabel.Text = 'Choose Needle Type';

            % Create NeedleSelectionDropDown
            app.NeedleSelectionDropDown = uidropdown(app.GridLayout2);
            app.NeedleSelectionDropDown.Items = {'None', 'BARD 22mm', 'Custom 20mm'};
            app.NeedleSelectionDropDown.ValueChangedFcn = createCallbackFcn(app, @NeedleSelectionDropDownValueChanged, true);
            app.NeedleSelectionDropDown.Visible = 'off';
            app.NeedleSelectionDropDown.FontColor = [0.302 0.7451 0.9333];
            app.NeedleSelectionDropDown.BackgroundColor = [0 0 0];
            app.NeedleSelectionDropDown.Layout.Row = 6;
            app.NeedleSelectionDropDown.Layout.Column = [1 4];
            app.NeedleSelectionDropDown.Value = 'None';

            % Create ChooseNeedlePathDetectionMethodLabel
            app.ChooseNeedlePathDetectionMethodLabel = uilabel(app.GridLayout2);
            app.ChooseNeedlePathDetectionMethodLabel.HorizontalAlignment = 'center';
            app.ChooseNeedlePathDetectionMethodLabel.WordWrap = 'on';
            app.ChooseNeedlePathDetectionMethodLabel.FontSize = 14;
            app.ChooseNeedlePathDetectionMethodLabel.FontWeight = 'bold';
            app.ChooseNeedlePathDetectionMethodLabel.FontColor = [0.0745 0.6235 1];
            app.ChooseNeedlePathDetectionMethodLabel.Visible = 'off';
            app.ChooseNeedlePathDetectionMethodLabel.Layout.Row = 8;
            app.ChooseNeedlePathDetectionMethodLabel.Layout.Column = [1 4];
            app.ChooseNeedlePathDetectionMethodLabel.Text = 'Choose Needle Path Detection Method';

            % Create NeedlePathAutoButton
            app.NeedlePathAutoButton = uibutton(app.GridLayout2, 'push');
            app.NeedlePathAutoButton.ButtonPushedFcn = createCallbackFcn(app, @NeedlePathButtonPushed, true);
            app.NeedlePathAutoButton.BackgroundColor = [0 0 0];
            app.NeedlePathAutoButton.FontColor = [0.302 0.7451 0.9333];
            app.NeedlePathAutoButton.Visible = 'off';
            app.NeedlePathAutoButton.Layout.Row = 9;
            app.NeedlePathAutoButton.Layout.Column = [1 2];
            app.NeedlePathAutoButton.Text = 'Auto';

            % Create needlePathManualButton
            app.needlePathManualButton = uibutton(app.GridLayout2, 'push');
            app.needlePathManualButton.ButtonPushedFcn = createCallbackFcn(app, @NeedlePathButtonPushed, true);
            app.needlePathManualButton.BackgroundColor = [0 0 0];
            app.needlePathManualButton.FontColor = [0.302 0.7451 0.9333];
            app.needlePathManualButton.Visible = 'off';
            app.needlePathManualButton.Layout.Row = 9;
            app.needlePathManualButton.Layout.Column = [3 4];
            app.needlePathManualButton.Text = 'Manual';

            % Create needlePathShortestButton
            app.needlePathShortestButton = uibutton(app.GridLayout2, 'push');
            app.needlePathShortestButton.ButtonPushedFcn = createCallbackFcn(app, @NeedlePathButtonPushed, true);
            app.needlePathShortestButton.BackgroundColor = [0 0 0];
            app.needlePathShortestButton.FontSize = 14;
            app.needlePathShortestButton.FontColor = [0.302 0.7451 0.9333];
            app.needlePathShortestButton.Visible = 'off';
            app.needlePathShortestButton.Layout.Row = 10;
            app.needlePathShortestButton.Layout.Column = [1 4];
            app.needlePathShortestButton.Text = 'Shortest Path';

            % Create appIntro
            app.appIntro = uilabel(app.GridLayout2);
            app.appIntro.HorizontalAlignment = 'center';
            app.appIntro.VerticalAlignment = 'top';
            app.appIntro.WordWrap = 'on';
            app.appIntro.FontWeight = 'bold';
            app.appIntro.FontColor = [0.302 0.749 0.9294];
            app.appIntro.Layout.Row = [2 7];
            app.appIntro.Layout.Column = [1 4];
            app.appIntro.Text = {'A module for breast biopsy needle guidance.'; ''; ' '; ''; 'Three modes-'; ''; '● ''Auto'' for automatically calculate needle path based on underlying tissue properties.'; ''; '● ''Manual'' for determining incision site and find best path aound it.'; ''; '● ''Shortest'' to find shortest path to reach the tumor/lesion.'; ''; ''; ''; 'With auditory/visual feedback to let user know that the needle has reached the optimum position and should not proceed more.'};

            % Create BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel = uilabel(app.GridLayout);
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.HorizontalAlignment = 'center';
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.VerticalAlignment = 'top';
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.FontSize = 14;
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.FontColor = [0.302 0.7451 0.9333];
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.Layout.Row = 14;
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.Layout.Column = [4 10];
            app.BiopsyEnhancedthroughNavigationandAugmentedVisualizationLabel.Text = 'Biopsy Enhanced through Navigation and Augmented Visualization';

            % Create Image
            app.Image = uiimage(app.GridLayout);
            app.Image.Layout.Row = [2 9];
            app.Image.Layout.Column = [4 10];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NavigationAppPrototype_main

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end