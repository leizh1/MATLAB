    % calculates rank for numbers in rows
    % the smallest number has the lowest rank = 1
    % input - row oriented matrix
    % T = [32 13 17 44 15 6; 11 23 5 21 54 93]; 
    % dim - ranking order (
    %   1 - assumes that values sit in cols, ranked by rows 
    %   2 - assumes that values sit in rows, ranked by cols
    
    % output - matrix having the same dimensions, values replaced by ranks 
    % idx = getRank(T,2)
    % result idx: [5 2 4 6 3 1; 2 4 1 3 5 6]
    
    function idx = getRank(T,dim)
    
    % ranking - based on the code from
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/163003
    if ~ any(dim == [1 2])
        error('getRank()', 'dim must be set to 1 or 2')
    end
    
    if dim == 2  % values in rows, ranks by columns
        [~, idx] = sort(T,2);
        [J I]=ndgrid(1:size(idx,1),1:size(idx,2));
        idx(sub2ind(size(idx),J,idx))=I;
    else % values in columns, ranks by rows
        [~, idx] = sort(T,1);
        [I J]=ndgrid(1:size(idx,1),1:size(idx,2));
        idx(sub2ind(size(idx),idx,J))=I;
    end;
    
    end