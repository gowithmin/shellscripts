#!/bin/sh
# hyunmin hwang, gowithmin@gmail.com
# 2014.12
# bind vsftpd user home directory(virtual directory) on web server

FTPRoot="/data/ftpsite"
SrcRoot="/data/webdocuments"

FTPDirInfoFN="FTPDirInfoForMount"
## FTPDirInfoForMount file format
# > comment for #
# > {FTPID}={Directory path for bind} {Directory path for bind}
# > e.g 1) ftp_user01=/mobile/css/new
# > e.g 2) ftp_user01=/pc/html/title /mobile/html/menu #/html/body
# source directory path same to virtual directory path
# e.g) source = ${SrcRoot}/mobile/css/new -bind to-> ${FTPRoot}/${FTPUserHome}/mobile/css/new

Usage() {
    echo "Usage : $0 [mount|umount]"
}

if [ -z $1 ];then
    Usage
    exit 1
else
    if [ $1 == "mount" ] || [ $1 == "umount" ];then
        Cmd=$1
    else
        Usage
        exit 1
    fi
fi

if [ ! -f $FTPDirInfoFN ];then
    echo "[CRIT] FTP directory info not found"
    exit 1
fi

Users=(`cat $FTPDirInfoFN | tr "\=" " " | awk {'print $1'}`)
for user in ${Users[@]}
do
    if [ `echo $user | grep -e "^\#" | wc -l` -ne 1 ];then
        tUserDirs=`grep $user $FTPDirInfoFN`
        UserDirs=${tUserDirs##*\=}
        for dir in ${UserDirs[@]}
        do
            if [ `echo $dir | grep -e "^\#" | wc -l` -ne 1 ];then
                if [ ! -d $SrcRoot/$dir ];then
                    echo "[CRIT] Source directory can not found"
                else
                    bindDir=$FTPRoot/$user${dir}
                    if [ ! -d $bindDir ];then
                        mkdir -p $bindDir
                    fi
                fi
                
                SrcDir=$SrcRoot$dir
                
                case $Cmd in
                mount)
                    mount --bind $SrcDir $bindDir
                    ;;
                umount)
                    umount $bindDir
                    ;;
                *)
                    Usage
                    ;;
                esac
                
                sleep 1
                echo "[INFO] FTP dir ${Cmd}ed"
                echo " src : $SrcDir, dst : $bindDir"
           fi
        done
     fi
done
