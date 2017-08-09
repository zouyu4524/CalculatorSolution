function sol = solution(src, dst, step, varargin)
%% solution for calulator: the game
% parameters:
%   src: original number
%   dst: objective number
%
% operator list:
%       '-3': minues 3
%       '+5': plus 5
%       'x2': times 2
%       '/3': divides 3
%         10: add '10' at the end of current number
%      '+/-': change sign
%       '<<': backspace
%  'reverse': reverse number, keep negetive sign ('-') if it exists
%   'mirror': 32 -> 2332
%    '5=>13': replace
%   'shift>': 231 -> 123
%   '<shift': -150 -> -501
%     '[+]2': increase each number of operators 2 (e.g. +3 -> +5)
%      'sum': 1023 -> (1+0+2+3) -> 6
%      'x^3': power
%    'inv10': 1250 -> (10-1, 10-8, 10-5, 0) -> 9850
%    'store': store current result as a number operator (ignore negetive)
%     [4, 2]: portal indicator, 4th digital will added to the 2nd digital
%             1123 -> (123 + 10) -> 133
%
% example:
%   sol = solution(39, 12, 4, 'x-3', '/3', '+9', '+/-')
%   >> sol = {'/3', '+/-', '+9', 'x-3'}

[OPERATOR, NUMBER, STR, p] = parser(varargin{:});

hasStore = strcmp(OPERATOR{1}, 'store');

n_input = nargin;
if ~isempty(p) % portal mode
    n_input = n_input - 1;
    s_dig = p(1); d_dig = p(2);
    if (s_dig <= d_dig)
        error('Portal src digital should larger than dst digital')
    end
end

searchspace = (n_input-3)^step;
sol = cell(1, step);

for k = 1 : searchspace
    result = src;
    OPERATOR_tmp = OPERATOR; NUMBER_tmp = NUMBER; STR_tmp = STR;
    if n_input -3 == 1 % only one operator
        strategy = ones(step, 1);
    else
        str = dec2base(k-1, n_input-3, step);
        strategy = str2double(cellstr(str')) + 1;
    end
    if ~hasStore
        for i = 1 : step
            operator = OPERATOR_tmp{strategy(i)};
            number = NUMBER_tmp{strategy(i)};
            if strcmp(operator, '[+]')
                [OPERATOR_tmp, NUMBER_tmp, STR_tmp] = ...
                    plusOperator(number, ...
                    OPERATOR_tmp, NUMBER_tmp, STR_tmp);
            else
                result = operator(result, number);
                if ~isempty(p) % portal mode
                    result = portal(s_dig, d_dig, result);
                end
                % when figure of number exceeds 6, program shows ERROR,
                % besides, operation on non-integer is not allowed
                if length(num2str(abs(result))) > 6 ||...
                        floor(result) ~= result
                    result = nan; break;
                end
            end
            sol(i) = STR_tmp(strategy(i));
        end
    else
        storeSearchSpace = 2^step;
        for storeIter =  1 : storeSearchSpace
            OPERATOR_tmp = OPERATOR; NUMBER_tmp = NUMBER; STR_tmp = STR;
            storeMask = str2double(cellstr(dec2bin(storeIter, step)'));
            [result, sol] = calc(src, strategy, ...
                OPERATOR_tmp, NUMBER_tmp, STR_tmp, storeMask, p);
            if result == dst
                break;
            end
        end
    end
    if result == dst
        break;
    end
end

if k == searchspace && result ~= dst
    error('No solution, please check input.')
end

end

function [result, sol] = calc(src, seq, OPERATOR, NUMBER, STR, ...
    storeMask, p)
% deal with scenarios with 'store'
% p is portal pair, [s, d]
% seq is the sequence of strategy
result = src;
sol = {};
step = numel(seq);
for k = 1 : step
    if storeMask(k) && result >= 0 % ignore negative case
        [OPERATOR, NUMBER, STR] = storeOperator(...
            result, OPERATOR, NUMBER, STR);
        sol = [sol, 'store'];
    end
    operator = OPERATOR{seq(k)}; number = NUMBER{seq(k)};
    if strcmp(operator, 'store')
        result = nan; sol = nan; break;
    end
    if strcmp(operator, '[+]')
        [OPERATOR, NUMBER, STR] = ...
            plusOperator(number, OPERATOR_tmp, NUMBER, STR);
    else
        result = operator(result, number);
        if ~isempty(p) % portal mode
            result = portal(p(1), p(2), result);
        end
        % when figure of number exceeds 6, program shows ERROR,
        % besides, operation on non-integer is not allowed
        if length(num2str(abs(result))) > 6 || floor(result) ~= result
            result = nan; sol = nan; break;
        end
    end
    sol = [sol, STR(seq(k))];
end
end

function [OPERATOR, NUMBER, STR] = plusOperator(...
    number, OPERATOR, NUMBER, STR)
% update operator according to '[+]' operator
for k = 1 : numel(OPERATOR)
    if ~strcmp(OPERATOR{k}, '[+]') && ~isempty(NUMBER{k})
        update = NUMBER{k} + number;
        if isnumeric(STR{k})
            STR{k} = update;
        else
            STR{k} = strrep(STR{k}, num2str(NUMBER{k}), num2str(update));
        end
        NUMBER{k} = update;
    end
end
end

function [OPERATOR, NUMBER, STR] = storeOperator(...
    number, OPERATOR, NUMBER, STR)
% update store command
OPERATOR{1} = @(x, number) str2double([num2str(x) num2str(number)]);
NUMBER{1} = number;
STR{1} = num2str(number);
end

function result = portal(s, d, number)
% portal mode
% s, d denote digital position of src and dst, respectively
result = number; digitals = num2str(number);
n = numel(digitals);
while (n >= s && floor(result) == result)
    transport = str2double(digitals(n-s+1));
    left = str2double(digitals([1:n-s, n-s+2:end]));
    result = left + transport * 10^(d-1);
    digitals = num2str(result);
    n = numel(digitals);
end
end