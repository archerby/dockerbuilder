#!/bin/bash
set -e # EXIT on ANY error
BASE_PATH=$PWD;
echo $BASE_PATH;

countdown()
(
  IFS=:
  set -- $*
  secs=$(( ${1#0} * 3600 + ${2#0} * 60 + ${3#0} ))
  while [ $secs -gt 0 ]
  do
    sleep 1 &
    printf "\r%02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
    secs=$(( $secs - 1 ))
    wait
  done
  echo
)
answer=0;
while [ "$answer" = 0 ]
do
echo "<==================================================================================================>";
read -r -p "Do you want to Use Existing Directory ? [Y/N] " CHECK_DIR

case $CHECK_DIR in
    [yY][eE][sS]|[yY])
	ls -ln $BASE_PATH
	answer=1;
	read -r -p "Add the project dir name (example AboutAustralia ): " PROJECT_DIR
	;;
		

    [nN][oO]|[nN])
	answer=1;
		read -r -p "Add the project dir name (example AboutAustralia ): " PROJECT_DIR
		mkdir -p $BASE_PATH/$PROJECT_DIR
		mkdir -p $BASE_PATH/$PROJECT_DIR/configurations
		mkdir -p $BASE_PATH/$PROJECT_DIR/configurations/sites-enabled
		mkdir -p $BASE_PATH/$PROJECT_DIR/mysql
		mkdir -p $BASE_PATH/$PROJECT_DIR/logs	
	        
	        ;;

    *)
	echo "Invalid input..."
	
	;;
esac

done

echo "<==================================================================================================>";
echo "Add the project Alias"
echo "<==========>NOTE ALIAS SHOULD BE UNIQUE<===========>";
sudo docker ps
read -r -p "TYPE the project alias (example AA ): " PROJECT_ALIAS




echo "<==================================================================================================>";
echo "Selected Dir $PROJECT_DIR info";
find ./$PROJECT_DIR/ -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"
echo "<==================================================================================================>";




echo "MYSQL verios: ";
echo "[1]: v5.5";
echo "[2]: v5.6";
echo "[3]: v5.7";
echo "[4]: v8.0";
echo "[0]: use already installed container";
MYSQL_Container=0;
answer=0;
while [ "$answer" = 0 ]
do
read -r -p "Select the version(1,2,3,4,0): " MYSQL_V
echo "<==================================================================================================>";
case $MYSQL_V in
    1|2|3|4)
		answer=1;		
		echo "selected option: " $MYSQL_V
		read -r -p "Add mysql password for user root : " MYSQL_PASS
		;;
    0)
		answer=1;
		sudo docker ps
		read -r -p "Add the Mysql container ID: " MYSQL_Container
		;;

    *)
	echo "Invalid input..."
	;;
esac
done


mysql_conf_file=$BASE_PATH/$PROJECT_DIR/configurations/mysql_conf_$MYSQL_V.cnf;
MCR=0;
echo "<==================================================================================================>";
if [ -f $(eval echo $mysql_conf_file) ]; then
	echo " Mysql conf file already exis!!!!! "
	answer=0;
	while [ "$answer" = 0 ]
	do
	read -r -p "Do you want to change the MYSQL config file to default? [Y/N] " MYSQL_CONF

	case $MYSQL_CONF in
	    [yY][eE][sS]|[yY])
			answer=1;
			echo "The file can be changed automatically to default configurations."			
			MCR=1;
		        ;;

	    [nN][oO]|[nN])
			answer=1;
		        echo "Existed config file is used;"
		        ;;

	    *)
		echo "Invalid input..."		
		;;
	esac
	done

else
	echo "The Mysql conf file was created automatically." 	
	echo "The File path is: "$mysql_conf_file	
	MCR=1;	

fi


if [ $MCR = 1 ] ;then

	if [ $MYSQL_V = 1 ]
	then
	    MYSQL_IMAGE="mysql:5.5";
	    cat > $mysql_conf_file <<EOF

