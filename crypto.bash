#!/usr/bin/env bash
#
# GGCOM - Bash - Library - Cryptography v201503030304
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/lib/crypto
#
# Example usage:
# source "crypto.bash"
# echo "`cryptoHashCalc md5 string 'Hello World'`"
# echo "`cryptoHashCalc sha1 file '/etc/hosts'`"

# List Support
function cryptoSupport() {

#	echo "[OpenSSL File]"
#	/usr/bin/openssl sha1 FILE;
#	
#	echo "[OpenSSL String]"
#	cat FILE | /usr/bin/openssl sha1;
#	
#	echo "[Hash.Bash File]"
#	./hash.bash sha1 FILE;
#	
#	echo "[Hash.Bash String]";
#	cat FILE | ./hash.bash sha1

	false
} # END FUNCTION: CRYPTO SUPPORT

# Calculate hash
# Example usage:
# echo "`cryptoHashCalc [md5|sha1|..] [string|file] '/etc/hosts'`"
function cryptoHashCalc() {
	local hash=${1-md5}
	local method=${2-string}
	local request=${3-''}
	
	local hashpath=''
	local hashpostargs=''

	#----- Find program, and arguments
	if hash "${hash}sum" 2>/dev/null; then
		hashpath="`type -p ${hash}sum`"
		hashpostargs="cut -d' ' -f1"
		
	elif hash "${hash}" 2>/dev/null; then
		hashpath="`type -p $hash`"
		hashpostargs="cut -d' ' -f1"

	elif hash gpg 2>/dev/null; then
		hashpath="`type -p gpg` --print-md ${hash}"
		hashpostargs="sed 's/ //g' | tr '[:upper:]' '[:lower:]' | tr -d '(\n|\r)'"

	elif hash openssl 2>/dev/null; then
		hashpath="`type -p openssl` dgst -${hash}"
		hashpostargs='cat'

	else
		hashpath=''
		hashargs=''

	fi
	#-----/Find program, and arguments

	#----- Doesn't exist
	if [ -z "$hashpath" ]; then
		echo -n ''
		exit 1;
	fi
	#-----/Doesn't exist

	#----- Calculate Hash
	case $method in
		string)
			echo -n "$request" | eval "$hashpath" | eval "$hashpostargs"
			;;

		file)
			eval "$hashpath" <$request | eval "$hashpostargs"
			;;
	esac
	#-----/Calculate Hash

} # END FUNCTION: HASH CALCULATION