# sloth
资产收集扫描脚本,根据域名获取子域名并调用httpx得到HTTP信息和调用nuclei做基础扫描,最后将所有结果打包到zip中,在vps上运行后直接下载zip到本地即可查看结果.
## 用到的工具
* subfinder
* nuclei
* ctfr
* github-subdomains
* puredns
* httpx
