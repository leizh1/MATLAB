%Budget Line object that inherited from LOB

classdef BudgetLine < Line
   properties(SetAccess = protected)
       mapping %mapping strcture
       children %mapped LOB
       pattern
       tag
   end
   properties%(Dependent = true)
       cashflow %memorized
   end
   
   methods
       
       function obj = BudgetLine(name)
           obj.name = name;
           %search for name_ID
       end
       
       function obj = setParams(obj, ID, mapping, tag)
           obj.ID = ID;
           obj.mapping = mapping;
           obj.tag = tag;
           obj.cashflow = zeros(1,1,1);
       end
       
       
       %% cashflow
       function cashflow = get.cashflow(obj)
           GP = Params.instance();
           if(size(obj.cashflow,3) < GP.N)
               cashflow = SystemRiskGenerator.combineCashflow(obj);
               obj.cashflow = cashflow;
           else
               cashflow = obj.cashflow;
           end
       end
       
       %%
       function setAYCY(obj, maxAY, maxFAY, maxCY)
          obj.nAY = maxAY;
          obj.nFAY = maxFAY;
          obj.nCY = maxCY;
       end
       
       %% pattern
       function p = get.pattern(obj)
           
       end
       

   end
end
