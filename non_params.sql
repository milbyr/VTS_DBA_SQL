col name format a30
col value format a60

set linesize 130
set pagesize 2000

SELECT KSPPINM "Name", KSPFTCTXVL "Value"
FROM X$KSPPI A, X$KSPPCV2 B
WHERE A.INDX + 1 = KSPFTCTXPN
AND KSPFTCTXDF <> 'TRUE'
ORDER BY 2;
