#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Bash - Library - Cryptography v201507100702
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/lib/crypto

Example usage:
source "crypto.bash"
echo "`cryptoHashCalc md5 string 'Hello World'`"
echo "`cryptoHashCalc sha1 file '/etc/hosts'`"

!COMMENT

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

# Generate password
# Example usage:
# echo "`cryptoGenPass [length] [tr format]`"
function cryptoGenPass() {

	#----- Variables
	local LENGTH=${1-40}
	local FILTER=${2-'[:print:]'}
	local OPENSSL=true
	hash openssl 2>/dev/null || { OPENSSL=false; }
	#-----/Variables

	#----- Main
	if [ "$OPENSSL" == true ]; then
		(openssl enc '-aes-256-cbc' -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt < /dev/zero | env LC_CTYPE=C tr -dc "$FILTER" | head -c "$LENGTH") 2>/dev/null
	else
		cat /dev/urandom | env LC_CTYPE=C tr -dc "$FILTER" | head -c "$LENGTH"
	fi
	#-----/Main

} # END FUNCTION: GENERATE PASSWORD

function cryptoHashCandidate() {
	local hash="${1-md5}"
	hash="$( echo "$hash" | tr '[:upper:]' '[:lower:]' )"

	if hash "${hash}sum" 2>/dev/null; then
		hashpath="`type -p ${hash}sum`"
		
	elif hash "${hash}" 2>/dev/null; then
		hashpath="`type -p $hash`"

	elif hash gpg 2>/dev/null; then
		hashpath="`type -p gpg` --print-md ${hash}"

	elif hash openssl 2>/dev/null; then
		hashpath="`type -p openssl` dgst -${hash}"

	else
		hashpath=''

	fi

	echo -n "$hashpath"
} # END FUNCTION: HASH CANDIDATE

function cryptoHashCandidatePost() {
	local hash=${1-md5}
	hash="$( echo "$hash" | tr '[:upper:]' '[:lower:]' )"

	if hash "${hash}sum" 2>/dev/null; then
		hashpostargs="cut -d' ' -f1"
		
	elif hash "${hash}" 2>/dev/null; then
		hashpostargs="cut -d' ' -f1"

	elif hash gpg 2>/dev/null; then
		hashpostargs="sed 's/ //g' | tr '[:upper:]' '[:lower:]' | tr -d '(\n|\r)'"

	elif hash openssl 2>/dev/null; then
		hashpostargs='cat'

	else
		hashpostargs=''

	fi

	echo -n "$hashpostargs"
} # END FUNCTION: HASH CANDIDATE

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
	hashpath=`cryptoHashCandidate "$hash"`
	hashpostargs=`cryptoHashCandidatePost "$hash"`
	#-----/Find program, and arguments

	#----- Doesn't exist
	if [ -z "$hashpath" ]; then
		echo -n ''
		exit 1;
	fi
	#-----/Doesn't exist

	#----- Calculate Hash
	case "$method" in
		string)
			echo -n "$request" | eval "$hashpath" | eval "$hashpostargs"
			;;

		file)
			eval "$hashpath" <"$request" | eval "$hashpostargs"
			;;

		test)
			echo -n "Testing." | eval "$hashpath" 2>&1 1>/dev/null
	esac
	#-----/Calculate Hash

} # END FUNCTION: HASH CALCULATION
