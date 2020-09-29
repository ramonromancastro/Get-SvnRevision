#!/bin/bash

# Get-SvnRevision.sh - Retrieve files from Subversion Repository (full, individual or changes)
# Copyright (C) 2013 Ramon Roman Castro <info@rrc2software.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Author: Ramon Roman Castro
# Web   : http://www.rrc2software.com
# Email : info@rrc2software.com

#--------------------------------------------------------------------------------------
# VARIABLES
#--------------------------------------------------------------------------------------

script_name=Get-SvnRevision
script_version=1.59
svn_error=0
svn_binpath=$(which svn 2>/dev/null)
svn_scriptname=$(basename $(readlink --canonicalize --no-newline $0))
svn_scriptname=${svn_scriptname%.*}
export_types=(full changes individual)
check_parameters=0

svn_repo=
svn_rev=
svn_type="full"
svn_user=
svn_pass=
deploy_path=
batch_execution=

httpd_root=$(httpd -V | grep "HTTPD_ROOT="".*""" | awk -F "=" '{ print $2 }' | tr -d '"')
httpd_config=$(httpd -V | grep "SERVER_CONFIG_FILE="".*""" | awk -F "=" '{ print $2 }' | tr -d '"')
httpd_config=${httpd_root}/${httpd_config}

if [ -f $httpd_config ]; then
	httpd_user=$(grep -oi "^[[:space:]]*User[[:space:]]\+\(.\+\)$" /etc/httpd/conf/httpd.conf | awk '{ print $2 }')
	httpd_group=$(grep -oi "^[[:space:]]*Group[[:space:]]\+\(.\+\)$" /etc/httpd/conf/httpd.conf | awk '{ print $2 }')
fi

httpd_user=${httpd_user:-apache}
httpd_group=${httpd_user:-apache}

#--------------------------------------------------------------------------------------
# CONFIGURATION
#--------------------------------------------------------------------------------------

exclude_files=(Thumbs.db .project .settings .buildpath)
exclude_folders=(sql _notes)
svn_output=$svn_scriptname.export
svn_outputscript=$svn_scriptname.export.sh
svn_outputtargz=$svn_scriptname.export.tar.gz

#--------------------------------------------------------------------------------------
# FUNTIONS
#--------------------------------------------------------------------------------------

# checkError()
# Print error, remove output files and exit
exitScript()
{
	rm $svn_output -Rf > /dev/null 2>&1
	exit $1
}

checkError()
{
	if [ $? -ne 0 ]; then
		echo -e "[\033[0;31m ERROR \033[0m]"
		exitScript 1
	fi
}

print_id(){
	case $1 in
		"M")
			echo -ne "    [\e[36m$1\e[0m]"
			;;
		"A")
			echo -ne "    [\e[32m$1\e[0m]"
			;;
		"D")
			echo -ne "    [\e[33m$1\e[0m]"
			;;
		*)
	esac
	echo " $2"
}

# getFull()
# Retrieve a copy of subversion repository up to revision number
getFull()
{
	echo $svn_repo
	svn export --non-interactive --trust-server-cert --username="$svn_user" --password="$svn_pass" --force -r $svn_rev $svn_repo $svn_output
	checkError
}

