do
$body$
declare
  num_users integer;
begin
   SELECT count(*)
     into num_users
   FROM pg_user
   WHERE usename = 'USER';

   IF num_users = 0 THEN
      create user USER with password 'PASSWORD';
   END IF;
end
$body$
;
