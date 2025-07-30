# Tar incremental backup
## version 1.2.0

### configuration

FORCE_FLAG_STATE - reinitialization flag - 0 (not reinitialise) / 1 (reinitialise) 

BACKUP_MODE - backup mode yearly / monthly / weekly / daily


### to run debug 
```shell
docker rm -f tar-incremental-backup-test-container && docker image rm tar-incremental-backup -f && docker-compose -f ./docker-compose.yml up --force-recreate --remove-orphans debugger
```

### to run test
```shell
docker rm -f tar-incremental-backup-test-container && docker image rm tar-incremental-backup -f && docker-compose -f ./docker-compose.yml up --force-recreate --remove-orphans test 
```