[client]
port = 3306

[mysqld]
port = 3306
max_allowed_packet=3562M
sql_mode = "NO_AUTO_VALUE_ON_ZERO"
character-set-server=utf8
collation-server=utf8_general_ci
wait_timeout=28800
interactive_timeout = 28800
max_allowed_packet=256M
query_cache_limit = 100M
query_cache_size  = 80M


innodb_buffer_pool_size = 256M
innodb_additional_mem_pool_size = 10M
innodb_lock_wait_timeout = 180
innodb_log_file_size = 24M
innodb_thread_concurrency = 8
innodb_file_per_table = 0

EOF
	elif [ $MYSQL_V = 2 ]
	then
	    MYSQL_IMAGE="mysql:5.6";
cat > $mysql_conf_file <<EOF

[client]
port = 3306

[mysqld]
port = 3306
max_allowed_packet=3562M
sql_mode = "NO_AUTO_VALUE_ON_ZERO"
character-set-server=utf8
collation-server=utf8_general_ci
wait_timeout=28800
interactive_timeout = 28800
max_allowed_packet=256M
query_cache_limit = 100M
query_cache_size  = 80M


innodb_buffer_pool_size = 256M
innodb_additional_mem_pool_size = 10M
innodb_lock_wait_timeout = 180
innodb_log_file_size = 24M
innodb_thread_concurrency = 8
innodb_file_per_table = 0

EOF
	elif [ $MYSQL_V = 3 ]
	then
	    MYSQL_IMAGE="mysql:5.7";
cat > $mysql_conf_file <<EOF

[client]
port = 3306

[mysqld]
port = 3306
max_allowed_packet=3562M
sql_mode = "NO_AUTO_VALUE_ON_ZERO"
character-set-server=utf8
collation-server=utf8_general_ci
wait_timeout=28800
interactive_timeout = 28800
max_allowed_packet=256M
query_cache_limit = 100M
query_cache_size  = 80M


EOF

elif [ $MYSQL_V = 4 ]
	then
	    MYSQL_IMAGE="mysql:8.0";
cat > $mysql_conf_file <<EOF
[client]
port = 3306

[mysqld]
port = 3306
max_allowed_packet=3562M
sql_mode = "NO_AUTO_VALUE_ON_ZERO"
character-set-server=utf8
collation-server=utf8_general_ci
wait_timeout=28800
interactive_timeout = 28800
max_allowed_packet=256M
query_cache_limit = 100M
query_cache_size  = 80M

EOF
	else
	    echo "";
	fi



fi

echo "<==================================================================================================>";
answer=0;
while [ "$answer" = 0 ]
do
read -r -p "Do you want to See and edit MYSQL config file? [Y/N] " CHECK_MC


case $CHECK_MC in
    [yY][eE][sS]|[yY])
		answer=1;
		nano $mysql_conf_file
	        ;;

    [nN][oO]|[nN])
		answer=1;
	        echo "Skipping the show and edit Mysql CONF"
	        ;;

    *)
	echo "Invalid input..."	
	;;
esac
done


echo "<==================================================================================================>";
echo "<==================================================================================================>";
echo "Apache verios: ";
echo "[1]: v2.2";
echo "[2]: v2.4";
echo "[0]: use already installed container";
answer=0;
while [ "$answer" = 0 ]
do
read -r -p "Select Apache version [1,2,0] : " APPACHE_V
case $APPACHE_V in
    1|2)
		answer=1;
		echo "Selected option : "$APPACHE_V
		;;
    0)
		answer=1;		
		sudo docker ps
		read -r -p "Add the APACHE container ID: " APACHE_Container
		;;

    *)
	echo "Invalid input..."
	;;
esac
done


if [ $APPACHE_V = 1 ]
then
    APACHE_IMAGE="lephare/apache:2.2";
elif [ $APPACHE_V = 2 ]
then
    APACHE_IMAGE="lephare/apache:2.4";
