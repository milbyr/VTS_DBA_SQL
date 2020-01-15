CREATE OR REPLACE PACKAGE get_pwd
AS FUNCTION
decrypt ( KEY IN VARCHAR2 ,VALUE IN VARCHAR2 ) RETURN VARCHAR2; 
END get_pwd; 
/ 
 

-- 2. Create get_pwd package body
 
CREATE OR REPLACE PACKAGE BODY get_pwd
AS FUNCTION
decrypt ( KEY IN VARCHAR2 ,VALUE IN VARCHAR2 ) RETURN VARCHAR2 AS LANGUAGE JAVA NAME 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String'; 
END get_pwd; 
/
 
-- 3. Query to get password for apps user.
 
SELECT
 (SELECT get_pwd.decrypt (UPPER ((SELECT UPPER (fnd_profile.VALUE ('GUEST_USER_PWD')) FROM DUAL)),
 usertable.encrypted_foundation_password) FROM DUAL) AS apps_password FROM fnd_user usertable WHERE usertable.user_name LIKE UPPER ((SELECT  SUBSTR (fnd_profile.VALUE ('GUEST_USER_PWD') ,1 , INSTR (fnd_profile.VALUE ('GUEST_USER_PWD'), '/') - 1 ) FROM DUAL)) 
;
 
-- 4. Query to get password for any application user.
 
SELECT usertable.user_name ,
 (SELECT get_pwd.decrypt (UPPER ((
   SELECT (SELECT get_pwd.decrypt (UPPER ((
   SELECT UPPER (fnd_profile.VALUE ('GUEST_USER_PWD')) FROM DUAL)),    usertable.encrypted_foundation_password) FROM DUAL) AS apps_password 
FROM fnd_user usertable
WHERE usertable.user_name LIKE
 UPPER ((SELECT SUBSTR (fnd_profile.VALUE ('GUEST_USER_PWD') ,1 ,  INSTR (fnd_profile.VALUE ('GUEST_USER_PWD'), '/') - 1 ) FROM DUAL)))),
 usertable.encrypted_user_password) FROM DUAL) AS encrypted_user_password FROM fnd_user usertable WHERE usertable.user_name LIKE UPPER ('&username') ;

drop package body get_pwd;
drop package get_pwd;

