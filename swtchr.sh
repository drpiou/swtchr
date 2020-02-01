#!/usr/bin/env bash

# https://github.com/drpiou/swtchr
# 0.0.2 - 2020-02-01
#
# This script allows you the run different version of bin in specific folders.



##### Constants

CONFIG_FILE=.swtchr
CONFIG_BASE="$HOME/$CONFIG_FILE"

SEMVER_FILE=swtchr.semver.sh
SEMVER_URL=https://raw.githubusercontent.com/drpiou/swtchr/master/semver.sh



##### Functions

_usage()
{
   echo ""
   echo "Usage: switchr <command>"
   echo ""
   echo -e "\t<command>\t The command to execute (eg: 'composer require tbnt/cms')"
   echo -e "\t-l\t\t The bin platform (optional - used for config file override)"
   echo -e "\t-p\t\t The bin path (required)"
   echo -e "\t-f\t\t The bin binaries folder (optional - default to '/')"
   echo -e "\t-b\t\t The bin to execute (required)"
   echo -e "\t-k\t\t The fallback bin to execute if no version found (optional)"
   echo -e "\t-s\t\t The version to find (optional - Semantic Versioning)"
   echo -e "\t-d\t\t Debug the selected bin path"
   echo -e "\t-v\t\t Debug (verbose) the selected bin path"
   echo -e "\t-h\t\t Print help"
   echo ""
}

_usage_exit()
{
   _usage
   exit 1
}



#### Help

while getopts "h=1" opt
do
    case "$opt" in
        h ) _usage_exit ;;
        ? ) _usage_exit ;;
    esac
done



##### Params

command=
platform=

params_path=
params_folder=
params_bin=
params_fallback=
params_version=
params_debug=
params_verbose=

if [[ -n "$1" ]]; then
    command=

    while [[ -n "$1" ]]; do
        if [[ "$1" =~ ^\-.* ]]; then
            break;
        fi

        if [[ -z "$command" ]]; then
            command="$1"
        else
            command="$command $1"
        fi

        shift
    done
fi

while getopts "l:p:f:b:k:s:d=1:v=1:h=1" opt
do
    case "$opt" in
        l ) platform="$OPTARG" ;;
        p ) params_path="$OPTARG" ;;
        f ) params_folder="$OPTARG" ;;
        b ) params_bin="$OPTARG" ;;
        k ) params_fallback="$OPTARG" ;;
        s ) params_version="$OPTARG" ;;
        d ) params_debug=1 ;;
        v ) params_verbose=1 ;;
        h ) _usage ;;
        ? ) ;;
    esac
done



##### Config

user_path=
user_folder=
user_bin=
user_fallback=
user_version=
user_debug=
user_verbose=

local_path=
local_folder=
local_bin=
local_fallback=
local_version=
local_debug=
local_verbose=

if [[ -e $CONFIG_BASE ]]; then
    while read line; do
        if [[ -n $line ]]; then
            key="$(sed 's/=.*//' <<< "$line")"
            value="$(sed 's/^[^=]*=//' <<< "$line")"

            if [[ -n $value ]]; then
                case "$key" in
                    default.platform ) platform="$value" ;;
                    default.path ) user_path="$value" ;;
                    default.folder ) user_folder="$value" ;;
                    default.bin ) user_bin="$value" ;;
                    default.fallback ) user_fallback="$value" ;;
                    default.version ) user_version="$value" ;;
                    default.debug ) user_debug="$value" ;;
                    default.verbose ) user_verbose="$value" ;;
                    ? ) ;;
                esac

                if [[ -n $platform ]]; then
                    case "$key" in
                        "${platform}.path" ) user_path="$value" ;;
                        "${platform}.folder" ) user_folder="$value" ;;
                        "${platform}.bin" ) user_bin="$value" ;;
                        "${platform}.fallback" ) user_fallback="$value" ;;
                        "${platform}.version" ) user_version="$value" ;;
                        "${platform}.debug" ) user_debug="$value" ;;
                        "${platform}.verbose" ) user_verbose="$value" ;;
                        ? ) ;;
                    esac
                fi
            fi
        fi
    done < "$CONFIG_BASE"
fi

if [[ -f $CONFIG_FILE ]]; then
    while read line; do
        if [[ -n $line ]]; then
            key="$(sed 's/=.*//' <<< "$line")"
            value="$(sed 's/^[^=]*=//' <<< "$line")"

            if [[ -n $value ]]; then
                case "$key" in
                    default.platform ) platform="$value" ;;
                    default.path ) local_path="$value" ;;
                    default.folder ) local_folder="$value" ;;
                    default.bin ) local_bin="$value" ;;
                    default.fallback ) local_fallback="$value" ;;
                    default.version ) local_version="$value" ;;
                    default.debug ) local_debug="$value" ;;
                    default.verbose ) local_verbose="$value" ;;
                    ? ) ;;
                esac

                if [[ -n $platform ]]; then
                    case "$key" in
                        "${platform}.path" ) local_path="$value" ;;
                        "${platform}.folder" ) local_folder="$value" ;;
                        "${platform}.bin" ) local_bin="$value" ;;
                        "${platform}.fallback" ) local_fallback="$value" ;;
                        "${platform}.version" ) local_version="$value" ;;
                        "${platform}.debug" ) local_debug="$value" ;;
                        "${platform}.verbose" ) local_verbose="$value" ;;
                        ? ) ;;
                    esac
                fi
            fi
        fi
    done < "$CONFIG_FILE"
