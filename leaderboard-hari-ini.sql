-- Jalankan sekali di Supabase > SQL Editor.
-- Dipakai layar Vaporista untuk menampilkan hitungan tugas HARI INI milik semua orang.
-- Hanya menambah fungsi baru; tidak mengubah atau menghapus data.
create or replace function public.leaderboard_today()
returns table (id uuid, done bigint, total bigint)
language sql
stable
security definer
set search_path = public
as $$
  select p.id,
         count(t.id) filter (where t.status = 'done'),
         count(t.id)
  from profiles p
  left join tasks t
    on t.assignee = p.id
   and t.due = (now() at time zone 'Asia/Jakarta')::date
  where p.role = 'employee'
    and auth.uid() is not null
  group by p.id
$$;

revoke all on function public.leaderboard_today() from public, anon;
grant execute on function public.leaderboard_today() to authenticated;
