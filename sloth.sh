echo "Target:" $1
mkdir $1
cd $1
# subfinder
subfinder -all -nc -silent -d $1 -o domain_$1.txt
# ctfr
python3 ../ctfr/ctfr.py -d $1 -o ctfr_$1.txt
sort ctfr_$1.txt | uniq | sed '/*/d' >> domain_$1.txt
# github
github-subdomains -k -d $1 -o github_$1.txt
sort github_$1.txt | uniq >> domain_$1.txt
# dns
puredns bruteforce ../dir/alldns.txt -r ../dir/resolvers.txt > dns_$1.txt
sort dns_$1.txt | uniq >> domain_$1.txt
# cleandomain
sort domain_$1.txt | uniq | puredns resolve -q -r resolvers.txt --write domain_$1.txt
cat domain_$1.txt | httpx -ip -title -cname  -ports 80,443,8080,8443,7001,8081 -follow-host-redirects -location -no-color -random-agent -silent -web-server -status-code -tech-detect -o httpx-$1.txt
awk '{print $1}' httpx-$1.txt > scanurl.txt
nuclei -l  scanurl.txt -t nuclei-templates -eid http-missing-security-headers,apache-detect,ssl-dns-names,waf-detect,expired-ssl,HTTP-TRACE,tech-detect,tomcat-exposed-docs,tls-version,default-openresty,nginx-version,old-copyright,default-nginx-page -o nucleiscan_$1.txt
zip -r -q ../$1.zip ./
