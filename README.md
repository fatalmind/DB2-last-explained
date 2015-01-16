DB2-last-explained
==================

DB2 view to display the execution plan of the last explained statement

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

The view displays the most recent execution plan gathered by the current user (as reported by SESSION_USER). If another person uses the same database user and does an `explain` between your `explain` and `select * from last_explained`, you'll get the execution plan form the other user's statement.


