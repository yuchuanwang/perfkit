## Perfkit - 性能分析与测量工具集



在我们进行软件、系统性能测量与优化的时候，经常会发现某个服务器或者虚拟机上，性能不正常了。想去抓取性能数据来分析定位的时候，因为很多工具默认是不安装的、而且有的时候也无法安装，没法及时抓取各种数据，然后就抓瞎了。

因此，实现了一个Dockerfile，包括了常见的各种Linux性能工具，包括perf、sar、vmstat、mpstat、iostat、top、htop、numastat、netstat、ss、ethtool、tcpdump等等。

以及，自带了生成火焰图的工具FlameGraph。

同时也包括了基于eBPF的工具集合[BCC](https://github.com/iovisor/bcc)，通过BCC的工具集，可以更加精细、有针对性地来抓取数据。其中包括了：profile、offcputime、execsnoop、runqlat、runqlen、softirqs、hardirqs、opensnoop、filetop、cachestat、tcplife、tcptop、tcpretrans等等。

这样，事先编译这个Dockerfile：

```shell
$ cd perfkit
$ docker build --tag perfkit .
```

然后，把它导出成perfkit.img文件：

```shell
$ docker save -o perfkit.img perfkit:latest
```

在需要分析测量的Host上面(**需要安装了Docker**)，导入之前的perfkit.img文件：

```shell
$ docker load < perfkit.img
```



然后运行这个容器，就可以随时随地开始抓取所需的性能数据了：

```shell
$ docker run --privileged -v /lib/modules:/lib/modules:ro -v /usr/src:/usr/src:ro -v /sys/kernel/debug:/sys/kernel/debug:rw -v /etc/localtime:/etc/localtime:ro -it perfkit bash
```



这个Dockerfile是基于Ubuntu 22.04，也只在Ubuntu 22.04的Host上试过。

发现了什么问题、或者有什么建议，欢迎告诉我。


