#!/bin/sh
# Çalışan (veya durmuş) Supabase konteynerlerinden ortam dosyalarını üretir.
# Şifreler bu sunucuda kalır; git'e veya sohbete gitmez.
#   sh make-env.sh            -> /opt/aidat-supabase/env/{db,kong,auth,rest}.env
set -eu
P=deneme_aidat-database
OUT=/opt/aidat-supabase/env
mkdir -p "$OUT"
chmod 700 "$OUT"
for s in db kong auth rest; do
  docker inspect "${P}-${s}-1" --format '{{range .Config.Env}}{{println .}}{{end}}' \
    | grep -vE '^(PATH|HOME|HOSTNAME|TERM)=' | grep -v '^$' > "$OUT/$s.env"
  chmod 600 "$OUT/$s.env"
  echo "$s.env: $(wc -l < "$OUT/$s.env") satır"
done
# Kontrol: kritik anahtarlar var mı (değerleri yazdırmadan)
for k in POSTGRES_PASSWORD JWT_SECRET; do grep -q "^$k=." "$OUT/db.env" && echo "db: $k tamam" || echo "db: $k EKSİK"; done
grep -q '^SUPABASE_ANON_KEY=.' "$OUT/kong.env" && echo "kong: anon tamam" || echo "kong: anon EKSİK"
grep -q '^GOTRUE_JWT_SECRET=.' "$OUT/auth.env" && echo "auth: jwt tamam" || echo "auth: jwt EKSİK"
grep -q '^PGRST_JWT_SECRET=.' "$OUT/rest.env" && echo "rest: jwt tamam" || echo "rest: jwt EKSİK"
