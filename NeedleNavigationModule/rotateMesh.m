function rotatedVertices = rotateMesh(vertices, rotationAxis, rotationAngle, rotationPoint)

    % Translate vertices to place rotationPoint at the origin
    translatedVertices = vertices - rotationPoint;

    % Convert rotation angle to radians
    rotationAngle = deg2rad(rotationAngle);

    % Normalize the rotation axis
    rotationAxis = rotationAxis / norm(rotationAxis);

    % Compute the rotation matrix using the axis-angle formula
    ux = rotationAxis(1);
    uy = rotationAxis(2);
    uz = rotationAxis(3);
    c = cos(rotationAngle);
    s = sin(rotationAngle);
    C = 1 - c;

    rotationMatrix = [
        c + ux^2*C,       ux*uy*C - uz*s,   ux*uz*C + uy*s;
        uy*ux*C + uz*s,   c + uy^2*C,       uy*uz*C - ux*s;
        uz*ux*C - uy*s,   uz*uy*C + ux*s,   c + uz^2*C;
    ];

    % Rotate the translated vertices
    rotatedVertices = (rotationMatrix * translatedVertices')';

    % Translate vertices back to the original position
    rotatedVertices = rotatedVertices + rotationPoint;
end
