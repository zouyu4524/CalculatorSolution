function [OPERATOR, NUMBER, STR, portal] = parser(varargin)
%% input parser
% return operator list
% if portal mode is on, return portal pair, otherwise portal is []
%
% parameters types:
% 1. number
% 2. operator + number
% 3. sign
% 4. backspace
% 5. reverse
% 6. replace
% 7. shift> | <shift
% 8. mirror
% 8. [+] number, change type {1, 2} operator
% 9. power
% 10. sum
% 11. store (not a operator, store current result as a 'number')
% 12. Inv10, each figure x (x=1~9) is replaced with (10 - x)
% 13. portal

portal = [];
OPERATOR = cell(nargin, 1); NUMBER = cell(nargin, 1);
STR = cell(nargin, 1);

for k = 1 : nargin
    number = [];
    param = varargin{k};
    if isnumeric(param)
        if numel(param) == 1 % type 1, number
            operator = @(x, number) str2double(...
                [num2str(x) num2str(number)]);
            number = param;
        else
            portal = param;  % type 12, portal
            operator = 'portal';
        end
    else
        switch (param)
            case '+/-'    % tpye 3, sign
                operator = @(x, number) -x;
            case '<shift' % type 7, shift left
                operator = @(x, number) sign(x)*(str2double(...
                    join(circshift(...
                    cellstr(num2str(abs(x))'), -1),'')));
            case 'shift>' % type 7, shift right
                operator = @(x, number) sign(x)*(str2double(...
                    join(circshift(...
                    cellstr(num2str(abs(x))'), 1),'')));
            case 'mirror' % type 8, mirror
                operator = @(x, number) sign(x)*str2double(...
                    [num2str(abs(x)), reverse(num2str(abs(x)))]);
            case 'store'  % type 11, store
                operator = 'store';
            otherwise
                pos = strfind(param, '=>'); % type 6, replace
                if (~isempty(pos))
                    org = param(1:pos-1);
                    rep = param(pos+2:end);
                    operator = @(x, number) str2double(...
                        strrep(num2str(x), org, rep));
                else
                    if ~isempty(strfind(param, 'x^')) % type 9, power
                        operator = @(x, number) x^(number);
                        number = str2double(param(3:end));
                    else
                        if ~isempty(strfind(param, '[+]')) % type 8
                            operator = '[+]';
                            number = str2double(param(4:end));
                        else
                            switch (param(1))
                                case '+'
                                    operator = @(x, number) x + number;
                                    number = str2double(param(2:end));
                                case '-'
                                    operator = @(x, number) x - number;
                                    number = str2double(param(2:end));
                                case 'x'
                                    operator = @(x, number) x * number;
                                    number = str2double(param(2:end));
                                case '/'
                                    operator = @(x, number) x / number;
                                    number = str2double(param(2:end));
                                case '<' % type 4, backspace
                                    operator = @(x, number) floor(x/10);
                                case 'r' % type 5, reverse
                                    operator = @(x, number) ...
                                        sign(x)*str2double(reverse(...
                                        num2str(abs(x))));
                                case 's' % type 10, sum
                                    operator = @(x, number) sign(x)*...
                                        sum(str2double(...
                                        cellstr(num2str(abs(x))')));
                                case 'i' % type 12, inv10
                                    operator = @(x, number) sign(x)*...
                                        str2double(num2str(mod(...
                                        10 - str2double(cellstr(...
                                        num2str(abs(x))')), 10)));
                                otherwise
                                    error(['Wrong input for ' ...
                                        num2str(k+3) 'parameter.'])
                            end
                        end
                    end
                end
        end
    end
    OPERATOR{k} = operator; NUMBER{k} = number;
    STR{k} = param;
end
    % deal with 'store', put store command in the first row
    posStore = find(strcmp(OPERATOR, 'store'), 1);
    if ~isempty(posStore)
        tmp = [OPERATOR, NUMBER, STR];
        tmp = [tmp(posStore, :); tmp([1:posStore-1, posStore+1:end], :)];
        OPERATOR = tmp(:, 1); NUMBER = tmp(:, 2); STR = tmp(:, 3);
    end
    % delete 'portal' operator
    posPortal = find(strcmp(OPERATOR, 'portal'), 1);
    if ~isempty(posPortal)
        tmp = [OPERATOR, NUMBER, STR];
        tmp(posPortal,:) = [];
        OPERATOR = tmp(:, 1); NUMBER = tmp(:, 2); STR = tmp(:, 3);
    end
end

function rs = reverse(s)
% reverse str, simple implementation 
% reverse function was introduced since 2016b
    tmp = cellstr(s');
    rs = [tmp{end:-1:1}];
end