fi



##### Vars

if [[ -n "$params_path" && -d $params_path ]]; then
    path=$params_path
elif [[ -n "$local_path" && -d $local_path ]]; then
    path=$local_path
elif [[ -n "$user_path" && -d $user_path ]]; then
    path=$user_path
else
    echo "abort: path '$path' not found".
    echo ""
    exit
fi

if [[ -n "$params_folder" ]]; then
    folder=$params_folder
elif [[ -n "$local_folder" ]]; then
    folder=$local_folder
elif [[ -n "$user_folder" ]]; then
    folder=$user_folder
else
    folder="/"
fi

if [[ -n "$params_bin" ]]; then
    bin=$params_bin
elif [[ -n "$local_bin" ]]; then
    bin=$local_bin
elif [[ -n "$user_bin" ]]; then
    bin=$user_bin
else
    echo "abort: bin '$bin' is empty".
    echo ""
    exit
fi

if [[ -n "$params_fallback" && -f $params_fallback ]]; then
    fallback=$params_fallback
elif [[ -n "$local_fallback" && -f $local_fallback ]]; then
    fallback=$local_fallback
elif [[ -n "$user_fallback" && -f $user_fallback ]]; then
    fallback=$user_fallback
else
    fallback="/$path/$folder/$bin"
fi

fallback=`echo $fallback | sed 's.//*./.g'`

if [[ -n "$params_version" ]]; then
    version=$params_version
elif [[ -n "$local_version" ]]; then
    version=$local_version
elif [[ -n "$user_version" ]]; then
    version=$user_version
else
    version=
fi

if [[ -n "$params_debug" ]]; then
    debug=$params_debug
elif [[ -n "$local_debug" ]]; then
    debug=$local_debug
elif [[ -n "$user_debug" ]]; then
    debug=$user_debug
else
    debug=
fi

if [[ -n "$params_verbose" ]]; then
    verbose=$params_verbose
elif [[ -n "$local_verbose" ]]; then
    verbose=$local_verbose
elif [[ -n "$user_verbose" ]]; then
    verbose=$user_verbose
else
    verbose=
fi

##### Main

if [[ "$verbose" == "1" ]]; then
    echo -e "command:\t$command"
    echo -e "platform:\t$platform"
    echo -e "path:\t\t$path"
    echo -e "folder:\t\t$folder"
    echo -e "bin:\t\t$bin"
    echo -e "fallback:\t$fallback"
    echo -e "version:\t$version"
    echo ""
fi

if [[ ! -f "$(dirname $0)/$SEMVER_FILE" ]]; then
    echo "downloading dependencies..."
    echo ""

    curl "$SEMVER_URL" > "$(dirname $0)/$SEMVER_FILE"
    chmod u+x "$(dirname $0)/$SEMVER_FILE"

    echo ""
    echo "done!"
    echo ""
fi

bin_path=$fallback
bin_version=
header=

if [[ -n "$version" ]]; then
    for d in $path/* ; do
        if [[ -d $d ]]; then
            [[ $d =~ ([0-9\.]+) ]]

            found=${BASH_REMATCH[1]}

            if [[ -n "$found" ]]; then
                debug_satisfiable=0
                debug_found=0

                test=`$(dirname $0)/$SEMVER_FILE -r "$version" $found | tail -1`

                if [[ -n "$test" ]]; then
                    debug_satisfiable=1

                    if [[ -n "$bin_version" ]]; then
                        test=`$(dirname $0)/$SEMVER_FILE -r "<=$test" $bin_version | tail -1`
                    fi

                    if [[ -n "$test" ]]; then
                        if [[ -f $d/$folder/$bin ]]; then
                            bin_path=`echo "$d/$folder/$bin" | sed 's.//*./.g'`
                        fi

                        bin_version=$test
                        debug_found=1
                    fi
                fi

                if [[ "$verbose" == "1" ]]; then
                    if [[ -z "$header" ]]; then
                        printf "%-12s | %-12s | %-10s | %-12s | %s" "search" "satisfiable" "found" "parsed" "directory"
                        echo ""
                        header=1
                    fi

                    printf "%-12s | %-12s | %-10s | %-12s | %s" "$version" "$debug_satisfiable" "$debug_found" "$found" "$d"
                    echo ""
                fi
            fi
        fi
    done

    if [[ "$verbose" == "1" ]]; then
        if [[ "$header" == "1" ]]; then
            echo ""
        fi

        if [[ ! -f "$bin_path" ]]; then
            echo "warning: no bin '$bin_path' found."
            echo ""
        fi

        if [[ -z "$bin_version" ]]; then
            echo "warning: no satisfiable $platform version found."
            echo ""
        fi
    fi
fi

if [[ ! -f $bin_path ]]; then
    echo "abort: fallback '$fallback' not found".
    echo ""
    exit
fi

if [[ "$verbose" == "1" || "$debug" == "1" ]]; then
    if [[ "$verbose" != "1" ]]; then
        echo ""
    fi

    echo "swtchr: $bin_path"
    echo ""
fi

$bin_path $command
