### Check Data Dir
- on Host
``` bash
sudo ls /data/postgresql/
```
- on Pod
``` bash
ls /var/lib/postgresql/data 
```
### Login
``` bash
psql -U postgres --password -p 5432 postgres
```
- [Postgres Installation](https://www.digitalocean.com/community/tutorials/how-to-deploy-postgres-to-kubernetes-cluster)
- [Bytebase Installation](https://docs.bytebase.com/get-started/self-host/deploy-with-kubernetes)
