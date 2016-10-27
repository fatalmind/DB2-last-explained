-- experimental XML output
WITH tree(operator_id, parent, object_name, rows, level, path, explain_time, cycle)
AS
(
SELECT 1 AS operator_id
     , null AS parent 
     , null AS object_name
     , null AS stream_count
     , 0 level
     , CAST('001' AS VARCHAR(1000)) path
     , max(explain_time) explain_time
     , 0
  FROM SYSTOOLS.EXPLAIN_OPERATOR O
 WHERE O.EXPLAIN_REQUESTER = SESSION_USER

UNION ALL

SELECT s.source_id AS operator_id
     , s.target_id AS parent
     , s.object_name AS object_name
     , s.stream_count AS rows
     , level + 1
     , tree.path || '/' || LPAD(CAST(s.source_id AS VARCHAR(3)), 3, '0')  path
     , tree.explain_time
     , POSITION('/' || LPAD(CAST(s.source_id AS VARCHAR(3)), 3, '0')  || '/' IN path USING OCTETS)
  FROM tree
     , SYSTOOLS.EXPLAIN_STREAM S
 WHERE s.target_id    = tree.operator_id
   AND s.explain_time = tree.explain_time
   AND S.Object_Name IS NULL
   AND S.explain_requester = SESSION_USER
   AND tree.cycle = 0
   AND level < 100
)
SELECT tree.parent
     , XMLELEMENT(NAME "operation"
                 , XMLATTRIBUTES(tree.operator_id                   AS "operation_id"
                               , TRIM(CAST(operator_type  AS VARCHAR(6))) AS "operator_type"
                               , object_name                        AS "object_name"
                               , CAST(rows           AS BIGINT    ) AS "rows"
                               , CAST(TOTAL_COST     AS BIGINT    ) AS "total_cost"
                               , CAST(IO_COST        AS BIGINT    ) AS "io_cost"
                               , CAST(CPU_COST       AS BIGINT    ) AS "cpu_cost"
                               , CAST(FIRST_ROW_COST AS BIGINT    ) AS "first_row_cost"
                               , CAST(BUFFERS        AS BIGINT    ) AS "buffers"
                               )
     , (SELECT XMLAGG(XMLELEMENT(NAME "argument"
                               , XMLATTRIBUTES(TRIM(argument_type) AS "type"
                                             , TRIM(argument_value) AS "value"
                                             )
                               )
                     )
          FROM SYSTOOLS.EXPLAIN_ARGUMENT arg
         WHERE arg.operator_id       = tree.operator_id
           AND arg.explain_time      = tree.explain_time
           AND arg.explain_requester = SESSION_USER
       )
     , (SELECT XMLAGG(XMLELEMENT(NAME "actual"
                               , XMLATTRIBUTES(actual_type  AS "type"
                                             , actual_value AS "value"
                                             )
                               )
                     )
          FROM SYSTOOLS.EXPLAIN_ACTUALS act
         WHERE act.operator_id       = tree.operator_id
           AND act.explain_time      = tree.explain_time
           AND act.explain_requester = SESSION_USER
       )
     , (SELECT XMLAGG(XMLELEMENT(NAME "predicate"
                               , XMLATTRIBUTES(TRIM(CAST(how_applied AS VARCHAR(10))) AS "how_applied")
                               , predicate_text
                               )
                     )
         FROM SYSTOOLS.EXPLAIN_PREDICATE pred
        WHERE pred.operator_id  = tree.operator_id
          AND pred.explain_time = tree.explain_time
          AND pred.explain_requester = SESSION_USER
       )
     )
  FROM tree
  LEFT JOIN SYSTOOLS.EXPLAIN_OPERATOR O
    ON (    o.operator_id  = tree.operator_id
        AND o.explain_time = tree.explain_time
        AND o.explain_requester = SESSION_USER
       ) 
ORDER BY path
