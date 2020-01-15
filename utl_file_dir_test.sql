--1. Create a test procedure
 
CREATE OR REPLACE procedure utl_file_test_write (
 path in varchar2, filename in varchar2, firstline in varchar2, secondline in varchar2)
 is
 output_file utl_file.file_type;
 begin
 output_file := utl_file.fopen (path,filename, 'W');
 
 utl_file.put_line (output_file, firstline);
 utl_file.put_line (output_file, secondline);
 utl_file.fclose(output_file);
 
exception
 when others then null;
end;
/

show error
 
--Now run a test -
 
begin
 utl_file_test_write ( '/applbe01/csf/temp', 'utl_file_test3', 'first line', 'second line');
end;
/

drop procedure utl_file_test_write;
