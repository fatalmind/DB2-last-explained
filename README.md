DB2-last-explained
==================

A DB2 view to display the execution plan of the last statement the current user explained.

It can be used right from the DB2 prompt without the need for a local installation of other tools like `db2exfmt` or `db2expln`. Its output is more dense and thus faster to gasp.


```
db2 => EXPLAIN PLAN FOR SELECT 1 FROM sysibm.sysdummy1;

db2 => select * from last_explained;

Explain Plan                                                                                        
----------------------------------------------
ID | Operation      |             Rows | Cost                                                       
 1 | RETURN         |                  |    0                                                       
 2 |  TBSCAN GENROW | 1 of 1 (100.00%) |    0                                                       
                                                                                                    
Predicate Information                                                                               
                                                                                                    
Explain plan by Markus Winand - NO WARRANTY                                                         
http://use-the-index-luke.com/s/last_explained 
```

System Requirements
-------------------

The view requires DB2 LUW 9.7 with Fix Pack 4 or better.

Note that it will not work on 9.7 Express-C which used to be on Fix Pack 2 without any option to install a later Fix Pack. This view does not work on DB2/zOS.

Installation
------------

Just create the view wherever you like. If not done yet, you'll need to install the explain tables first. Please find all the details here: http://use-the-index-luke.com/sql/explain-plan/db2/getting-an-execution-plan

Usage
-----

Just query the view:

    select * from last_explained;
    
Please have a look at this short overview of the most common execution plan operations you might see: http://use-the-index-luke.com/sql/explain-plan/db2/operations
  
Caveats
-------

The view displays the most recent execution plan gathered by the current user (as reported by `SESSION_USER`). If another person uses the same database user and does an `explain` between your `explain` and `select * from last_explained`, you'll get the execution plan form the other user's statement.