else
    echo "";
fi

echo "<==================================================================================================>";
conf_file=$BASE_PATH/$PROJECT_DIR/configurations/sites-enabled/virtualHost_$PROJECT_ALIAS.conf

RAC=0;
if [ -f $(eval echo $conf_file) ]; then
	echo "The Apache conf file exit!"
	answer=0;
	while [ "$answer" = 0 ]
	do
	read -r -p "Do you want to recreate config file to dewault conf? [Y/N] " REBUILD_APACHE_CONF

	case $REBUILD_APACHE_CONF in
	    [yY][eE][sS]|[yY])
			answer=1;
			RAC=1
		        echo "The Apache conf would be reconfigureg to default"
			read -r -p "Please add the web_url (example site.loc) : " SITE_URL
		        ;;

	    [nN][oO]|[nN])
			answer=1;
		        echo "Skipping the rebuild CONF"
		        ;;

	    *)
		echo "Invalid input..."
		
		;;
	esac
	done
else
	echo "The Apache conf file be created automatically." 	
	echo "The File path is: "$conf_file	
	RAC=1;
	read -r -p "Please add the web_url (example site.loc) : " SITE_URL
fi

echo "<==================================================================================================>";

if [ $RAC = 1 ] ;then


if [ $APPACHE_V = 1 ]
then

cat > $conf_file <<EOF

	<VirtualHost *:80>
	    ServerName $SITE_URL
	    ServerAlias *.$SITE_URL

	    UseCanonicalName Off
	    AddHandler php5-fcgi .php
	    Action php5-fcgi /php5-fcgi
	    Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
	    FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host php_$PROJECT_ALIAS:9000 -pass-header Authorization

	    DocumentRoot /var/www/$PROJECT_ALIAS
	    <Directory /var/www/$PROJECT_ALIAS>
		Order allow,deny
		Allow from all
		Require all granted
		Satisfy Any
		Options FollowSymlinks
	    </Directory>

	    ErrorLog /var/log/apache2/$SITE_URL.error.log
	    CustomLog /var/log/apache2/$SITE_URL.access.log combined

	</VirtualHost>

EOF
    

elif [ $APPACHE_V = 2 ]
then
   
TMPLINE='/var/www/'$PROJECT_ALIAS'/$1';

cat > $conf_file <<EOF

<VirtualHost *:80>
    ServerName $SITE_URL
    ServerAlias *.$SITE_URL

    UseCanonicalName Off
    
    RewriteEngine on
    RewriteCond /var/www/$PROJECT_ALIAS/%{REQUEST_FILENAME} -f
    RewriteRule ^/(.*\.php(/.*)?)$ fcgi://php_$PROJECT_ALIAS:9000  $TMPLINE [L,P]

    DocumentRoot /var/www/$PROJECT_ALIAS
    <Directory /var/www/$PROJECT_ALIAS>
	Order allow,deny
        Allow from all
        Require all granted
        Satisfy Any
        Options FollowSymlinks
    </Directory>

    ErrorLog /var/log/apache2/$SITE_URL.error.log
    CustomLog /var/log/apache2/$SITE_URL.access.log combined

</VirtualHost>

EOF


else
    echo "";
fi


fi

echo "<==================================================================================================>";
answer=0;
while [ "$answer" = 0 ]
do
read -r -p "Do you want to See and edit Apache config file? [Y/N] " CHECK_MC

case $CHECK_MC in
    [yY][eE][sS]|[yY])
		answer=1;
		nano $conf_file
	        ;;

    [nN][oO]|[nN])
		answer=1;
	        echo "Skipping the show and edit Mysql CONF"
	        ;;

    *)
	echo "Invalid input..."
	
	;;
esac
done



