function intersectionPoint = ray_triangle_intersection(faces, vertices, ray_origin, ray_direction, varargin)



intersectionPoint = NaN(1,3);


vert0 = vertices(faces(:,1),:);
vert1 = vertices(faces(:,2),:);
vert2 = vertices(faces(:,3),:);


if (size(ray_origin ,1)==3 && size(ray_origin ,2)~=3), ray_origin =ray_origin' ; end
if (size(ray_direction  ,1)==3 && size(ray_direction  ,2)~=3), ray_direction  =ray_direction'  ; end
if (size(vert0,1)==3 && size(vert0,2)~=3), vert0=vert0'; end
if (size(vert1,1)==3 && size(vert1,2)~=3), vert1=vert1'; end
if (size(vert2,1)==3 && size(vert2,2)~=3), vert2=vert2'; end

N = max([size(ray_origin,1), size(ray_direction,1), size(vert0,1), size(vert1,1), size(vert2,1)]);
if (size(ray_origin ,1)==1 && N>1 && size(ray_origin ,2)==3), ray_origin  = repmat(ray_origin , N, 1); end
if (size(ray_direction  ,1)==1 && N>1 && size(ray_direction  ,2)==3), ray_direction   = repmat(ray_direction  , N, 1); end
if (size(vert0,1)==1 && N>1 && size(vert0,2)==3), vert0 = repmat(vert0, N, 1); end
if (size(vert1,1)==1 && N>1 && size(vert1,2)==3), vert1 = repmat(vert1, N, 1); end
if (size(vert2,1)==1 && N>1 && size(vert2,2)==3), vert2 = repmat(vert2, N, 1); end



%defaults
eps        = 1e-5;
planeType  = 'two sided';
lineType   = 'ray';
border     = 'normal';
fullReturn = false;
nVarargs   = length(varargin);
k = 1;
if nVarargs>0 && isstruct(varargin{1})
    options = varargin{1};
    if (isfield(options, 'eps'     )), eps      = options.eps;      end
    if (isfield(options, 'triangle')), planeType= options.triangle; end
    if (isfield(options, 'ray'     )), lineType = options.ray;      end
    if (isfield(options, 'border'  )), border   = options.border;   end
else
    while (k<=nVarargs)
        switch lower(varargin{k})
            case 'eps'
                eps = abs(varargin{k+1});
                k = k+1;
            case 'planetype'
                planeType = lower(strtrim(varargin{k+1}));
                k = k+1;
            case 'border'
                border = lower(strtrim(varargin{k+1}));
                k = k+1;
            case 'linetype'
                lineType = lower(strtrim(varargin{k+1}));
                k = k+1;
            case 'fullreturn'
                fullReturn = (double(varargin{k+1})~=0);
                k = k+1;
        end
        k = k+1;
    end
end

switch border
    case 'normal'
        zero=0.0;
    case 'inclusive'
        zero=eps;
    case 'exclusive'
        zero=-eps;

end

intersect = false(size(ray_origin,1),1);
t = inf+zeros(size(ray_origin,1),1); u=t; v=t;
xcoor = nan+zeros(size(ray_origin));

edge1 = vert1-vert0;
edge2 = vert2-vert0;
tvec  = ray_origin -vert0;
pvec  = cross(ray_direction, edge2,2);
det   = sum(edge1.*pvec,2);
switch planeType
    case 'two sided'
        angleOK = (abs(det)>eps);
    case 'one sided'
        angleOK = (det>eps);
end
if all(~angleOK), return; end

det(~angleOK) = nan;
u    = sum(tvec.*pvec,2)./det;
if fullReturn
    qvec = cross(tvec, edge1,2);
    v    = sum(ray_direction  .*qvec,2)./det;
    t    = sum(edge2.*qvec,2)./det;
    ok   = (angleOK & u>=-zero & v>=-zero & u+v<=1.0+zero);
else
    v = nan+zeros(size(u)); t=v;
    ok = (angleOK & u>=-zero & u<=1.0+zero);
    if ~any(ok), intersect = ok; return; end
    qvec = cross(tvec(ok,:), edge1(ok,:),2);
    v(ok,:) = sum(ray_direction(ok,:).*qvec,2) ./ det(ok,:);
    if (~strcmpi(lineType,'line'))
        t(ok,:) = sum(edge2(ok,:).*qvec,2)./det(ok,:);
    end

    ok = (ok & v>=-zero & u+v<=1.0+zero);
end


switch lineType
    case 'line'
        intersect = ok;
    case 'ray'
        intersect = (ok & t>=-zero);
    case 'segment'
        intersect = (ok & t>=-zero & t<=1.0+zero);
end



ok = intersect | fullReturn;
xcoor(ok,:) = vert0(ok,:) ...
    + edge1(ok,:).*repmat(u(ok,1),1,3) ...
    + edge2(ok,:).*repmat(v(ok,1),1,3);


points = [xcoor(intersect,1), xcoor(intersect,2), xcoor(intersect,3)];



if ~isempty(points)
    dvar = (points(:,1) - ray_origin(1,1)).^2 + (points(:,2) - ray_origin(1,2)).^2 + (points(:,3) - ray_origin(1,3)).^2;
    [~,idx] = min(dvar);
    intersectionPoint = points(idx,:);
end

end