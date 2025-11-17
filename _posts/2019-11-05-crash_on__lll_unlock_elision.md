---
title: 记录一次排查__lll_unlock_elsion()函数coredump问题过程
tags: linux SUSE
---
调用某个so中的函数时必现coredump，但是在相同操作系统版本的其他环境上不会出现。

```shell
(gdb) bt
#0 0x555b1d90 in __lll_unlock_elision() from /lib/libpthread.so.0
...
```

<!--more-->

---

## 排查过程

出现此问题时，首先排查两台环境区别，发现操作系统版本均一致（Suse12sp3），且应用与调用的so等完全一致。
最终发现两台机器CPU不一致。
其中出现问题的环境CPU为 Intel Core Processor (Haswell)
正常环境的CPU为 Intel Xeon E312xx (Sandy Bridge)
上网搜索确认该问题属于一个CPU的bug。

> Unfortunately it is intel that developed bugged chips (Haswell, Broadwell and Skylake), they have it in their errata (BDD50,51) [desktop-mobile-5th-gen-core-family-spec-update.pdf](https://www-ssl.intel.com/content/dam/www/public/us/en/documents/specification-updates/desktop-mobile-5th-gen-core-family-spec-update.pdf)

## 解决办法

1. 更新so
2. 根据SUSE官网提供的方法，将应用链接的/lib64/libpthread.so改为/lib64/noelision/libpthread.so也可解决该问题。

---

## 参考

[bbs.archlinux](https://bbs.archlinux.org/viewtopic.php?id=202545)
[forums.opensuse](https://forums.opensuse.org/showthread.php/535482-Crash-on-__lll_unlock_elision)
[SUSE官网](https://www.suse.com/support/kb/doc/?id=000019071)
