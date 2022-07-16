echo "Target:" $1

outputpath=./result/$1
ctfrpath=./Tools/ctfr/ctfr.py
dnsdicpath=./Config/alldns.txt
resolverspath=./Config/resolvers.txt
nucleiblack="openresty-detect,dns-waf-detect,cors-misconfig,options-method,txt-fingerprint,cname-fingerprint,email-extractor,addeventlistener-detect,http-missing-security-headers,deprecated-tls,nginx-status,apache-detect,ssl-dns-names,waf-detect,expired-ssl,HTTP-TRACE,tech-detect,tomcat-exposed-docs,tls-version,default-openresty,nginx-version,old-copyright,default-nginx-page,nameserver-fingerprint"


mkdir $outputpath
# subfinder
echo "Start subfinder"
subfinder -all -nc -silent -d $1 -o $outputpath/domain_$1.txt
# ctfr
# git clone https://github.com/UnaPibaGeek/ctfr.git
echo "Start ctfr"
python3 $ctfrpath -d $1 -o $outputpath/ctfr_$1.txt
sort $outputpath/ctfr_$1.txt | uniq | sed '/*/d' >> $outputpath/domain_$1.txt
# puredns 
# git clone https://github.com/blechschmidt/massdns.git
# cd massdns
# make
# sudo make install
# go install github.com/d3mondev/puredns/v2@latest
echo "Start puredns"
puredns bruteforce $dnsdicpath $1 -r $resolverspath > $outputpath/dns_$1.txt
sort $outputpath/dns_$1.txt | uniq >> $outputpath/domain_$1.txt
# cleandomain
sort $outputpath/domain_$1.txt | uniq | puredns resolve -q -r $resolverspath --write $outputpath/domain_$1.txt
# naabu
echo "Start naabu"
naabu -list $outputpath/domain_$1.txt -ec -tp 1000 -nmap-cli "nmap -sV -oN $1_nmap.txt" -silent -o $outputpath/portscan_$1.txt
# httpx
echo "Start httpx"
cat $outputpath/domain_$1.txt | httpx -ip -title -cname  -ports 80,443,8080,8443,7001,8081 -follow-host-redirects -location -no-color -random-agent -silent -web-server -status-code -tech-detect -o $outputpath/httpx-$1.txt
awk '{print $1}' $outputpath/httpx-$1.txt > $outputpath/scanurl.txt
# nuclei
echo "Start nuclei"
nuclei -l  $outputpath/scanurl.txt -eid $nucleiblack -o $outputpath/nucleiscan_$1.txt
echo "Package ing"
zip -r -q $1.zip $outputpath