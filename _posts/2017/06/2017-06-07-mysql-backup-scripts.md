---
layout: post
title: Mysql备份定时任务和备份脚本
date: 2017-06-07
category: [database, mysql]
tags: [mysql, shell]
---


最近折腾docker,需要一个mysql的备份脚本,导出纯sql的,物理卷备份已经有了,我找同事要一份,给我发过来一看是我自己7年前写的.哈哈!完全忘记了.

这个用了7年了,基本上没有什么问题,有些需要优化的我写到todo里了,有时间会来重构一下.

```bash
#!/bin/bash


# author: Vincent Wantchalk - ohergal@gmail.com
# created date: 2010-12-07
# last update: 2017-06-07


###########################
# USAGE
###########################
#
# 一. 直接运行命令来备份
#     * backup_mysql.sh
#         - 默认用mysqldump方式备份
#     * backup_mysql.sh 1
#         - 同上
#     * backup_mysql.sh 2
#         - 使用mysqlhotcopy的方式备份
#     * backup_mysql.sh 3
#         - 直接打tar包
#     
# 二. 放在crontab里做定时任务
#
#     # crontab -e -u root
#     30 3 * * *   /var/backups/backup_mysql.sh 1
#     40 3 * * mon/2 /var/backups/backup_mysql.sh 2
#     42 4 1 * * /var/backups/backup_mysql.sh 3 
#     
#

###########################
# TODO
###########################
#
#    * [ ] 备份目录改成年月日层次结构
#    * [ ] 备份文件加上时间,现在只有日期
#    * [ ] 删除时,按照日期的目录删除
#    * [ ] 加上--skip-comments 参数 

###########################
# Change Log
###########################
#
# * 2017-07-06
#     - 增加使用说明
#

# 需要备份的数据库 用空格隔开
BACKUP_DATABASES="mysql"
# 备份数据库的用户名和密码(最好是root的,这样可以通用备份所有的库)
DB_USER=root
DB_PASS=00000000
# 备份文件的根目录
BACKUP_ROOT_PATH=/var/backups/local
# mysql命令的目录
MYSQL_BIN_PATH=/usr/bin
# 是否开启NFS备份
IS_NFS_BACKUP=no
# 远程备份路径 (此路径为nfs映射的路径)
REMOTE_BACKUP_ROOT_PATH=/app01/nfs_mount/dl/website_backup


#######################################################################
## 核心方法
#######################################################################
# 打印日志
log_common()
{
    if [[ ! -z $1 ]] ; then
        echo -e '\E[34;48m'"\033[1m $1 \033[0m"
    fi
}

log_warn()
{
    if [[ ! -z $1 ]] ; then
        echo -e '\E[33;48m'"\033[1m $1 \033[0m"
    fi
}

log_error()
{
    if [[ ! -z $1 ]] ; then
        echo -e '\E[31;48m'"\033[1m $1 \033[0m"
    fi
}

log_title()
{
    if [[ ! -z $1 ]] ; then
        echo -e '\E[35;48m'"\033[1m **********************  $1  ********************* \033[0m"
    fi
}

log_para()
{
    if [[ ! -z $1 && ! -z $2 ]] ; then
        echo -e '\E[32;48m'"\033[1m $1 : \033[0m" $2
    fi
}

backup_mysql_db()
{

    # 本次备份的db名字
    DBName=$1
    DBUser=$DB_USER
    DBPasswd=$DB_PASS
    BackupPath=$BACKUP_ROOT_PATH/mysql/
    RemotePATH=$REMOTE_BACKUP_ROOT_PATH/mysql/
    LogFile=$BACKUP_ROOT_PATH/mysql/mysqlbackup.log
    DBPath=/var/lib/mysql/
    BackupMethod=$2
    ## 初始化目录
    if  [ ! -e $BackupPath ] ; then 
        mkdir -p $BackupPath
    fi
    # 如果开启NFS备份
    if [ $IS_NFS_BACKUP == "yes" ] ; then
        if  [ ! -e $RemotePATH ] ; then 
            mkdir -p $RemotePATH
        fi
    fi
    ## 初始化备份文件
    NewFile="$BackupPath""$DBName"_$(date +%y%m%d)_"$BackupMethod".tgz
    RemoteFile="$RemotePATH""$DBName"_$(date +%y%m%d)_"$BackupMethod".tgz
    DumpFile="$BackupPath""$DBName"_$(date +%y%m%d)
    OldFile="$BackupPath""$DBName"_$(date +%y%m%d --date='7 days ago')_"$BackupMethod".tgz
    OldFiler="$RemotePATH""$DBName"_$(date +%y%m%d --date='7 days ago')_"$BackupMethod".tgz
    if [ $MYSQL_BACKUP_METHOD_PARA == 1 ] ; then
        OldFile="$BackupPath""$DBName"_$(date +%y%m%d --date='7 days ago')_"$BackupMethod".tgz
        OldFiler="$RemotePATH""$DBName"_$(date +%y%m%d --date='7 days ago')_"$BackupMethod".tgz
    elif [ $MYSQL_BACKUP_METHOD_PARA == 2 ] ; then
        OldFile="$BackupPath""$DBName"_$(date +%y%m%d --date='2 week ago')_"$BackupMethod".tgz
        OldFiler="$RemotePATH""$DBName"_$(date +%y%m%d --date='2 week ago')_"$BackupMethod".tgz
    elif [ $MYSQL_BACKUP_METHOD_PARA == 3 ] ; then
        OldFile="$BackupPath""$DBName"_$(date +%y%m%d --date='1 month ago')_"$BackupMethod".tgz
        OldFiler="$RemotePATH""$DBName"_$(date +%y%m%d --date='1 month ago')_"$BackupMethod".tgz
    fi



    echo "-------------------------------------------" >> $LogFile
    echo $(date +"%y-%m-%d %H:%M:%S") >> $LogFile
    echo "--------------------------" >> $LogFile
    # 删除不要的过期备份
    if [ -f $OldFile ] ; then
       rm -f $OldFile >> $LogFile 2>&1
       echo "[$OldFile]Delete Old File Success!" >> $LogFile
    else
       echo "[$OldFile]No Old Backup File!" >> $LogFile
    fi
    if [ $IS_NFS_BACKUP == "yes" ] ; then
        if [ -f $OldFiler ] ; then
           rm -f $OldFiler >> $LogFile 2>&1
           echo "[$OldFiler]Delete Old File Success!" >> $LogFile
        else
           echo "[$OldFiler]No Old Backup File!" >> $LogFile
        fi
    fi

    if [ -f $NewFile ] ; then
       echo "[$NewFile]The Backup File is exists,Can't Backup!" >> $LogFile
    else
       case $BackupMethod in
       mysqldump)
          if [ -z $DBPasswd ] ; then
             $MYSQL_BIN_PATH/mysqldump -u $DBUser --opt $DBName > $DumpFile
          else
             $MYSQL_BIN_PATH/mysqldump -u $DBUser -p$DBPasswd --opt $DBName > $DumpFile
          fi
          tar czvf $NewFile $DumpFile >> $LogFile 2>&1
          echo "[$NewFile]Backup Success!" >> $LogFile
          rm -rf $DumpFile
          ;;
       mysqlhotcopy)
          rm -rf $DumpFile
          mkdir $DumpFile
          if [ -z $DBPasswd ] ; then
             $MYSQL_BIN_PATH/mysqlhotcopy -u $DBUser $DBName $DumpFile >> $LogFile 2>&1
          else
             $MYSQL_BIN_PATH/mysqlhotcopy -u $DBUser -p $DBPasswd $DBName $DumpFile >>$LogFile 2>&1
          fi
          tar czvf $NewFile $DumpFile >> $LogFile 2>&1
          echo "[$NewFile]Backup Success!" >> $LogFile
          rm -rf $DumpFile
          ;;
       *)
          /etc/init.d/mysql stop >/dev/null 2>&1
          tar czvf $NewFile $DBPath$DBName >> $LogFile 2>&1
          /etc/init.d/mysql start >/dev/null 2>&1
          echo "[$NewFile]Backup Success!" >> $LogFile
          ;;
       esac
    fi

    if [ $IS_NFS_BACKUP == "yes" ] ; then
        cp -ruv $NewFile  $RemoteFile
    fi

    echo "-------------------------------------------" >> $LogFile
}

# 备份所有的
backup_mysql_db_all()
{
    log_title " start backup mysql database "
    # 循环db 开始备份
    for db_to_name in $BACKUP_DATABASES
    do
        log_para "start to backup db : " " $db_to_name "
        backup_mysql_db $db_to_name  $MYSQL_BACKUP_METHOD
        log_common "the db $db_to_name backup success !"
    done 
    log_title " backup mysql database end "
}


# 备份策略
MYSQL_BACKUP_METHOD_PARA=$1
MYSQL_BACKUP_METHOD=mysqldump
# 检查并设置默认参数
if [[ ! -z $1 ]] ; then
    log_common "your enter parameter is $1"
else
    log_common "you havn't enter any method of mysql backup use 'mysqldump' by default"
    MYSQL_BACKUP_METHOD_PARA=1
fi

# 初始化备份策略
if [ $MYSQL_BACKUP_METHOD_PARA == 1 ] ; then
    MYSQL_BACKUP_METHOD=mysqldump
elif [ $MYSQL_BACKUP_METHOD_PARA == 2 ] ; then
    MYSQL_BACKUP_METHOD=mysqlhotcopy
elif [ $MYSQL_BACKUP_METHOD_PARA == 3 ] ; then
    MYSQL_BACKUP_METHOD=tar
fi
log_para "mysql backup method is " " $MYSQL_BACKUP_METHOD "

# 开始备份
backup_mysql_db_all
```


