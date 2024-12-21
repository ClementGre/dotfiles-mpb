#!/bin/zsh

echo " -> Setting file associations for SublimeText..."

# List of text-based file extensions to associate with Sublime Text
extensions=("txt" "md" "html" "htm" "xml" "css" "js" "ts" "json" "c" "cpp" "h" "hpp" "hxx" "cxx" "cc" "java" "vue" "py" "rb" "pl" "sh" "bash" "ps1" "psm1" "f" "for" "f90" "f95" "f03" "f08" "s" "asm" "sln" "vcxproj" "cs" "vb" "fs" "fsi" "fsx" "idl" "odl" "php" "shtml" "php3" "php4" "php5" "php7" "phtml" "ctp" "twig" "jsp" "jspx" "cfm" "cfc" "dhtml" "xhtml" "jhtml" "erb" "rhtml" "htaccess" "htpasswd" "conf" "ini" "yaml" "yml" "toml" "toc" "mdown" "mkdn" "mdwn" "mdtxt" "mdtext" "textile" "rst" "rs" "properties" "stl" "sql" "csv" "tsv" "tab" "log" "cfg" "reg" "manifest" "bat" "cmd" "pem" "asc" "key" "pub" "xml.dist" "jsonld" "n3" "ttl" "trig" "rq" "sparql" "rq.in" "rq.out" "rq.result" "yaml-tmlanguage" "xsl" "xslt" "xul" "xbl" "xaml" "xsd" "wsdl" "bib" "en" "tex" "sty" "cls" "bbx" "cbx" "lbx" "m" "webmanifest" "iml" "swift" "plist" "mailsignature" " entitlements" "lst" "ir" "plist" "gitignore" "obj" )

for extension in "${extensions[@]}"
do
    duti -s com.sublimetext.4 ".$extension" all
done

echo " -> Setting file associations for IINA..."

extensions=("mp4" "mkv" "avi" "mov" "wmv" "flv" "webm" "mpeg")

for extension in "${extensions[@]}"
do
    duti -s com.colliderli.iina ".$extension" all
done
