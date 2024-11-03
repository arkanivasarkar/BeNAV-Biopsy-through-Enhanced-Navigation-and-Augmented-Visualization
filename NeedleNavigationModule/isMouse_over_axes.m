function flag = isMouse_over_axes(handle, axes)


if all([handle.CurrentPoint(1) >= axes.Position(1),...
        handle.CurrentPoint(1) <=  axes.Position(1) + axes.Position(3),...
        handle.CurrentPoint(2) >= axes.Position(2),...
        handle.CurrentPoint(2) <=  axes.Position(2) + axes.Position(4)])
    flag = true;
else
    flag = false;
end