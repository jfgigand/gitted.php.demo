## Get started

**You don't need to be root!** but you need [Git](http://git-scm.com/)
and [LXC](https://linuxcontainers.org/) installed on your Linux
system. See [Gitted](https://github.com/geonef/sysconf.gitted) for
more information.

```
git clone https://github.com/jfgigand/gitted.php.demo.git && cd demo
sysconf/gitted-client register && sysconf/gitted-client add demo
git push demo master
```

The last command creates the LXC container ```demo```,
install PHP, MySQL and the required packages (from ```sysconf/```) and
import the data (from ```mysql/```).
