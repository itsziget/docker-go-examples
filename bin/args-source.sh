if [[ "$#" == "0" ]]; then
  echo "Usage: $0 <source_file> [options ...]"
  echo "<source_file>         is the name of the file in the src directory without the 'go' extension."
  echo "                      Use 'main' to build 'main.go' or 'mainc' to build 'mainc.go'"
  echo
  echo "General options"
  echo "--no-tagged-filename  The name of the generated binary will not be suffixed with the build modes."
  echo "--no-color            Commands will not be colorized"
  echo "--dry-run             Show the build commands without executing them."
  echo
  echo "Go build options"
  echo "--no-cgo              Set CGO_ENABLED=0 to disable CGO."
  echo "--no-debug            Do not generate DWARF symbols into the binary."
  echo "--no-symbol-table     Do not generate symbol table at all into the binary"
  echo "--static              Generate required libraries into the binary instead of using them from the OS."
  echo "--timetzdata          Generate timezone data into the binary like UTC or Europe/Budapest"

  exit 0
fi

source_file="$1"
shift 1

ldflags=""
tags=""
outname="build/$(basename $source_file)"
outname_suffix=""
dry_run=0
no_color=0
no_tagged_filename=0

for i in "$@"; do
  case $i in
    --no-cgo)
      export CGO_ENABLED=0
      outname_suffix+="-cgo0"
      ;;
    --no-debug)
      ldflags+="-w "
      outname_suffix+="-debug0"
      ;;
    --no-symbol-table)
      ldflags+="-s "
      outname_suffix+="-st0"
      ;;
    --static)
      ldflags+='-extldflags "-static" '
      outname_suffix+="-static"
      ;;
    --timetzdata)
      tags="timetzdata"
      outname_suffix+="-tz"
      ;;
    --dry-run)
      dry_run=1
      ;;
    --no-color)
      no_color=1
      ;;
    --no-tagged-filename)
      no_tagged_filename=1
      ;;
  esac
done

if [[ "$no_tagged_filename" == "0" ]]; then
  outname+="$outname_suffix"
fi

go_build_command=(go build -o $outname)

if [[ -n "$ldflags" ]]; then
  go_build_command+=(-ldflags "$ldflags")
fi
if [[ -n "$tags" ]]; then
  go_build_command+=(-tags "$tags")
fi
go_build_command+=("src/$source_file.go")
go_build_command_full=("${go_build_command[@]}")
if [[ "${CGO_ENABLED:-}" != "" ]]; then
  go_build_command_full=(CGO_ENABLED=$CGO_ENABLED "${go_build_command[@]}")
fi

function show_command() {
  : ${no_color:-0}

  for i in "${@}"; do
    if [[ "$i" == *" "* ]]; then
      i="'$i'"
      if [[ "$no_color" == "0" ]]; then
        i="\e[36m$i"
      fi
    fi
    if [[ "$no_color" == "0" ]]; then
      i="\e[33m$i"
    fi
    echo -n -e "${i} "
  done
  if [[ "$no_color" == "0" ]]; then
    echo -e "\e[0m" 
  fi
}