# getIndividual()
# Retrieve a copy of subversion repository of changes maded in revision number
getIndividual()
{
	#for i in $(svn log -qv -r $svn_rev $svn_repo | awk '/[DMA][ ]+\//{ print $1$2 }'); do
	OLD_IFS=$IFS
	IFS=$'\n'
	for i in $(svn log --non-interactive --trust-server-cert --username="$svn_user" --password="$svn_pass" -qv -r $svn_rev $svn_repo | awk '/^[ ]+[DMA][ ]+\//{ print gensub(/[ ]+([DMA])[ ]+/,"\\1","g",$0)}'); do
		o=${i:0:1}
		p=${i:1}
		l=$(basename $svn_repo)
		p=${p#/$l/}
		pescape=$(echo ${p} | sed 's/\(.*@.*\)/\1@/')
		print_id "$o" "$p"
		#echo "    [$o] $p"
		if [ "$o" != "D" ]; then
			mkdir -p $svn_output/$(dirname $p) > /dev/null 2>&1
			svn export --non-interactive --trust-server-cert --username=$svn_user --password=$svn_pass --force -r $svn_rev $svn_repo/$pescape $svn_output/$p > /dev/null 2>&1
			checkError
		else
			echo "rm \".$p\" -Rf" >> $svn_outputscript
		fi
	done
	IFS=$OLD_IFS
}

# getChanges()
# Retrieve a copy of subversion repository of changes maded between to revision numbers
getChanges()
{
	svn_rev_last=$(echo $svn_rev | awk 'BEGIN{FS=":"}{ print $2 }')
	svn_repo_l=${#svn_repo}
	let svn_repo_l++
	#for i in $(svn diff -r $svn_rev --summarize $svn_repo | awk '/[DMA][ ]+/{ print $1$2 }'); do
	OLD_IFS=$IFS
	IFS=$'\n'
	for i in $(svn diff --non-interactive --trust-server-cert --username="$svn_user" --password="$svn_pass" -r $svn_rev --summarize $svn_repo | awk '/^[DMA][ ]+/{ print gensub(/([DMA])[ ]+/,"\\1","g",$0)}'); do
		o=${i:0:1}
		p=${i:$svn_repo_l}
		pescape=$(echo ${p} | sed 's/\(.*@.*\)/\1@/')
		print_id "$o" "$p"
		#echo "    [$o] $p"
		if [ "$o" != "D" ]; then
			if [ "$p" != "" ]; then
				#<r1.51>
				look=$(svn log --non-interactive --trust-server-cert --username="$svn_user" --password="$svn_pass" -q ${svn_repo}/${pescape}@${svn_rev_last} | awk '{ if (NR==2) print $1 }' | tr -d 'r')
				#</r1.51>
				mkdir -p $svn_output/$(dirname $p) > /dev/null 2>&1
				svn export --non-interactive --trust-server-cert --username="$svn_user" --password="$svn_pass" --force -r $svn_rev_last $svn_repo/${pescape}@${look} $svn_output/$p > /dev/null 2>&1
				checkError
			fi
		else
			echo "rm \".$p\" -Rf" >> $svn_outputscript
		fi
	done
	IFS=$OLD_IFS
}

# summary()
# Print script summary
summary()
{
cat << EOF
Repository URL  : $svn_repo
Export type     : $svn_type
Revision number : $svn_rev
Auto-deploy dir : $deploy_path
EOF
}

# usage()
# Print script usage
usage()
{
cat << EOF
usage: ${script_name}.sh options

OPTIONS:
    -U|--url          Repository URL
    -t|--type         Export type, can be 'full', 'individual' or 'changes' (Default: full)
    -r|--revision     Revision number, can be N or N:M
    -u|--username     Repository username
    -p|--password     Repository password [optional]
    -d|--deploy-path  Absolute deploy path [optional]
    -b|--batch        Non interactive execution [optional]
   
NOTES:
    - All directories (${exclude_folders[@]}) are removed on destination directory by this script
    - All files (${exclude_files[@]}) are removed on destination directory by this script
    - Export type 'individual' only works from repository base or first level directory.

EOF
	exitScript 1
}

check_svn_connectivity(){
	svn info --non-interactive --trust-server-cert --username="$svn_user" --password="$svn_pass" "$svn_repo" > /dev/null 2>&1
	return $?
}

result_usage(){
	echo
	echo "---------------------------------------------------------"
	echo "To use the result of this script,"
	echo "    cp $svn_output.* <destination_directory>"
	echo "    cd <destination_directory>"
	echo "    ./$svn_outputscript"
	echo "---------------------------------------------------------"
	echo
}

print_license(){
	echo "${script_name}.sh version ${script_version}, Copyright (C) 2018  Ramón Román Castro <ramonromancastro@gmail.com>"
	echo "This program comes with ABSOLUTELY NO WARRANTY; for details read LICENSE file."
	echo "This is free software, and you are welcome to redistribute it"
	echo "under certain conditions; read LICENSE file for details."
	echo
}

read_params(){
	while [[ $# -gt 0 ]]; do
		key="$1"
		case $key in
			-U|--url)
				svn_repo="$2"
				shift
				;;
			-r|--revision)
				svn_rev="$2"
				shift
				;;
			-t|--type)
				svn_type="$2"
				shift
				;;
			-u|--username)
				svn_user="$2"
				shift
				;;
			-p|--password)
				svn_pass="$2"
				shift
				;;
			-b|--batch)
				batch_execution=1
				;;
			-d|--deploy-path)
				deploy_path="$2"
				shift
				LEN=${#deploy_path}-1
				if [ "${deploy_path:LEN}" != "/" ]; then deploy_path=$deploy_path"/"; fi
				;;
			*)
				usage
				;;
		esac
		shift
	done
}

#######################################################################################
# MAIN CODE
#######################################################################################

print_license

# Load default config
if [ -f ${script_name}.conf ]; then
	. ${script_name}.conf
fi

# Check prerrequisites
if [ "$svn_binpath" == "" ]; then
	echo -e "\033[33mWarning: Subversion client not found\nSubversion package must be installed\nIf not installed, execute:\n\tyum install subversion\033[0m"
	exitScript 1
fi

# Read arguments
read_params "$@"

# Check arguments
if [[ -z $svn_repo ]] || [[ -z $svn_rev ]] || [[ -z $svn_type ]] || [[ -z $svn_user ]]; then
	usage
fi

# Check auto-deploy
if [ ! -z "$deploy_path" ]; then
	if [[ ! "$deploy_path" =~ ^/ ]]; then
		echo -e "\033[33mWarning: Auto-deploy dir must be absolute!\033[0m"
		usage
	fi
	if [ ! -d "$deploy_path" ]; then
		echo -e "\033[33mWarning: Auto-deploy dir [$deploy_path] not found!\033[0m"
		exitScript 1
	fi
