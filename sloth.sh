echo "Target:" $1

outputpath=./result/$1
subfinderpath=./Tools/subfinder/subfinder
subfinderpcpath=./Config/provider-config.yaml
ctfrpath=./Tools/ctfr/ctfr.py
dnsdicpath=./Config/alldns.txt
resolverspath=./Config/resolvers.txt
httpxpath=./Tools/httpx/httpx
nucleipath=./Tools/nuclei/nuclei
nucleitemplatespath=./Config/nuclei-templates
naabupath=./Tools/naabu/naabu
nucleiblack="dns-waf-detect,cors-misconfig,options-method,txt-fingerprint,cname-fingerprint,email-extractor,addeventlistener-detect,http-missing-security-headers,deprecated-tls,nginx-status,apache-detect,ssl-dns-names,waf-detect,expired-ssl,HTTP-TRACE,tech-detect,tomcat-exposed-docs,tls-version,default-openresty,nginx-version,old-copyright,default-nginx-page,nameserver-fingerprint"


mkdir $outputpath
# subfinder
$subfinderpath -pc $subfinderpcpath -all -nc -silent -d $1 -o $outputpath/domain_$1.txt
# ctfr
# git clone https://github.com/UnaPibaGeek/ctfr.git
python3 $ctfrpath -d $1 -o $outputpath/ctfr_$1.txt
sort $outputpath/ctfr_$1.txt | uniq | sed '/*/d' >> $outputpath/domain_$1.txt
# puredns 
# git clone https://github.com/blechschmidt/massdns.git
# cd massdns
# make
# sudo make install
# go install github.com/d3mondev/puredns/v2@latest
puredns bruteforce $dnsdicpath $1 -r $resolverspath > $outputpath/dns_$1.txt
sort $outputpath/dns_$1.txt | uniq >> $outputpath/domain_$1.txt
# cleandomain
sort $outputpath/domain_$1.txt | uniq | puredns resolve -q -r $resolverspath --write $outputpath/domain_$1.txt
# naabu
naabupath -list $outputpath/domain_$1.txt -ec -tp 1000 -nmap-cli 'nmap -sV' -o $outputpath/portscan_$1.txt
# httpx
cat $outputpath/domain_$1.txt | $httpxpath -ip -title -cname  -ports 80,443,8080,8443,7001,8081 -follow-host-redirects -location -no-color -random-agent -silent -web-server -status-code -tech-detect -o $outputpath/httpx-$1.txt
awk '{print $1}' $outputpath/httpx-$1.txt > $outputpath/scanurl.txt
# nuclei
$nucleipath -l  $outputpath/scanurl.txt -t $nucleitemplatespath -eid email-extractor,addeventlistener-detect,http-missing-security-headers,deprecated-tls,nginx-status,apache-detect,ssl-dns-names,waf-detect,expired-ssl,HTTP-TRACE,tech-detect,tomcat-exposed-docs,tls-version,default-openresty,nginx-version,old-copyright,default-nginx-page,nameserver-fingerprint -o $outputpath/nucleiscan_$1.txt
zip -r -q $1.zip $outputpath