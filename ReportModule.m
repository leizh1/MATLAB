classdef ReportModule
   methods(Static)
       function displayHeatmap(BL)
           AY0 = BL.yr0 - BL.nAY;
           AYt = BL.yr0 + BL.nFAY - 1;
           %CYt = BL.yr0 + BL.nCY-1;
           heatmap(BL.analytics.VaR, 1:BL.nCY, AY0:AYt, [],...
               'TickAngle', 45, 'ShowAllTicks', true);
           pause;
       end
       
       %the input of this function aggregated cashflow, meaning the
       %cashflow is aggregated by AY
       function displayAggregatedCashflowBySurf(aggregatedCashflow, axes, plotObj)
           GP = Params.instance;
           nbar = 80;
           spacer = 3;
           % reshape the data
           [rows, cols, nsims] = size(aggregatedCashflow);
           if(nsims>1)
               aggregatedCashflow = reshape(aggregatedCashflow, cols, nsims, []);
               aggregatedCashflow = transpose(aggregatedCashflow);
           end
           %aggregatedCashflow = transpose(aggregatedCashflow);
           % calculate bar positions
           percentile_1 = prctile(aggregatedCashflow(:), 0.1); %percentile_1 = min(aggregatedCashflow(:));
           percentile_99 = prctile(aggregatedCashflow(:), 99.9); %percentile_99 = max(aggregatedCashflow(:));

           bar_width = (percentile_99-percentile_1)/(nbar-1);
           if(bar_width==0)
               x_axes = percentile_99;
           else
               x_axes = percentile_1:bar_width:percentile_99;
           end
           %x_axes = [min(aggregatedCashflow(:)), x_axes, max(aggregatedCashflow(:))];
           %
           N = [];
           %
           for i = 1:size(aggregatedCashflow, 2);
               [frequency, ~] = hist(aggregatedCashflow(:,i), x_axes);
               N = [N; zeros(spacer, nbar); frequency];
               %XOUT = [XOUT; xout];
           end
           %normalize the frequency
           %{
           maxCountByCY = max(N,[],2);
           shrinkFactorByCY = min(maxCountByCY(maxCountByCY~=0))./maxCountByCY;
           shrinkFactorByCY(shrinkFactorByCY==inf)=0;
           N = N.*repmat(shrinkFactorByCY, 1, nbar);
           %}
           
           N = transpose(N);
           barRef = bar3(axes, x_axes, N, 1);
           
           %<==============adjustments================>
           %change angle
           %set(barRef, 'CameraPosition', [235, 4.406E7, 58]);
           %remove empty bars
           ReportModule.removeEmptyBars(barRef);
           %empty ztick
           %set(axes, 'ZTick', []);
           %font size
           set(axes, 'FontSize', 8);
           %draw reverse
           set(axes,'YDir','normal')
           %change y limit
           set(axes, 'YLim', [percentile_1, percentile_99]);
           %change xtick space
           set(axes,'XTick',spacer+1:spacer+1:(spacer+1)*(1+size(aggregatedCashflow, 2)));
           set(axes,'YTick',percentile_1:(percentile_99-percentile_1)/10:percentile_99);
           %change y tick
           ytickerlabel = get(axes,'YTickLabel');
           ytickerlabel1 = ['<', ytickerlabel(1,:)];
           ytickerlabel(1, 1:length(ytickerlabel1)) = ytickerlabel1;
           ytickerlabel99 = ['>', ytickerlabel(length(ytickerlabel),:)];
           ytickerlabel(length(ytickerlabel),1:length(ytickerlabel99)) = ytickerlabel99;
           %set(axes,'YTickLabel', ytickerlabel);
           
           %<==============adjustment with additional info from obj================>
           if(nargin==2) %default input
               %change axes label
               set(axes,'XTickLabel',GP.yr0:GP.yr0+size(aggregatedCashflow, 2)-1);
               %label
               xlabel(axes, 'Calendar Year');
               ylabel(axes, 'Cash flow distribution');
               %title
               title(axes, 'Distribution of Cashflow by Calendar Year', 'FontWeight','bold', 'FontSize', 14);
           elseif(nargin == 3) %input with driver, used in driver panel
               if(isa(plotObj, 'EconomicDrivers'))
                   if(strcmp(plotObj.type, 'AY'))
                       xticker = (plotObj.yr0-plotObj.nAY+1):(plotObj.yr0+plotObj.nFAY);
                       set(axes,'XTickLabel',xticker);
                       %title
                       title(axes, ['Distribution of ', plotObj.name, ' by Accident Year'], 'FontWeight','bold', 'FontSize', 14);
                   else %CY
                       xticker = (plotObj.yr0):(plotObj.yr0+plotObj.nCY-1);
                       set(axes,'XTickLabel',xticker);
                       %title
                       title(axes, ['Distribution of ', plotObj.name, ' by Calendar Year'], 'FontWeight','bold', 'FontSize', 14);
                   end
                   
               elseif(isa(plotObj, 'BugetLine'))
                   %change axes label
                   set(axes,'XTickLabel',GP.yr0:GP.yr0+size(aggregatedCashflow, 2)-1);
                   set(axes, 'ZTick', []);
                   %label
                   xlabel(axes, 'Calendar Year');
                   ylabel(axes, 'Cash flow distribution');
                   %title
                   title(axes, ['Distribution of of cash flow for', plotObj.name, ' by Calendar Year'], 'FontWeight','bold', 'FontSize', 14);
               end
           end
           
           
       end
       
       function removeEmptyBars(hBars)
           for iSeries = 1:numel(hBars)
               zData = get(hBars(iSeries),'ZData');  %# Get the z data
               index = logical(kron(zData(2:6:end,2) == 0,ones(6,1)));  %# Find empty bars
               zData(index,:) = nan;                 %# Set the z data for empty bars to nan
               set(hBars(iSeries),'ZData',zData);    %# Update the graphics objects
           end
       end
       
   end
end