echo "<==================================================================================================>";
echo "PHP verios: ";
echo "[1]: v5.3";
echo "[2]: v5.5";
echo "[3]: v5.6";
echo "[4]: v7.0";
echo "[5]: v7.1";
echo "[6]: v7.2";
echo "[0]: use already installed container";
answer=0;
while [ "$answer" = 0 ]
do
read -r -p "Select the version(1,2,3,4): " PHP_V
case $PHP_V in
    1|2|3|4|5|6)
		answer=1;
		echo "selected: " $PHP_V
		;;
    0)
		answer=1;
		read -r -p "Add the PHP container ID: " PHP_Container
		;;

    *)
	echo "Invalid input..."	
	;;
esac
done

if [ $PHP_V = 1 ]
then
    PHP_IMAGE="leucos/phpfpm-53:latest";
elif [ $PHP_V = 2 ]
then
    PHP_IMAGE="cytopia/php-fpm-5.5:latest";
elif [ $PHP_V = 3 ]
then
    PHP_IMAGE="php:5.6-fpm-jessie";
elif [ $PHP_V = 4 ]
then
    PHP_IMAGE="php:7.0-fpm-jessie";
elif [ $PHP_V = 5 ]
then
    PHP_IMAGE="php:7.1-fpm-jessie";
elif [ $PHP_V = 6 ]
then
    PHP_IMAGE="php:7.2-fpm-jessie";
else
    echo "";
fi


echo "<==================================================================================================>";
echo "<========>NOTE: type 'skip' to go not CLone any project<=========>";

read -r -p "Add the Git clone link : " GIT_CLONE_LINK


if [ $GIT_CLONE_LINK = 'skip' ]
then
	mkdir -p $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS;
else
   	if [ -d $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS ]
	then
		echo "<========>WARNING: The dirrectory $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS already exist <=========>";
		read -r -p "Remove this dir and clone(type '1') or use existing without clone( type '2') ? : " RECREATE_GIT_DIR
		if [ $RECREATE_GIT_DIR = 1 ]
		then
			sudo rm -rf $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS
			echo "Cloning the ptoject from git ($GIT_CLONE_LINK) to $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS"
			git clone $GIT_CLONE_LINK $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS
			echo "Git clone ready! ) "
			
		else
		    echo "";
		fi
	else
		echo "Cloning the ptoject from git ($GIT_CLONE_LINK) to $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS"
		git clone $GIT_CLONE_LINK $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS
		echo "Git clone ready! ) "
		
	fi
fi







DCY=0;
docker_yml=$BASE_PATH/$PROJECT_DIR/docker-compose.yml
if [ -f $(eval echo $docker_yml) ]; then
	echo "The Docker Compose YML file exit!"
	answer=0;
	while [ "$answer" = 0 ]
	do
	read -r -p "Do you want to recreate Docker Compose YML file to default? [Y/N] " REBUILD_DCY_CONF

	case $REBUILD_DCY_CONF in
	    [yY][eE][sS]|[yY])
			answer=1;
			DCY=2
		        echo "The Docker Compose YML will be edited"
		        ;;

	    [nN][oO]|[nN])
			answer=1;
		        echo "Skipping the rebuild Docker Compose YML"
		        ;;

	    *)
		echo "Invalid input..."
		;;
	esac
	done
else
	echo "The Docker Compose YML file be created automatically." 	
	echo "The File path is: "$docker_yml	
	DCY=1;
fi

DUMP_FILE_PATH=0;
ARCH_FILE_PATH=0;