还有一个类似的来自`iredmail`,也可以用.

```
#!/usr/bin/env bash

# Author:   Zhang Huangbin (zhb@iredmail.org)
# Date:     16/09/2007
# Purpose:  Backup specified mysql databases with command 'mysqldump'.
# License:  This shell script is part of iRedMail project, released under
#           GPL v2.

###########################
# REQUIREMENTS
###########################
#
#   * Required commands:
#       + mysqldump
#       + du
#       + bzip2     # If bzip2 is not available, change 'CMD_COMPRESS'
#                   # to use 'gzip'.
#

###########################
# USAGE
###########################
#
#   * It stores all backup copies in directory '/var/vmail/backup' by default,
#     You can change it in variable $BACKUP_ROOTDIR below.
#
#   * Set correct values for below variables:
#
#       BACKUP_ROOTDIR
#       MYSQL_ROOT_USER
#       DATABASES
#       DB_CHARACTER_SET
#
#   * Add crontab job for root user (or whatever user you want):
#
#       # crontab -e -u root
#       1   4   *   *   *   bash /path/to/backup_mysql.sh
#
#   * Make sure 'crond' service is running, and will start automatically when
#     system startup:
#
#       # ---- On RHEL/CentOS ----
#       # chkconfig --level 345 crond on
#       # /etc/init.d/crond status
#
#       # ---- On Debian/Ubuntu ----
#       # update-rc.d cron defaults
#       # /etc/init.d/cron status
#

#########################################################
# Modify below variables to fit your need ----
#########################################################
# Keep backup for how many days. Default is 90 days.
KEEP_DAYS='90'

# Where to store backup copies.
export BACKUP_ROOTDIR='/var/vmail/backup'

# MySQL username. Root user is required to dump all databases.
export MYSQL_ROOT_USER='root'

# ~/.my.cnf
export MYSQL_DOT_MY_CNF='/root/.my.cnf'

# Databases we should backup.
# Multiple databases MUST be seperated by SPACE.
export DATABASES='mysql vmail roundcubemail amavisd iredadmin sogo iredapd'

# Database character set for ALL databases.
# Note: Currently, it doesn't support to specify character set for each databases.
export DB_CHARACTER_SET="utf8"

#########################################################
# You do *NOT* need to modify below lines.
#########################################################
export PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin'

# Commands.
export CMD_DATE='/bin/date'
export CMD_DU='du -sh'
export CMD_COMPRESS='bzip2 -9'
export COMPRESS_SUFFIX='bz2'
export CMD_MYSQL="mysql --defaults-file=${MYSQL_DOT_MY_CNF} -u${MYSQL_ROOT_USER}"
export CMD_MYSQLDUMP="mysqldump --defaults-file=${MYSQL_DOT_MY_CNF} -u${MYSQL_ROOT_USER} --events --ignore-table=mysql.event --default-character-set=${DB_CHARACTER_SET} --skip-comments"

# Date.
export YEAR="$(${CMD_DATE} +%Y)"
export MONTH="$(${CMD_DATE} +%m)"
export DAY="$(${CMD_DATE} +%d)"
export TIME="$(${CMD_DATE} +%H-%M-%S)"
export TIMESTAMP="${YEAR}-${MONTH}-${DAY}-${TIME}"

# Pre-defined backup status
export BACKUP_SUCCESS='YES'

# Define, check, create directories.
export BACKUP_DIR="${BACKUP_ROOTDIR}/mysql/${YEAR}/${MONTH}/${DAY}"

# Find the old backup which should be removed.
export REMOVE_OLD_BACKUP='NO'
if which python &>/dev/null; then
    export REMOVE_OLD_BACKUP='YES'
    py_cmd="import time; import datetime; t=time.localtime(); print datetime.date(t.tm_year, t.tm_mon, t.tm_mday) - datetime.timedelta(days=${KEEP_DAYS})"
    shift_date=$(python -c "${py_cmd}")
    shift_year="$(echo ${shift_date} | awk -F'-' '{print $1}')"
    shift_month="$(echo ${shift_date} | awk -F'-' '{print $2}')"
    shift_day="$(echo ${shift_date} | awk -F'-' '{print $3}')"
    export REMOVED_BACKUP_DIR="${BACKUP_ROOTDIR}/mysql/${shift_year}/${shift_month}/${shift_day}"
fi

# Log file
export LOGFILE="${BACKUP_DIR}/${TIMESTAMP}.log"

# Verify MySQL connection.
${CMD_MYSQL} -e "show databases" &>/dev/null
if [ X"$?" != X"0" ]; then
    echo "[ERROR] MySQL username or password is incorrect in file ${0}." 1>&2
    echo "Please fix them first." 1>&2

    exit 255
fi

# Check and create directories.
[ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} 2>/dev/null
chown root ${BACKUP_DIR}
chmod 0700 ${BACKUP_DIR}

# Initialize log file.
echo "* Starting backup: ${TIMESTAMP}." >${LOGFILE}
echo "* Backup directory: ${BACKUP_DIR}." >>${LOGFILE}

# Backup.
echo "* Backing up databases: ${DATABASES}." >> ${LOGFILE}
for db in ${DATABASES}; do
    #backup_db ${db} >>${LOGFILE}

    #if [ X"$?" == X"0" ]; then
    #    echo "  - ${db} [DONE]" >> ${LOGFILE}
    #else
    #    [ X"${BACKUP_SUCCESS}" == X'YES' ] && export BACKUP_SUCCESS='NO'
    #fi
    output_sql="${BACKUP_DIR}/${db}-${TIMESTAMP}.sql"

    # Check database existence
    ${CMD_MYSQL} -e "USE ${db}" &>/dev/null

    if [ X"$?" == X'0' ]; then
        # Dump
        ${CMD_MYSQLDUMP} ${db} > ${output_sql}

        if [ X"$?" == X'0' ]; then
            # Get original SQL file size
            original_size="$(${CMD_DU} ${output_sql} | awk '{print $1}')"

            # Compress
            ${CMD_COMPRESS} ${output_sql} >>${LOGFILE}

            if [ X"$?" == X'0' ]; then
                rm -f ${output_sql} >> ${LOGFILE}
            fi

            # Get compressed file size
            compressed_file_name="${output_sql}.${COMPRESS_SUFFIX}"
            compressed_size="$(${CMD_DU} ${compressed_file_name} | awk '{print $1}')"

            sql_log_msg="INSERT INTO log (event, loglevel, msg, admin, ip, timestamp) VALUES ('backup', 'info', 'Database: ${db}, size: ${compressed_size} (original: ${original_size})', 'cron_backup_sql', '127.0.0.1', UTC_TIMESTAMP());"
        else
            # backup failed
            export BACKUP_SUCCESS='NO'
            sql_log_msg="INSERT INTO log (event, loglevel, msg, admin, ip, timestamp) VALUES ('backup', 'info', 'Database backup failed: ${db}. Log: $(cat ${LOGFILE})', 'cron_backup_sql', '127.0.0.1', UTC_TIMESTAMP());"
        fi

        # Log to SQL table `iredadmin.log`, so that global domain admins can
        # check backup status (System -> Admin Log)
        ${CMD_MYSQL} iredadmin -e "${sql_log_msg}"
    fi
done

# Append file size of backup files.
echo -e "* File size:\n----" >>${LOGFILE}
cd ${BACKUP_DIR} && \
${CMD_DU} *${TIMESTAMP}*sql* >>${LOGFILE}
echo "----" >>${LOGFILE}

echo "* Backup completed (Success? ${BACKUP_SUCCESS})." >>${LOGFILE}

if [ X"${BACKUP_SUCCESS}" == X'YES' ]; then
    echo "==> Backup completed successfully."
else
    echo -e "==> Backup completed with !!!ERRORS!!!.\n" 1>&2
fi

if [ X"${REMOVE_OLD_BACKUP}" == X'YES' -a -d ${REMOVED_BACKUP_DIR} ]; then
    echo -e "* Delete old backup: ${REMOVED_BACKUP_DIR}." >> ${LOGFILE}
    echo -e "* Suppose to delete: ${REMOVED_BACKUP_DIR}" >> ${LOGFILE}
    rm -rf ${REMOVED_BACKUP_DIR} >> ${LOGFILE} 2>&1

    sql_log_msg="INSERT INTO log (event, loglevel, msg, admin, ip, timestamp) VALUES ('backup', 'info', 'Remove old backup: ${REMOVED_BACKUP_DIR}.', 'cron_backup_sql', '127.0.0.1', UTC_TIMESTAMP());"
    ${CMD_MYSQL} iredadmin -e "${sql_log_msg}"
fi

echo "==> Detailed log (${LOGFILE}):"
echo "========================="
cat ${LOGFILE}
```
