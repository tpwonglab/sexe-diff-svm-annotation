function result = concat_and_remove_nan(x, y)
    % Ensure both inputs are column vectors
    if size(x, 2) > 1 || size(y, 2) > 1
        error('Both inputs must be column vectors.');
    end
    
    % Determine the lengths of the arrays
    len_x = length(x);
    len_y = length(y);
    
    % Pad the shorter array with NaNs to match the length of the longer array
    if len_x < len_y
        x = [x; NaN(len_y - len_x, 1)];
    else
        y = [y; NaN(len_x - len_y, 1)];
    end
    
    % Concatenate the arrays vertically
    concatenated = [x; y];
    
    % Remove NaN values
    result = concatenated(~isnan(concatenated));
end
