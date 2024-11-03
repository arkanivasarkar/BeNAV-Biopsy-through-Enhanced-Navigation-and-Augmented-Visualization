function rotateAxis(app)

if isMouse_over_axes(app.UIFigure, app.UIAxes2D)

    app.UIFigure.Pointer = 'hand';

    [oaz, oel] = view(app.UIAxes2D);
    mouse_position_initial = get(0,'PointerLocation');    % get starting point

    app.UIFigure.WindowButtonMotionFcn = [];
    app.UIFigure.WindowButtonMotionFcn = {@startRotationCallback, app, oaz, oel, mouse_position_initial};
    app.UIFigure.WindowButtonUpFcn =[];    
    app.UIFigure.WindowButtonUpFcn = {@endRotationCallback, app};
end



    function startRotationCallback(~, ~, app, oaz, oel, mouse_position_initial)

        % get mouse location
        mouse_position_final = get(0, 'PointerLocation');
        
        dx = mouse_position_final(1) - mouse_position_initial(1);           % calculate difference x
        dy = mouse_position_final(2) - mouse_position_initial(2);           % calculate difference y
        factor = 10;                         % correction mouse -> rotation
        newaz = oaz-dx/factor;              % calculate new azimuth
        newel = oel-dy/factor;              % calculate new elevation
        % 
        % newaz = -dx/factor;              % calculate new azimuth
        % newel = -dy/factor;             % calculate new elevation
        % 
        % camorbit(app.UIAxes2D, newaz,newel, 'camera')
        view(app.UIAxes2D, newaz,newel);               % adjust view
     

        app.var.current_light = camlight(app.var.current_light,'headlight');
    end


    function endRotationCallback(~, ~, app)
        
        %reset
        app.UIFigure.Pointer = 'arrow';
        app.UIFigure.WindowButtonMotionFcn = [];
        app.UIFigure.WindowButtonUpFcn = [];

    end

end