classdef Util < Singleton
    methods(Static)
        
        % Function IC
        % Induces rank correlation onto a sample.
        %
        % Input:
        %  sample - sample column-oriented matrix (NxM)
        %  RC - rank correlation matrix
        %  score - score vector. Its length is equal to #rows in the sample
        %  seed - random seed
        % Output:
        %  sample - rotated matrix, first column left unchanged
        %  index  - index of each element in the columns of the original sample
        %           (NxM matrix)
        %
        % Required functions:
        %   getRank - calculates ranks
        %
        % Usage example:
        %   sample = rand(1000,2); % random sample
        %   scatter(sample(:,1),sample(:,2));
        %   R = [1 0.7; 0.7 1];            % corr matrix
        %   score = norminv((1:1000)./1001,0,1);
        %   [sample1, ix] = IC(sample,R,score);
        %   scatter(sample1(:,1),sample1(:,2));
        %
        % Method from: "Stephen J. Mildenhall, Correlation and Aggregate Loss Distributions
        %               With An Emphasis On The Iman-Conover Method", 2005
        %
        % Author: Roman Gutkovich, roman.gutkovich@aig.com
        %
        % ver 1.0	02/08/2012
        % ver 2.0	03/16/2013
        % Changes	1. added random seed
        
        function [sample, index] = IC(sample,RC,score, seed)
            
            
            if (nargin == 3)
                warning('Function IC : rendom seed not specified, set to 1');
                seed = 1;
            end
            
            if (nargin < 3)
                error('Function IC : too few arguments');
            end
            
            stream = RandStream.getGlobalStream;
            GenType = get(stream,'Type');
            stream = RandStream(GenType,'Seed',seed); %changed from 1
            RandStream.setGlobalStream(stream);
            
            
            rows = size(sample,1);
            cols = size(sample,2);
            if (cols < 2)
                warning('Function IC','Only one column in the input, function skipped');
                return;
            end
            
            if (max(size(score)) ~= rows)
                error ('IC: number of elements in "score" vector must match number of rows in "sample"');
            end
            
            ix_col1 = getRank(sample(:,1),1);
            
            [sample, index] = sort(sample);
            M = zeros(rows,cols);
            
            % normalize the score vector
            score = (score - mean(score))/std(score);
            
            % set columns of score matrix
            M(:,1) = score;
            for j = 2:cols
                M(:,j) = score(randsample(rows,rows));
            end;
            
            C = chol(RC);
            E = (M'*M)/rows;
            F = chol(E);
            %T = M*inv(F)*C; MATLAB recommends to use M/F instead of M*inv(F)
            T = (M/F)*C;
            
            % rank values in columns
            idx = getRank(T,1);
            
            % sample after rotations
            for k = 1:size(idx,2)
                sample(:,k) = sample(idx(:,k),k);
                index(:, k) = index(idx(:,k), k);
            end
            
            % rotate the entire sample to
            % preserve the original order of the first column
            % of the input sample
            sample = sample(ix_col1,1:end);
            index = index(ix_col1, 1:end);
            
        end
        
        function ds = makeDataset(ca)
            %Transfers cell array to dataset
            names = ca(2:end, 1);
            if(~iscellstr(names))
                names = cellstr(num2str(cell2mat(names)));
            end
            ds = cell2dataset(ca(:,2:end), 'ObsNames', names);
        end

    end
end
