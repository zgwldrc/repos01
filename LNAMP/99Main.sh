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