echo "<==================================================================================================>";
echo "<==================================================================================================>";
MYSQL_VOLUM="";
if [ $MYSQL_Container = 0 ]
then
    echo "Build new Mysql Container"
    
    echo "Choose the way of how to create database: ";
    echo "[1]: Using dump File";
    echo "[2]: Using mysql.tar.gz archive";
    echo "[0]: Manualy after all components would be ready";
	answer=0;
	while [ "$answer" = 0 ]
	do
    read -r -p "Choose the way : " CHECK_MC
	echo "<=======================>NOTE!!: type 'find' to try find the files <=======================>";
	case $CHECK_MC in
	    1)
			answer=1;			
			read -r -p "Plese set the FULL!!! path to Dump File : " DUMP_FILE_PATH
			if [ $DUMP_FILE_PATH = 'find' ]
			then
				echo "Here is all sql files  under: $BASE_PATH";
				sudo find $BASE_PATH -type f \( -name \*sql.gz -o -name \*.sql \)
				DUMP_FILE_PATH=0;
				read -r -p "Plese set the FULL!!! path to Dump File : " DUMP_FILE_PATH
				MYSQL_VOLUM="    - $DUMP_FILE_PATH:/var/tmp/dumpx.sql";

			fi
			;;

	    2)
			answer=1;
			read -r -p "Plese set the  path to Archive file File : " ARCH_FILE_PATH
			if [ $ARCH_FILE_PATH = 'find' ]
			then
				echo "Here is all archive files under: $BASE_PATH";
				sudo find $BASE_PATH -type f \( -name \*tar.gz -o -name \*.gz -o -name \*.zip \)
				ARCH_FILE_PATH=0;
				read -r -p "Plese set the path to Dump File : " ARCH_FILE_PATH
				mkdir -p $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V
				tar -C $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V -xzf $ARCH_FILE_PATH
				MYSQL_VOLUM="    - $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V:/var/lib/mysql";
				
			fi
			;;
	    0)
			answer=1;
			echo "continuing";
			;;

	    *)
		echo "Invalid input..."
		exit 1
		;;
	esac
	done
    
else
    echo "";
fi


def_conf_file=$BASE_PATH/$PROJECT_DIR/configurations/sites-enabled/virtualhost.conf
cat > $def_conf_file <<EOF
#

EOF

if [ $DCY = 1 ];then
cat > $docker_yml <<EOF
version: '2'
services:
  phpfpm_$PROJECT_ALIAS:
    image: $PHP_IMAGE
    container_name: container_phpfpm_$PROJECT_ALIAS
    environment:
      LANG: en_US.UTF-8
    volumes:    
    - $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS:/var/www/$PROJECT_ALIAS
    links:
    - mysql_$PROJECT_ALIAS:mysql
    labels:
      io.rancher.scheduler.affinity:host_label: server-fvs21=true
      io.rancher.container.pull_image: always
  apache_$PROJECT_ALIAS:
    image: $APACHE_IMAGE
    container_name: container_apache_$PROJECT_ALIAS
    environment:
      LANG: en_US.UTF-8
    volumes:    
    - $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS:/var/www/$PROJECT_ALIAS
    - $BASE_PATH/$PROJECT_DIR/configurations/sites-enabled:/etc/apache2/sites-enabled
    - $BASE_PATH/$PROJECT_DIR/logs:/logs
    - $def_conf_file:/etc/dockerize/templates/virtualhost.conf.tpl
    links:
    - phpfpm_$PROJECT_ALIAS:php_$PROJECT_ALIAS
    labels:
      io.rancher.scheduler.affinity:host_label: server-fvs21=true
  mysql_$PROJECT_ALIAS:
    image: $MYSQL_IMAGE
    container_name: container_mysql_$PROJECT_ALIAS
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_PASS
    volumes:
    - $mysql_conf_file:/etc/mysql/conf.d/custom.cnf
$MYSQL_VOLUM
    labels:
      io.rancher.scheduler.affinity:host_label: server-fvs21=true
      io.rancher.container.pull_image: always
EOF

fi


echo "<========================================================>";
answer=0;
while [ "$answer" = 0 ]
do
read -r -p "Do you want to See and edit Docker Compose yml file? [Y/N] " CHECK_MC

case $CHECK_MC in
    [yY][eE][sS]|[yY])
		answer=1;
		nano $docker_yml
	        ;;

    [nN][oO]|[nN])
		answer=1;
	        echo "Skipping the show and edit DCY CONF"
	        ;;

    *)
	echo "Invalid input..."
	;;
esac
done

