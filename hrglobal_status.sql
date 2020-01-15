set pages 200 lines 160 trims on

SELECT DECODE(hli.legislation_code,NULL,'Global',
  hli.legislation_code) legCode,
 hli.application_short_name asn,
  hli.status status, last_update_date
FROM hr_legislation_installations hli
WHERE hli.status = 'I'
order by 1,2;
