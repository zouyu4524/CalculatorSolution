# Solution for Calculator: the Game

## Demo

![LEVEL:189](http://ww1.sinaimg.cn/large/93d8f721ly1fidb507o87g20j2076419.gif)

## Example
**LEVEL: 189**
sol = solution(45, 516, 4, '+10', 'mirror', 'reverse', [4, 2])

```
operator list:
       '-3': minues 3
       '+5': plus 5
       'x2': times 2
       '/3': divides 3
         10: add '10' at the end of current number
      '+/-': change sign
       '<<': backspace
  'reverse': reverse number, keep negetive sign ('-') if it exists
   'mirror': 32 -> 2332
    '5=>13': replace
   'shift>': 231 -> 123
   '<shift': -150 -> -501
     '[+]2': increase each number of operators 2 (e.g. +3 -> +5)
      'sum': 1023 -> (1+0+2+3) -> 6
      'x^3': power
    'inv10': 1250 -> (10-1, 10-8, 10-5, 0) -> 9850
    'store': store current result as a number operator (ignore negetive)
     [4, 2]: portal indicator, 4th digital will added to the 2nd digital
             1123 -> (123 + 10) -> 133
```