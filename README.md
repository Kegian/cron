# cronexp

D framework providing parser of cron expressions and evaluator of
next date and time of execution

## About

Cron expression consists of 6 required fields separated by white space

Supported fields:

```
Field           Allowed values      Special charachters

Seconds         0-59                , - * /
Minutes         0-59                , - * /
Hours           0-23                , - * /
Day-of-month    1-31                , - * / ?
Month           1-12 or JAN-DEC     , - * /
Day-of-week     1-7 or MON-SUN      , - * / ?

Months names: JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC
Days-of-week names: MON,TUE,WED,THU,FRI,SAT,SUN
```

Expression:

```
 ┌───────────── second (0 - 59)
 │ ┌───────────── minute (0 - 59)
 │ │ ┌───────────── hour (0 - 23)
 │ │ │ ┌───────────── day of month (1 - 31)
 │ │ │ │ ┌───────────── month (1 - 12)
 │ │ │ │ │ ┌───────────── day of week (1 - 7) (Monday to Sunday)
 │ │ │ │ │ │   
 │ │ │ │ │ │
 │ │ │ │ │ │
 * * * * * *
```

Charachters:

`Asterisk (*)` is used for specify all values (eg. 'every minute' in minute field)

`Comma (,)` is used for to separate items of a list (eg. using `MON,WED,FRI` 
in  the 6th field (day of week) means Mondays, Wednesdays, Fridays)

`Hyphen (-)` is used for define ranges (eg. `10-30` in 1st field means every second
between 10 and 30 inclusive)

`Slash (/)` is used for define step values, `a/x = a, a+x, a+2x, a+3x, ...`
(eg. `2/4` in hours means list of `2,6,10,14,18,22`)\
`*` in `*/x` mean minimal allowed value (eg. 0 for hours, 1 for months etc)

`Question mark (?)` is a synonym of `*` for day-of-week and day-of-month fields used
to explicitly indicate that days are set with other field


**NOTES**:
* If both the 'Day-of-month' and 'Day-of-week' fields are
  restricted (aren't `*`), next correct time will be when **both**
  fields match the conditions\
  For example: `* * * 13 * FRI` expression will be satisfied only on friday 13th.
* Ranges can be overflowing, it means range `NOV-FEB` (NOV > FEB)
  will expand in `NOV,DEC,JAN,FEB`

## Usage

```d
import cron;

auto cron = CronExpr("30 * 12 1/2 NOV-FEB 2/2");
auto date = DateTime(2000, 6, 1, 10, 30, 0);
auto next = cron.getNext(date);

writeln(next); // 2000-Nov-07 12:00:30
```

Note that return type of `CronExpr.getNext` is `Nullable!DateTime`\
It can be `Null` if next date of execution is more than 4 years(1464 days)

For example:

```d
import cron;

auto cron = CronExpr("0 0 0 29 FEB THU");
auto date = DateTime(2000, 1, 1, 0, 0, 0);
Nullable!DateTime next = cron.getNext(date);

assert(next.isNull); // Because next correct date in 2024 year
```