echo "<========================================================>";
cd $PROJECT_DIR
if [ $DUMP_FILE_PATH != 0 ]
then
	echo "Up the mysql container";
	sudo docker-compose up -d mysql_$PROJECT_ALIAS
	echo "please wait for .... ";
 	countdown "00:00:18"

	echo "<========  Trying to use dump file ==============>";
	sudo docker exec -ti container_mysql_$PROJECT_ALIAS sh -c "mysql -A -p$MYSQL_PASS  <<MYSQL_SCRIPT
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE database_$PROJECT_ALIAS;
USE database_$PROJECT_ALIAS;
SOURCE /var/tmp/dumpx.sql;
MYSQL_SCRIPT"
echo "<========  Dump USED! ==============>";
mkdir -p $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V
	sudo docker cp -a container_mysql_$PROJECT_ALIAS:/var/lib/mysql/. $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V/
echo "<========  Mysql folder is copied USED! ==============>";
	NEW_M_VOLUM="    - $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V:/var/lib/mysql";
	sed -i  "s@$MYSQL_VOLUM@$NEW_M_VOLUM@g" $docker_yml
echo "<========  Volume for dump changet to copiet mysql ==============>";
sudo docker rm -f container_mysql_$PROJECT_ALIAS



	sudo docker-compose up -d mysql_$PROJECT_ALIAS	
echo "please wait for .... ";
 	countdown "00:00:15"

echo "<========   mysql container restarted ==============>";
	
fi


sudo docker-compose up -d
WEB_IP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_apache_$PROJECT_ALIAS)


echo "**************************************************************************************";
echo "*********                The basic setup completed  !!!!                     *********";
echo "**************************************************************************************";
echo "**************************************************************************************";
echo "*********                             Summary                                *********";
echo "*     please add the host alias to /etc/hosts                                        *";
echo "*     $WEB_IP	$SITE_URL							   *";
echo "*  PHP working path $BASE_PATH/$PROJECT_DIR/git_$PROJECT_ALIAS 			   *";
echo "*  Apache conf path $BASE_PATH/$PROJECT_DIR/configurations/sites-enabled 		   *";
echo "*  Mysql lib path $BASE_PATH/$PROJECT_DIR/mysql/chV_$MYSQL_V	 		   *";
echo "*  docker-compose file $BASE_PATH/$PROJECT_DIR/docker-compose.yml	 		   *";
echo "*                                                                                    *";
echo "*                                                                                    *";
echo "*                                                                                    *";
echo "**************************************************************************************";
echo "**************************************************************************************";
echo "**************************************************************************************";
echo "*   To add some additional extentions for PHP                                        *";
echo "*   run your php container using the command                                         *";
echo "*   sudo docker exec -ti <php container name |ID> bash                               *";
echo "*   docker-php-ext-install <extention-list>                                          *";
echo "*   As soon as extentions will be installed                                          *";
echo "*   exit form container and add the commit                                           *";
echo "*   docker commit <container ID> {name}:{version}                                    *";
echo "*   example: docker commit e41848c9cdd4 php:7.1-ext-pach                             *";
echo "*   As soon as commit ready open your docker-conpose.yml file                        *";
echo "*   And change the php image to yours {name}:{version} ()                            *";
echo "**************************************************************************************";
echo "**************************************************************************************";
echo "**************************************************************************************";
echo "*  if you cannot connect to mysql container from host                                *";
echo "*  you should change the priveleges for your user                                    *";
echo "*  run your mysql container using bash                                               *";
echo "*   sudo docker exec -ti <php container name |ID> bash                               *";
echo "*   run: mysql -A -p                                                                 *";
echo "*   and change the priveleges using this script                                      *";
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
FLUSH PRIVILEGES;"
echo "*                                                                                    *";
echo "*                                                                                    *";
echo "*                                                                                    *";
echo "**************************************************************************************";
echo "**************************************************************************************";
echo "**************************************************************************************";



echo "Installation script completed! Powered by d.nazarevich"
