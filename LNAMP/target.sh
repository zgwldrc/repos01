#!/bin/bash
APP_DOWNLOAD=/Data/download
APP_SRC=/Data/src
APP_LIB=/Data/lib



func_WriteEnvVarToBashrc() {
	#$1 is Title
	#$2-$n is variable name,the variable need to has been defined

	if [ $# -eq 0 ];then
		echo "Usage:%0 TITLE VARNAME1 VARNAME2 VARNAME3 ..."
		exit 1
	fi

	local title=$1
	shift
	grep -q $title ~/.bashrc 
	if [ $? -eq 1 ];then
	  {
	    echo 
	    echo "#--------$title---------#" 
	    until [ $# -eq 0 ]
	    do
	      echo "export $1=${!1}"
	      shift
	    done
	    echo "#--------$title---------#"
	  } >> ~/.bashrc
	fi
}
func_InstallApacheFromSource2_4_18() {
	##############################
	#Set Variables for your prefer
	##############################
	APACHE_PREFIX=/Data/apps/apache2
	WWW_DIR=/Data/www

	local apache_Url=http://mirrors.cnnic.cn/apache//httpd/httpd-2.4.18.tar.gz
	local apr_Url=http://apache.fayea.com//apr/apr-1.5.2.tar.gz
	local aprUtil_Url=http://apache.fayea.com//apr/apr-util-1.5.4.tar.gz
	local pcre_Url=http://jaist.dl.sourceforge.net/project/pcre/pcre/8.38/pcre-8.38.tar.bz2
	
	local operation="./configure \
		--prefix=$APACHE_PREFIX \
		--enable-mpms-shared=all \
		--with-mpm=prefork \
		--enable-mods-shared=most \
		--with-pcre=$APP_LIB/pcre \
		--with-included-apr"

	##############################
	#Url Analyzing
	##############################
	local apache_Tarball=${apache_Url##*/}
	local apache_SrcDir=${apache_Tarball%.tar.*}
	local apache_Ver=${apache_SrcDir##*-}
	local apache_Base=${apache_SrcDir%-[0-9].*}
        
	local apr_Tarball=${apr_Url##*/}
	local apr_SrcDir=${apr_Tarball%.tar.*}
	local apr_Ver=${apr_SrcDir##*-}
	local apr_Base=${apr_SrcDir%-[0-9].*}

	local aprUtil_Tarball=${aprUtil_Url##*/}
	local aprUtil_SrcDir=${aprUtil_Tarball%.tar.*}
	local aprUtil_Ver=${aprUtil_SrcDir##*-}
	local aprUtil_Base=${aprUtil_SrcDir%-[0-9].*}

	local pcre_Tarball=${pcre_Url##*/}
	local pcre_SrcDir=${pcre_Tarball%.tar.*}
	local pcre_Ver=${pcre_SrcDir##*-}
	local pcre_Base=${pcre_SrcDir%-[0-9].*}

	##############################
	#Main
	##############################
	###System Prepare
	func_WriteEnvVarToBashrc APACHE APACHE_PREFIX WWW_DIR

	mkdir -p $APACHE_PREFIX
	mkdir -p $WWW_DIR
	mkdir -p $APP_DOWNLOAD
	mkdir -p $APP_SRC
	grep httpd /etc/passwd || useradd -r httpd -s /bin/false
	cd $APP_DOWNLOAD
	yum install -y wget
	[ -f $apache_Tarball  ] || wget $apache_Url
	[ -f $apr_Tarball     ] || wget $apr_Url
	[ -f $aprUtil_Tarball ] || wget $aprUtil_Url
	[ -f $pcre_Tarball    ] || wget $pcre_Url
	
	[ -d $APP_SRC/$apache_SrcDir  ] || tar axvf $apache_Tarball  -C $APP_SRC
	[ -d $APP_SRC/$apr_SrcDir     ] || tar axvf $apr_Tarball     -C $APP_SRC
	[ -d $APP_SRC/$aprUtil_SrcDir ] || tar axvf $aprUtil_Tarball -C $APP_SRC
	[ -d $APP_SRC/$pcre_SrcDir    ] || tar axvf $pcre_Tarball    -C $APP_SRC
	
	[ -d $APP_SRC/$apache_SrcDir/srclib/apr      ] || cp -r $APP_SRC/$apr_SrcDir $APP_SRC/$apache_SrcDir/srclib/apr
	[ -d $APP_SRC/$apache_SrcDir/srclib/apr-util ] || cp -r $APP_SRC/$aprUtil_SrcDir $APP_SRC/$apache_SrcDir/srclib/apr-util

	cd $APP_SRC/$pcre_SrcDir
	make clean &> /dev/null
	./configure --prefix=$APP_LIB/pcre && make && make install
	
	cd $APP_SRC/$apache_SrcDir
	make clean &> /dev/null
	$operation &&  make && make install
	
	####Make init Script
	rm -f /etc/init.d/httpd
	ln -s $APACHE_PREFIX/bin/apachectl /etc/init.d/httpd
	sed -i '1a # chkconfig: 35 56 80' $APACHE_PREFIX/bin/apachectl
	sed -i '2a # description:httpd service' $APACHE_PREFIX/bin/apachectl
	chkconfig --add httpd

	mkdir -p $APACHE_PREFIX/conf.d
	sed -i '$a include conf.d/*.conf' $APACHE_PREFIX/conf/httpd.conf
	touch $APACHE_PREFIX/conf.d/empty.conf
	sed -i "s/^#ServerName www.example.com:80/ServerName $HOSTNAME:80/"  $APACHE_PREFIX/conf/httpd.conf
	sed -i 's/daemon/httpd/' $APACHE_PREFIX/conf/httpd.conf
}


func_InstallMySQLFromSource5_5_47() {
        ##############################
        #Set Variables for your prefer
        ##############################
        MYSQL_PREFIX=/Data/apps/mysql

        local mysql_Url=http://cdn.mysql.com//Downloads/MySQL-5.5/mysql-5.5.47.tar.gz

        local operation="cmake .. \
		-DCMAKE_INSTALL_PREFIX=$MYSQL_PREFIX \
		-DMYSQL_DATADIR=$MYSQL_PREFIX/data \
		-DMYSQL_UNIX_ADDR=$MYSQL_PREFIX/tmp/mysql.sock \
		-DSYSCONFDIR=$MYSQL_PREFIX/etc \
		-DWITH_INNOBASE_STORAGE_ENGINE=1 \
		-DDEFAULT_CHARSET=utf8 \
		-DDEFAULT_COLLATION=utf8_bin"

        local mysql_Tarball=${mysql_Url##*/}
        local mysql_SrcDir=${mysql_Tarball%.tar.*}
        local mysql_Ver=${mysql_SrcDir##*-}
        local mysql_Base=${mysql_SrcDir%-[0-9].*}

        ##############################
        #Main
        ##############################

	####System Prepare
	
        func_WriteEnvVarToBashrc MYSQL MYSQL_PREFIX
	
        mkdir -p $MYSQL_PREFIX
        mkdir -p $APP_DOWNLOAD
        mkdir -p $APP_SRC

	grep mysql /etc/passwd || useradd -r -s /bin/false mysql
	yum -y install cmake ncurses ncurses-devel wget gcc gcc-c++

	####Get MYSQL Tarball
        cd $APP_DOWNLOAD        
        [ -f $mysql_Tarball            ] || wget $mysql_Url
        [ -d $APP_SRC/$mysql_SrcDir    ] || tar axvf $mysql_Tarball -C $APP_SRC
	
	####Compile MYSQL
        cd $APP_SRC/$mysql_SrcDir
	[ -d bld ] || mkdir bld
	cd bld
        make clean &> /dev/null
	$operation && make && make install

	echo $MYSQL_PREFIX/lib >> /etc/ld.so.conf.d/mysql-$mysql_Ver.conf
	ldconfig

        ####Make init Script And init DB
        cd $MYSQL_PREFIX
	chown -R mysql .
	chgrp -R mysql .
	scripts/mysql_install_db --user=mysql --basedir=$MYSQL_PREFIX --datadir=$MYSQL_PREFIX/data
	sleep 2
	chown -R mysql data
	rm -rf etc
	mkdir etc
	cp support-files/my-medium.cnf etc/my.cnf
	rm -rf /etc/my.cnf
	ln -s $MYSQL_PREFIX/etc/my.cnf /etc/my.cnf
	rm -rf /etc/init.d/mysqld
	cp support-files/mysql.server /etc/init.d/mysqld
	chkconfig --add mysqld
	chkconfig --level 35 mysqld on
}
func_InstallPHPFromSource5_5_32() {
        ##############################
        #Set Variables for your prefer
        ##############################
        PHP_PREFIX=/Data/apps/php

        local php_Url=http://cn2.php.net/distributions/php-5.5.32.tar.gz
	local mhash_Url="http://nchc.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz"
	local libmcrypt_Url="http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz"
	local mcrypt_Url="http://nchc.dl.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz"

        local with="$1"
	local opt="--with-apxs2=$APACHE_PREFIX/bin/apxs"
	case $with in 
              apache) opt="--with-apxs2=$APACHE_PREFIX/bin/apxs" ;;
	      nginx)  opt="--enable-fpm --enable-pcntl" ;;
              *)      :;;
        esac
		
        local operation="./configure --prefix=$PHP_PREFIX \
			--with-config-file-path=$PHP_PREFIX/etc \
			$opt \
			--with-mysql=mysqlnd \
			--with-mysqli=mysqlnd \
			--with-pdo-mysql=mysqlnd \
			--enable-ftp \
			--enable-exif \
			--enable-mbstring \
			--enable-shmop \
			--enable-soap \
			--enable-sockets \
			--enable-zip \
			--enable-bcmath \
			--enable-gd-native-ttf \
			--with-gd \
			--with-freetype-dir \
			--with-jpeg-dir \
			--with-png-dir \
			--with-curl \
			--with-openssl \
			--with-mhash \
                        --with-mcrypt=$APP_LIB/libmcrypt \
			--with-xmlrpc \
			--with-zlib \
			--with-bz2 \
			--with-snmp"

        local php_Tarball=${php_Url##*/}
        local php_SrcDir=${php_Tarball%.tar.*}
        local php_Ver=${php_SrcDir##*-}
        local php_Base=${php_SrcDir%-[0-9].*}

        local mhash_Tarball=${mhash_Url##*/}
        local mhash_SrcDir=${mhash_Tarball%.tar.*}
        local mhash_Ver=${mhash_SrcDir##*-}
        local mhash_Base=${mhash_SrcDir%-[0-9].*}

        local libmcrypt_Tarball=${libmcrypt_Url##*/}
        local libmcrypt_SrcDir=${libmcrypt_Tarball%.tar.*}
        local libmcrypt_Ver=${libmcrypt_SrcDir##*-}
        local libmcrypt_Base=${libmcrypt_SrcDir%-[0-9].*}

        local mcrypt_Tarball=${mcrypt_Url##*/}
        local mcrypt_SrcDir=${mcrypt_Tarball%.tar.*}
        local mcrypt_Ver=${mcrypt_SrcDir##*-}
        local mcrypt_Base=${mcrypt_SrcDir%-[0-9].*}

        ##############################
        #Main
        ##############################

	####System Prepare
	
        func_WriteEnvVarToBashrc PHP PHP_PREFIX
	
        mkdir -p $PHP_PREFIX
        mkdir -p $APP_DOWNLOAD
        mkdir -p $APP_SRC

	yum -y install libcurl-devel perl gd zlib \
		freetype libpng libjpeg libxml2-devel \
		openssl-devel bzip2-devel openjpeg-devel \
		libjpeg-turbo-devel libpng-devel freetype-devel \
		wget net-snmp net-snmp-devel
        ####Get mhash Tarball
        cd $APP_DOWNLOAD
        [ -f $mhash_Tarball ] || wget $mhash_Url
        [ -d $APP_SRC/$mhash_SrcDir ] || tar axvf $mhash_Tarball -C $APP_SRC

        ####Get libmcrypt Tarball
        cd $APP_DOWNLOAD
        [ -f $libmcrypt_Tarball ] || wget $libmcrypt_Url
        [ -d $APP_SRC/$libmcrypt_SrcDir ] || tar axvf $libmcrypt_Tarball -C $APP_SRC

        ####Get mcrypt Tarball
        cd $APP_DOWNLOAD
        [ -f $mcrypt_Tarball ] || wget $mcrypt_Url
        [ -d $APP_SRC/$mcrypt_SrcDir ] || tar axvf $mcrypt_Tarball -C $APP_SRC

	####Get PHP Tarball
        cd $APP_DOWNLOAD        
        [ -f $php_Tarball            ] || wget $php_Url
        [ -d $APP_SRC/$php_SrcDir    ] || tar axvf $php_Tarball -C $APP_SRC

         
	
	####Compile mhash
        cd $APP_SRC/$mhash_SrcDir
        make clean &> /dev/null
	./configure --prefix=$APP_LIB/mhash && make && make install
	echo $APP_LIB/mhash/lib > /etc/ld.so.conf.d/mhash.conf

	####Compile libmcrypt
        cd $APP_SRC/$libmcrypt_SrcDir
        make clean &> /dev/null
	./configure --prefix=$APP_LIB/libmcrypt && make && make install
	cd $APP_SRC/$libmcrypt_SrcDir/libltdl
	./configure --prefix=$APP_LIB/libmcrypt --enable-ltdl-install && make && make install
	echo $APP_LIB/libmcrypt/lib > /etc/ld.so.conf.d/libmcrypt.conf
	
	####Compile mcrypt
        cd $APP_SRC/$mcrypt_SrcDir
        make clean &> /dev/null
	./configure --prefix=$APP_LIB/mcrypt && make && make install
	
	####Compile PHP
        cd $APP_SRC/$php_SrcDir
        make clean &> /dev/null
	$operation && make && make install
	cp -f php.ini-production $PHP_PREFIX/etc/php.ini

        if [ "x$1" == "xapache" ];then

		####Write httpd conf.d/php.conf
		{
		 echo '<FilesMatch \.php$>'
		 echo 'SetHandler application/x-httpd-php'
		 echo '</FilesMatch>'
		 echo 'DirectoryIndex index.php'
		} > $APACHE_PREFIX/conf.d/php.conf

	else

		cd $PHP_PREFIX/etc
		cp php-fpm.conf.default php-fpm.conf

        fi


}
func_InstallNginxFromSource1_8_1() {
	##############################
	#Set Variables for your prefer
	##############################
	NGINX_PREFIX=/Data/apps/nginx
	WWW_DIR=/Data/www


	local nginx_Url=http://nginx.org/download/nginx-1.8.1.tar.gz
	local zlib_Url=http://nchc.dl.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz
	local pcre_Url=http://jaist.dl.sourceforge.net/project/pcre/pcre/8.38/pcre-8.38.tar.bz2
	

	##############################
	#Url Analyzing
	##############################
	local nginx_Tarball=${nginx_Url##*/}
	local nginx_SrcDir=${nginx_Tarball%.tar.*}
	local nginx_Ver=${nginx_SrcDir##*-}
	local nginx_Base=${nginx_SrcDir%-[0-9].*}
        
	local zlib_Tarball=${zlib_Url##*/}
	local zlib_SrcDir=${zlib_Tarball%.tar.*}
	local zlib_Ver=${zlib_SrcDir##*-}
	local zlib_Base=${zlib_SrcDir%-[0-9].*}

	local pcre_Tarball=${pcre_Url##*/}
	local pcre_SrcDir=${pcre_Tarball%.tar.*}
	local pcre_Ver=${pcre_SrcDir##*-}
	local pcre_Base=${pcre_SrcDir%-[0-9].*}

	local operation="./configure \
			--prefix=$NGINX_PREFIX \
			--user=nginx \
			--group=nginx \
			--with-pcre=$APP_SRC/$pcre_SrcDir \
			--with-pcre-jit \
			--with-zlib=$APP_SRC/$zlib_SrcDir \
			--with-cc-opt='-O2' \
			--with-http_ssl_module" 


	##############################
	#Main
	##############################
	###System Prepare
	func_WriteEnvVarToBashrc NGINX NGINX_PREFIX WWW_DIR

	mkdir -p $NGINX_PREFIX
	mkdir -p $WWW_DIR
	mkdir -p $APP_DOWNLOAD
	mkdir -p $APP_SRC
	grep nginx /etc/passwd || useradd -r nginx -s /bin/false
	cd $APP_DOWNLOAD
	yum install -y wget
	[ -f $nginx_Tarball  ] || wget $nginx_Url
	[ -f $zlib_Tarball ] || wget $zlib_Url
	[ -f $pcre_Tarball    ] || wget $pcre_Url
	
	[ -d $APP_SRC/$nginx_SrcDir  ] || tar axvf $nginx_Tarball  -C $APP_SRC
	[ -d $APP_SRC/$zlib_SrcDir ] || tar axvf $zlib_Tarball -C $APP_SRC
	[ -d $APP_SRC/$pcre_SrcDir    ] || tar axvf $pcre_Tarball    -C $APP_SRC
	
	
	cd $APP_SRC/$nginx_SrcDir
	make clean &> /dev/null
	$operation &&  make && make install
	
}

func_InstallLAMP() {
 
  func_InstallApacheFromSource2_4_18
  func_InstallMySQLFromSource5_5_47
  func_InstallPHPFromSource5_5_32 apache
 
}
func_InstallLNMP() {
 
  func_InstallNginxFromSource1_8_1
  func_InstallMySQLFromSource5_5_47
  func_InstallPHPFromSource5_5_32 nginx
 
}
echoMenu() {
  clear
  echo "#-------------------------------#"
  echo "#1.Install Apache               #"
  echo "#2.Install Mysql                #"
  echo "#3.Install PHP(with apx2)       #"
  echo "#4.Install PHP(with fpm)        #"
  echo "#5.Install NGINX                #"
  echo "#6.Install LAMP                 #"
  echo "#7.Install LNMP                 #"
  echo "#8.Quit                         #"
  echo "#-------------------------------#"
}

getSelect() {
  local choice=0
  local regularChoice=0
  until [ $regularChoice -eq 1 ]
  do
    echoMenu
    read -n 1 -p"Please Enter Your Choice:" choice
    if [ "x$choice" == "x" ];then
      continue
    else
      regularChoice=`expr match $choice '[1-9]'`
    fi
  done
  echo 
  return $choice
}

####Main
if [ $# -eq 0 ];then

	getSelect


	case $? in
	1   )	func_InstallApacheFromSource2_4_18;;
	2   )	func_InstallMySQLFromSource5_5_47;;
	3   )   func_InstallPHPFromSource5_5_32;;
	4   )   func_InstallPHPFromSource5_5_32 nginx;;
	5   )   func_InstallNginxFromSource1_8_1;;
	6   )   func_InstallLAMP;;
	7   )   func_InstallLNMP;;
	*   )	exit 0 ;;
	esac
else
    until [ "x$1" == "x" ]
    do
	case $1 in
	1   )	func_InstallApacheFromSource2_4_18;;
	2   )	func_InstallMySQLFromSource5_5_47;;
	3   )   func_InstallPHPFromSource5_5_32;;
	4   )   func_InstallPHPFromSource5_5_32 nginx;;
	5   )   func_InstallNginxFromSource1_8_1;;
	6   )   func_InstallLAMP;;
	7   )   func_InstallLNMP;;
	*   )	exit 0 ;;
	esac
	shift
    done
fi
