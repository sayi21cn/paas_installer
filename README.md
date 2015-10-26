# paas_installer
CloudFoundry一键安装脚本

只需要两步，即可将Cloud Foundry任意模块安装到指定的ECS上，同时也保留了在本地单点安装全部模块的功能。 
1、修改config.yml 
2、执行deploy.sh脚本，指定配置文件为config.yml

脚本会根据配置执行，动态生成install脚本，push到目标节点，然后执行脚本安装。 
需要说明的是，多节点安装过程是并发的，每个节点安装完成后，会上传安装日志到install_log下面，可以查看安装过程中的错误。 
如果是本地安装，安装过程的输出会直接打印到屏幕。

配置说明： 
1、公共定制项 
deploy: 指定本次安装的模块，可选值：nats hm9000 ccng uaa ha dea loggr gorouter all，如果指定为all，则在本地单节点安装全部模块； 
domain: 指定域名，安装完成后，CC节点endpoint为: api.[domain]； 
password： 指定各模块的统一初始密码，包括但不限于uaadb、ccdb、nats等密码； 
org： 指定默认组织，目前默认为dtdream。

2、节点分布定制： 
component.[name]: name为模块名，可选值与deploy一致，且deploy中指定的模块，此处必须定制，另外nats节点也必须定制（大部分模块都依赖与nats）； 
component.[name].ip ：部署模块名为name的节点地址，如果是ECS，请直接使用内网地址； 
component.[name].psw: 目标地址root帐号的密码。