fi

# Read SVN Password
if [ -z $svn_pass ]; then
	echo -n "Password: "
	read -s svn_pass
	echo
fi

check_parameters=0
for i in ${export_types[@]}; do
	if [[ "$i" == "$svn_type" ]] ; then
		check_parameters=1
		break
	fi;
done

if [[ $check_parameters -eq 0 ]]; then
	usage
fi

# Print summary
summary

# Remove old output files
echo "Removing old files ... "
rm $svn_outputtargz -Rf > /dev/null 2>&1
checkError

rm $svn_output -Rf > /dev/null 2>&1
checkError

mkdir $svn_output > /dev/null 2>&1
checkError

echo "Checking SVN connectivity ... "
check_svn_connectivity
checkError

# Creating SH file
echo "Initializing SH file ... "
echo "#!/bin/bash" > $svn_outputscript
checkError

# Subversion Repository export
echo "Executing EXPORT ... "
case "$svn_type" in
	"full")
		getFull
		;;
	"individual")
		echo -e "\033[33m[ ADVISE ]\033[0m individual export is DISABLED."
		exitScript 1
		#getIndividual
		;;
	"changes")
		getChanges
		;;
	*)
		usage
esac

# Configure SH file
echo "Configuring SH file ... "

echo "echo ""Changing umask to 0027""" >> $svn_outputscript
echo 'old_umask=$(umask)' >> $svn_outputscript
echo "umask 0027" >> $svn_outputscript

echo "echo ""Extracting $svn_outputtargz""" >> $svn_outputscript
echo "tar xvzf $svn_outputtargz --no-same-permissions --no-overwrite-dir" >> $svn_outputscript
checkError

echo "echo ""Removing $svn_outputtargz""" >> $svn_outputscript
echo "rm $svn_outputtargz -f " >> $svn_outputscript
checkError

echo "echo ""Removing $svn_outputscript""" >> $svn_outputscript
echo "rm $svn_outputscript -f " >> $svn_outputscript
checkError

echo "echo ""Updating .revision file""" >> $svn_outputscript
echo "if [ ! -f .revision ]; then echo \"Datetime,Operation,Revision,Source,Username\" >> .revision; fi" >> $svn_outputscript
checkError

echo "echo ""$(date +%Y/%m/%d),$(date +%H:%M),$svn_type,$svn_rev,$svn_repo,$svn_user"" >> .revision" >> $svn_outputscript
checkError

for pattern in ${exclude_folders[@]}; do
	echo "echo ""Removing $pattern directories""" >> $svn_outputscript
	echo "find . -name \"$pattern\" -type d -exec rm -rf {} \;" >> $svn_outputscript
	checkError
done

for pattern in ${exclude_files[@]}; do
	echo "echo ""Removing $pattern files""" >> $svn_outputscript
	echo "find . -name \"$pattern\" -type f -exec rm -rf {} \;" >> $svn_outputscript
	checkError
done

echo 'echo "Restoring umask to $old_umask"' >> $svn_outputscript
echo 'umask $old_umask' >> $svn_outputscript

echo 'echo "Changing dir ownership"' >> $svn_outputscript
echo "chown ${httpd_user}:${httpd_group} . -R" >> $svn_outputscript

#echo "echo ""Changing permissions on all files to 640""" >> $svn_outputscript
#echo "find . -type f -exec chmod 640 {} \;" >> $svn_outputscript
#checkError

#echo "echo ""Changing permissions on all directories to 750""" >> $svn_outputscript
#echo "find . -type d -exec chmod 750 {} \;" >> $svn_outputscript
#checkError

chmod +x $svn_outputscript > /dev/null 2>&1
checkError

# Generate TAR.GZ file
echo "Creating TAR.GZ file ... "
tar cvzf $svn_outputtargz -C $svn_output . > /dev/null 2>&1
checkError

echo "Removing temporal files ... "
rm $svn_output -Rf > /dev/null 2>&1
checkError

# Print end message

# Auto-deploy
if [ ! -z "$deploy_path" ]; then
	if [ -d "$deploy_path" ]; then
		if [ ! -s "$batch_execution" ]; then
			response='s'
		else
			read -r -p "¿Esta seguro que desea desplegar automaticamente en el directorio [$deploy_path]? [s/N] " response
		fi
		case "$response" in
			y|Y|s|S)
				echo -n "Copying files to auto-deploy dir ... "
				mv -f $svn_output.* "$deploy_path"
				checkError
				echo -n "Changing current directory ... "
				cd "$deploy_path"
				checkError
				echo "Executing deployment script ... "
				./$svn_outputscript
				checkError
				;;
			*)
				result_usage
				;;
		esac
	else
		result_usage
	fi
else
	result_usage
fi

echo -e "\033[33mThis script set umask to 0027 on extracted files, so if website have special permissions, you have to set them.\033[0m"

exitScript 0
